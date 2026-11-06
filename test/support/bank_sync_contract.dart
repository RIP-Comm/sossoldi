import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:sossoldi/services/banking/sync/bank_sync_lifecycle.dart';
import 'package:sossoldi/services/banking/sync/bank_sync_service.dart';
import 'package:sossoldi/services/banking/sync/bank_sync_request.dart';
import 'package:sossoldi/services/banking/sync/bank_sync_result.dart';
import 'package:sossoldi/services/database/migration_manager.dart';
import 'package:sossoldi/services/database/repositories/bank_connection_repository.dart';
import 'package:sqflite/sqflite.dart';

import 'bank_sync_harness.dart';

/// The same financial contract runs on desktop SQLite and the native iOS plugin.
void bankSyncContract(DatabaseFactory factory) {
  late BankSyncHarness h;

  setUp(() async {
    h = BankSyncHarness(factory);
    await h.open();
  });
  tearDown(() => h.close());

  test(
    'a later server timestamp validates every page before advancing a checkpoint',
    () async {
      await h.service.syncAccount(1);
      final previous = await h.state();
      final transactions = await h.transactions();
      h.pages = [
        [bankRecord(reference: 'future', date: '2030-01-01')],
        [bankRecord()],
      ];
      h.intercept = (request) async {
        if (request.url.path.endsWith('/transactions') &&
            request.url.queryParameters['continuation_key'] == null) {
          return h.response(
            {'transactions': h.pages.first, 'continuation_key': '1'},
            headers: {'date': 'invalid'},
          );
        }
        return null;
      };
      final result = await h.service.syncAccount(1);
      expect(result.status, BankSyncStatus.partial);
      expect(result.rejected, 1);
      expect(await h.state(), previous);
      expect(await h.transactions(), transactions);
    },
  );

  test('malformed PSU header names cannot reach an account endpoint', () async {
    h.requiredHeaders = ['PSU-IP-Address\r\nInjected'];
    final result = await h.service.syncAccount(
      1,
      request: const BankSyncRequest(
        trigger: BankSyncTrigger.manual,
        psuHeaders: {'PSU-IP-Address\r\nInjected': '127.0.0.1'},
      ),
    );
    expect(result.status, BankSyncStatus.partial);
    expect(
      h.requests.where((request) => request.url.path.startsWith('/accounts/')),
      isEmpty,
    );
    expect(await h.transactions(), isEmpty);
  });

  test(
    'initial import reconciles 305.89 - 73.14 = 232.75 exactly and re-sync is idempotent',
    () async {
      final result = await h.service.syncAccount(1);
      expect(result.status, BankSyncStatus.success);
      expect(result.inserted, 1);
      expect(await h.total(), closeTo(232.75, 0.000001));
      expect((await h.state())['openingMinor'], '30589');
      expect((await h.state())['balanceMinor'], '23275');
      expect((await h.state())['checkpoint'], '2026-09-06T00:00:00.000Z');
      expect(
        h.requests
            .firstWhere((request) => request.url.path.endsWith('/transactions'))
            .url
            .queryParameters['strategy'],
        'longest',
      );
      expect((await h.service.syncAccount(1)).status, BankSyncStatus.noChange);
      expect(await h.transactions(), hasLength(1));
      expect(
        h.requests
            .lastWhere((request) => request.url.path.endsWith('/transactions'))
            .url
            .queryParameters['date_from'],
        isNull,
      );
    },
  );

  test(
    'corrections, cancellation and rebooking preserve explicit local edits',
    () async {
      await h.service.syncAccount(1);
      final localId = (await h.transactions()).single['id'];
      await h.db.update(
        'transaction',
        {'note': 'My private note', 'idCategory': 42},
        where: 'id = ?',
        whereArgs: [localId],
      );
      h.pages = [
        [
          bankRecord(
            id: 'changed-id',
            amount: '70.00',
            note: 'Corrected bank note',
          ),
        ],
      ];
      h.balance = '235.89';
      expect((await h.service.syncAccount(1)).updated, 1);
      final edited = (await h.transactions()).single;
      expect(edited['id'], localId);
      expect(edited['amount'], 70);
      expect(edited['type'], 'OUT');
      expect(edited['note'], 'My private note');
      expect(edited['idCategory'], 42);
      h.pages = [
        [bankRecord(status: 'CNCL')],
      ];
      expect((await h.service.syncAccount(1)).cancelled, 1);
      expect(await h.transactions(), isEmpty);
      h.pages = [
        [bankRecord(amount: '70.00')],
      ];
      expect((await h.service.syncAccount(1)).inserted, 1);
      expect((await h.transactions()).single['note'], 'My private note');
      expect((await h.transactions()).single['idCategory'], 42);
    },
  );

  test(
    'pending becomes booked and explicit local deletion remains suppressed',
    () async {
      await h.service.syncAccount(1);
      h.pages = [
        [
          bankRecord(),
          bankRecord(reference: 'pending', status: 'PDNG', amount: '1'),
        ],
      ];
      await h.service.syncAccount(1);
      expect(await h.transactions(), hasLength(1));
      h.pages = [
        [bankRecord(), bankRecord(reference: 'pending', amount: '1')],
      ];
      h.balance = '231.75';
      expect((await h.service.syncAccount(1)).inserted, 1);
      final id = (await h.transactions()).last['id'];
      await h.db.delete('transaction', where: 'id = ?', whereArgs: [id]);
      await h.service.syncAccount(1);
      expect(await h.transactions(), hasLength(1));
    },
  );

  test(
    'page order, page size and transient ID collisions do not change identity',
    () async {
      h.pages = [
        [bankRecord()],
        [bankRecord(reference: 'ref-2', id: 'temporary-1', amount: '1')],
      ];
      h.balance = '231.75';
      expect((await h.service.syncAccount(1)).inserted, 2);
      final before = await h.transactions();
      h.pages = [
        [
          bankRecord(reference: 'ref-2', id: 'new', amount: '1'),
          bankRecord(id: 'new'),
        ],
      ];
      expect((await h.service.syncAccount(1)).status, BankSyncStatus.noChange);
      expect(await h.transactions(), before);
    },
  );

  test(
    'ambiguous duplicate fingerprints or references abort the whole batch',
    () async {
      for (final reference in <String?>[null, 'duplicate']) {
        h.pages = [
          [bankRecord(reference: reference)],
          [bankRecord(reference: reference, id: 'other')],
        ];
        final result = await h.service.syncAccount(1);
        expect(result.status, BankSyncStatus.partial);
        expect(result.warnings, contains('ambiguous_transaction_identity'));
        expect(await h.transactions(), isEmpty);
        expect(await h.db.query('bankSyncState'), isEmpty);
      }
    },
  );

  test(
    'fallback identity survives changed IDs but ambiguous corrections remain retryable by the user',
    () async {
      h.pages = [
        [bankRecord(), bankRecord(reference: null, amount: '1')],
      ];
      h.balance = '231.75';
      await h.service.syncAccount(1);
      h.pages = [
        [bankRecord(reference: null, amount: '1', id: 'changed'), bankRecord()],
      ];
      expect((await h.service.syncAccount(1)).status, BankSyncStatus.noChange);
      final state = await h.state();
      h.pages = [
        [bankRecord(), bankRecord(reference: null, amount: '2')],
      ];
      expect((await h.service.syncAccount(1)).status, BankSyncStatus.partial);
      expect(await h.state(), state);
      expect(await h.transactions(), hasLength(2));
    },
  );

  test(
    'invalid records do not commit valid siblings or advance checkpoints',
    () async {
      await h.service.syncAccount(1);
      final before = await h.state();
      h.pages = [
        [
          bankRecord(),
          bankRecord(reference: 'new', amount: '2'),
          {'status': 'BOOK'},
        ],
      ];
      final result = await h.service.syncAccount(1);
      expect(result.status, BankSyncStatus.partial);
      expect(result.rejected, 1);
      expect(await h.state(), before);
      expect(await h.transactions(), hasLength(1));
      final audit = (await h.db.query('bankSyncAudit')).single;
      expect(audit['warnings'], '["invalid_financial_records"]');
      expect(audit.toString(), isNot(contains('Synthetic purchase')));
      h.pages = [
        [bankRecord(), bankRecord(reference: 'new', amount: '2')],
      ];
      h.balance = '230.75';
      expect((await h.service.syncAccount(1)).inserted, 1);
    },
  );

  test(
    'foreign account and transaction currencies never enter global totals',
    () async {
      h.bankCurrency = 'USD';
      expect(
        (await h.service.syncAccount(1)).status,
        BankSyncStatus.terminalFailure,
      );
      expect(await h.transactions(), isEmpty);
      h.bankCurrency = 'EUR';
      h.pages = [
        [bankRecord(currency: 'USD')],
      ];
      expect((await h.service.syncAccount(1)).status, BankSyncStatus.partial);
      expect(await h.db.query('bankSyncState'), isEmpty);
    },
  );

  for (final currency in ['USD', 'GBP', 'CHF']) {
    test(
      'uses the selected $currency as the global unit without EUR assumptions',
      () async {
        await h.db.transaction((txn) async {
          await txn.update('currency', {'mainCurrency': 0});
          await txn.update(
            'currency',
            {'mainCurrency': 1},
            where: 'code = ?',
            whereArgs: [currency],
          );
        });
        h.bankCurrency = currency;
        h.pages = [
          [bankRecord(currency: currency)],
        ];
        expect((await h.service.syncAccount(1)).status, BankSyncStatus.success);
        expect((await h.state())['currency'], currency);
        expect((await h.state())['openingMinor'], '30589');
      },
    );
  }

  test(
    'global currency and bank-owned values cannot silently be relabeled or edited',
    () async {
      await h.service.syncAccount(1);
      await expectLater(
        h.db.transaction((txn) async {
          await txn.update('currency', {'mainCurrency': 0});
          await txn.update(
            'currency',
            {'mainCurrency': 1},
            where: 'code = ?',
            whereArgs: ['USD'],
          );
        }),
        throwsA(isA<DatabaseException>()),
      );
      expect(
        (await h.db.query(
          'currency',
          where: 'mainCurrency = 1',
        )).single['code'],
        'EUR',
      );
      await expectLater(
        h.db.update('transaction', {'amount': 1}),
        throwsA(isA<DatabaseException>()),
      );
      await expectLater(
        h.db.update('bankAccount', {'startingValue': 1}, where: 'id = 1'),
        throwsA(isA<DatabaseException>()),
      );
    },
  );

  test(
    'stale, available, unanchored and expected balances cannot initialize an account',
    () async {
      for (final type in ['CLAV', 'ITAV', 'XPCD', 'UNKNOWN']) {
        h.balanceType = type;
        expect((await h.service.syncAccount(1)).status, BankSyncStatus.partial);
      }
      h.balanceType = 'CLBD';
      h.balanceTime = h.serverTime.subtract(const Duration(days: 10));
      expect((await h.service.syncAccount(1)).status, BankSyncStatus.partial);
      h.balanceTime = null;
      h.balanceMarker = 'not-fetched';
      expect((await h.service.syncAccount(1)).status, BankSyncStatus.partial);
      expect(await h.transactions(), isEmpty);
    },
  );

  for (final target in [
    'bankRemoteTransaction',
    'transaction',
    'bankSyncState',
    'bankSyncAudit',
  ]) {
    test(
      'SQLite failure at $target rolls back financial data and checkpoints',
      () async {
        await h.db.execute(
          'CREATE TRIGGER injected_failure BEFORE INSERT ON "$target" BEGIN SELECT RAISE(ABORT, \'injected\'); END',
        );
        final result = await h.service.syncAccount(1);
        expect(result.completed, isFalse);
        expect(await h.transactions(), isEmpty);
        expect(await h.db.query('bankRemoteTransaction'), isEmpty);
        expect(await h.db.query('bankSyncState'), isEmpty);
        expect(
          (await h.db.query(
            'bankAccount',
            where: 'id = 1',
          )).single['lastSyncAt'],
          isNull,
        );
      },
    );
  }

  test(
    'a network error after pagination leaves the previous batch intact',
    () async {
      await h.service.syncAccount(1);
      final before = await h.state();
      h.pages = [
        [bankRecord()],
        [bankRecord(reference: 'new')],
      ];
      h.intercept = (request) async =>
          request.url.queryParameters['continuation_key'] == '1'
          ? h.response({'error': 'ASPSP_ERROR'}, status: 503)
          : null;
      final result = await h.service.syncAccount(1);
      expect(result.status, BankSyncStatus.retryableFailure);
      expect(await h.state(), before);
      expect(await h.transactions(), hasLength(1));
      expect(h.sleeps, hasLength(3));
    },
  );

  test('429 honors Retry-After and retry count is bounded', () async {
    var calls = 0;
    h.intercept = (request) async {
      if (!request.url.path.endsWith('/transactions')) return null;
      calls++;
      return calls == 1
          ? h.response(
              {'error': 'ASPSP_RATE_LIMIT_EXCEEDED'},
              status: 429,
              headers: {'retry-after': '2'},
            )
          : null;
    };
    expect((await h.service.syncAccount(1)).status, BankSyncStatus.success);
    expect(h.sleeps, [const Duration(seconds: 2)]);
    expect(calls, 2);
  });

  test('absolute Retry-After uses server time, not the local clock', () async {
    var calls = 0;
    h.localTime = DateTime.utc(2040);
    h.intercept = (request) async {
      if (!request.url.path.endsWith('/transactions')) return null;
      calls++;
      return calls == 1
          ? h.response(
              {'error': 'ASPSP_RATE_LIMIT_EXCEEDED'},
              status: 429,
              headers: {
                'retry-after': HttpDate.format(
                  h.serverTime.add(const Duration(seconds: 3)),
                ),
              },
            )
          : null;
    };
    expect((await h.service.syncAccount(1)).completed, isTrue);
    expect(h.sleeps, [const Duration(seconds: 3)]);
  });

  test('malformed Retry-After falls back to bounded backoff', () async {
    var calls = 0;
    h.intercept = (request) async {
      if (!request.url.path.endsWith('/transactions')) return null;
      calls++;
      return calls == 1
          ? h.response(
              {'error': 'ASPSP_RATE_LIMIT_EXCEEDED'},
              status: 429,
              headers: {'retry-after': 'invalid'},
            )
          : null;
    };
    expect((await h.service.syncAccount(1)).completed, isTrue);
    expect(calls, 2);
    expect(h.sleeps, hasLength(1));
  });

  test(
    'absolute Retry-After without server time does not retry early',
    () async {
      h.intercept = (request) async {
        if (!request.url.path.endsWith('/transactions')) return null;
        return h.response(
          {'error': 'ASPSP_RATE_LIMIT_EXCEEDED'},
          status: 429,
          headers: {
            'date': 'invalid',
            'retry-after': HttpDate.format(
              h.serverTime.add(const Duration(seconds: 3)),
            ),
          },
        );
      };
      expect(
        (await h.service.syncAccount(1)).status,
        BankSyncStatus.retryableFailure,
      );
      expect(h.sleeps, isEmpty);
      expect(await h.transactions(), isEmpty);
      expect(await h.db.query('bankSyncState'), isEmpty);
    },
  );

  test(
    'continuation cycles, page caps and record caps cannot commit incomplete feeds',
    () async {
      h.cycle = true;
      expect(
        (await h.service.syncAccount(1)).warnings,
        contains('continuation_cycle'),
      );
      h.cycle = false;
      h.pages = [
        [bankRecord()],
        [bankRecord(reference: 'second')],
      ];
      h.resetService(limits: const BankSyncLimits(pages: 1));
      expect((await h.service.syncAccount(1)).warnings, contains('page_limit'));
      h.resetService(limits: const BankSyncLimits(records: 1));
      expect(
        (await h.service.syncAccount(1)).warnings,
        contains('record_limit'),
      );
      expect(await h.transactions(), isEmpty);
    },
  );

  test(
    'history fallback is explicit and does not invent a 90 day cutoff',
    () async {
      h.intercept = (request) async =>
          request.url.queryParameters['strategy'] == 'longest'
          ? h.response({'error': 'WRONG_TRANSACTIONS_PERIOD'}, status: 422)
          : null;
      final result = await h.service.syncAccount(1);
      expect(result.completed, isTrue);
      expect(result.warnings, contains('bank_default_history_fallback'));
      expect((await h.state())['strategy'], 'default');
      expect(
        h.requests
            .where((request) => request.url.path.endsWith('/transactions'))
            .every(
              (request) =>
                  !request.url.queryParameters.containsKey('date_from'),
            ),
        isTrue,
      );
    },
  );

  test(
    'manual PSU headers are complete and background headers are absent',
    () async {
      h.requiredHeaders = ['Psu-Ip-Address', 'Psu-User-Agent'];
      final incomplete = await h.service.syncAccount(
        1,
        request: const BankSyncRequest(
          trigger: BankSyncTrigger.manual,
          psuHeaders: {'Psu-Ip-Address': '192.0.2.1'},
        ),
      );
      expect(incomplete.completed, isFalse);
      expect(
        h.requests.where((request) => request.url.path.contains('/accounts/')),
        isEmpty,
      );
      await h.service.syncAccount(
        1,
        request: const BankSyncRequest(
          trigger: BankSyncTrigger.manual,
          psuHeaders: {
            'Psu-Ip-Address': '192.0.2.1',
            'Psu-User-Agent': 'Synthetic test',
          },
        ),
      );
      expect(h.requests.last.headers['psu-ip-address'], '192.0.2.1');
      h.requests.clear();
      await h.service.syncAccount(1);
      expect(
        h.requests.every(
          (request) => !request.headers.keys.any(
            (name) => name.toLowerCase().startsWith('psu-'),
          ),
        ),
        isTrue,
      );
    },
  );

  test(
    'concurrent triggers coalesce and reconnect retains stable local identity',
    () async {
      final results = await Future.wait([
        h.service.syncAccount(1),
        h.service.syncAccount(1),
      ]);
      expect(results[0], same(results[1]));
      expect(
        h.requests.where(
          (request) => request.url.path.endsWith('/transactions'),
        ),
        hasLength(1),
      );
      final localId = (await h.transactions()).single['id'];
      await h.db.update('bankAccount', {
        'ebAccountUid': 'new-session-uid',
      }, where: 'id = 1');
      await h.db.update('bankConnection', {
        'sessionId': 'replacement-session',
      }, where: 'id = 1');
      expect((await h.service.syncAccount(1)).status, BankSyncStatus.noChange);
      expect((await h.transactions()).single['id'], localId);
    },
  );

  test('disconnect during fetch invalidates the commit', () async {
    h.intercept = (request) async {
      if (request.url.path.endsWith('/balances')) {
        await h.db.update('bankConnection', {
          'status': 'DISCONNECTED',
        }, where: 'id = 1');
      }
      return null;
    };
    expect((await h.service.syncAccount(1)).status, BankSyncStatus.partial);
    expect(await h.transactions(), isEmpty);
  });

  test(
    'completed disconnect keeps imported history as editable manual transactions',
    () async {
      await h.service.syncAccount(1);
      await BankConnectionRepository.withDatabase(h.db).disconnectLocally(1);
      expect(await h.db.query('bankRemoteTransaction'), isEmpty);
      expect(await h.db.query('bankSyncState'), isEmpty);
      expect(await h.transactions(), hasLength(1));
      await h.db.update('transaction', {'amount': 80});
      await h.db.update('bankAccount', {'startingValue': 300}, where: 'id = 1');
      expect(await h.total(), 220);
    },
  );

  test(
    'database clear removes exact ledger and checkpoints with the original data',
    () async {
      await h.service.syncAccount(1);
      await NativeContractDatabase(h.db).clearDatabase();
      for (final table in [
        'bankAccount',
        'transaction',
        'bankRemoteTransaction',
        'bankSyncState',
        'bankSyncAudit',
      ]) {
        expect(await h.db.query(table), isEmpty);
      }
    },
  );

  test(
    'database reset recreates the complete schema without obsolete sync guards',
    () async {
      await h.service.syncAccount(1);
      await NativeContractDatabase(h.db).resetDatabase();
      expect(await h.db.query('bankRemoteTransaction'), isEmpty);
      expect(await h.db.query('bankSyncState'), isEmpty);
      expect(
        (await h.db.query(
          'currency',
          where: 'mainCurrency = 1',
        )).single['code'],
        'EUR',
      );
    },
  );

  test(
    'mixed account outcomes are partial and total failure cannot look like zero changes',
    () async {
      await h.addAccount(2);
      h.intercept = (request) async =>
          request.url.path.contains('synthetic-uid-2')
          ? h.response({'error': 'ASPSP_ERROR'}, status: 503)
          : null;
      final result = await h.service.syncConnection(1);
      expect(result.status, BankSyncStatus.partial);
      expect(result.accounts.map((value) => value.status), [
        BankSyncStatus.success,
        BankSyncStatus.retryableFailure,
      ]);
      h.applicationId = 'wrong-application';
      expect(
        (await h.service.syncAll()).status,
        BankSyncStatus.terminalFailure,
      );
    },
  );

  test(
    'local clock changes do not move the remote transaction checkpoint',
    () async {
      h.localTime = DateTime.utc(2040);
      await h.service.syncAccount(1);
      expect((await h.state())['checkpoint'], '2026-09-06T00:00:00.000Z');
      h.localTime = DateTime.utc(2000);
      final result = await h.service.syncAccount(1);
      expect(result.completed, isTrue);
      expect((await h.state())['checkpoint'], '2026-09-06T00:00:00.000Z');
    },
  );

  test(
    'manual and background throttles are independent and use monotonic elapsed time',
    () async {
      h.resetService(limits: const BankSyncLimits());
      expect((await h.service.syncAccount(1)).completed, isTrue);
      expect((await h.service.syncAccount(1)).status, BankSyncStatus.skipped);
      const manual = BankSyncRequest(trigger: BankSyncTrigger.manual);
      expect(
        (await h.service.syncAccount(1, request: manual)).completed,
        isTrue,
      );
      h.localTime = DateTime.utc(2040);
      expect(
        (await h.service.syncAccount(1, request: manual)).status,
        BankSyncStatus.skipped,
      );
      h.elapsed += const Duration(seconds: 16);
      expect(
        (await h.service.syncAccount(1, request: manual)).completed,
        isTrue,
      );
    },
  );

  test(
    'database reopen preserves ledger, local edits and deduplication',
    () async {
      await h.service.syncAccount(1);
      await h.db.close();
      h.db = await factory.openDatabase(h.path);
      final ledger = await h.db.query('bankRemoteTransaction');
      expect(ledger.single['amountMinor'], '-7314');
      expect(
        (await h.db.query('bankSyncState')).single['openingMinor'],
        '30589',
      );
      expect(await h.transactions(), hasLength(1));
    },
  );

  test(
    'zero-decimal currency works while three-decimal UI import is explicitly refused',
    () async {
      await h.db.update('currency', {'mainCurrency': 0});
      await h.db.insert('currency', {
        'symbol': 'JPY',
        'code': 'JPY',
        'name': 'Japanese yen',
        'mainCurrency': 1,
      });
      h.bankCurrency = 'JPY';
      h.pages = [
        [bankRecord(currency: 'JPY', amount: '73')],
      ];
      h.balance = '232';
      expect((await h.service.syncAccount(1)).completed, isTrue);
      expect((await h.state())['openingMinor'], '305');
    },
  );

  test(
    'three-decimal and XXX global currencies cannot silently lose precision',
    () async {
      await h.db.update('currency', {'mainCurrency': 0});
      final id = await h.db.insert('currency', {
        'symbol': 'KWD',
        'code': 'KWD',
        'name': 'Kuwaiti dinar',
        'mainCurrency': 1,
      });
      expect(
        (await h.service.syncAccount(1)).warnings,
        contains('unsupported_global_currency_precision'),
      );
      await h.db.update(
        'currency',
        {'code': 'XXX'},
        where: 'id = ?',
        whereArgs: [id],
      );
      expect((await h.service.syncAccount(1)).completed, isFalse);
      expect(await h.transactions(), isEmpty);
    },
  );

  test(
    'a total deadline and a Retry-After beyond the budget do not start more requests',
    () async {
      h.resetService(
        limits: const BankSyncLimits(timeout: Duration(milliseconds: 20)),
      );
      h.intercept = (request) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return null;
      };
      expect(
        (await h.service.syncAccount(1)).warnings,
        contains('operation_timeout'),
      );
      await Future<void>.delayed(const Duration(milliseconds: 60));
      h.requests.clear();
      h.resetService(
        limits: const BankSyncLimits(timeout: Duration(seconds: 1)),
      );
      h.intercept = (request) async => h.response(
        {'error': 'ASPSP_RATE_LIMIT_EXCEEDED'},
        status: 429,
        headers: {'retry-after': '3600'},
      );
      expect(
        (await h.service.syncAccount(1)).status,
        BankSyncStatus.retryableFailure,
      );
      expect(h.requests, hasLength(1));
      expect(h.sleeps, isEmpty);
      expect(await h.transactions(), isEmpty);
    },
  );

  test('missing server time never advances a financial checkpoint', () async {
    h.intercept = (request) async {
      if (!request.url.path.endsWith('/transactions')) return null;
      return h.response(
        {
          'transactions': [bankRecord()],
        },
        headers: {'date': 'invalid'},
      );
    };
    expect((await h.service.syncAccount(1)).completed, isFalse);
    expect(await h.db.query('bankSyncState'), isEmpty);
  });

  test(
    'startup and resume retry after days, with no duplicate observer requests',
    () async {
      h.resetService();
      final results = StreamController<BankSyncSummary>();
      final iterator = StreamIterator(results.stream);
      final lifecycle = BankSyncLifecycle(
        service: h.service,
        onResult: results.add,
        onError: results.addError,
      );
      try {
        lifecycle.start();
        lifecycle.start();
        expect(await iterator.moveNext(), isTrue);
        expect(iterator.current.status, BankSyncStatus.success);
        h.localTime = h.localTime.add(const Duration(days: 2));
        h.serverTime = h.serverTime.add(const Duration(days: 2));
        h.elapsed += const Duration(days: 2);
        lifecycle.didChangeAppLifecycleState(AppLifecycleState.resumed);
        expect(await iterator.moveNext(), isTrue);
        expect(iterator.current.status, BankSyncStatus.noChange);
        expect(
          h.requests.where(
            (request) => request.url.path.endsWith('/transactions'),
          ),
          hasLength(2),
        );
      } finally {
        lifecycle.dispose();
        await iterator.cancel();
        await results.close();
      }
    },
  );

  test(
    'v8 upgrade preserves manual data and creates the exact bank ledger',
    () async {
      final path = '${h.path}.v8';
      final manager = MigrationManager();
      final old = await factory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 8,
          onCreate: (db, version) => manager.migrate(db, 0, version),
        ),
      );
      final manual = Map<String, Object?>.from(
        (await h.db.query('bankAccount')).single,
      )..remove('currencyCode');
      manual.addAll({
        'ebConnectionId': null,
        'ebAccountUid': null,
        'startingValue': 12.34,
      });
      await old.insert('bankAccount', manual);
      await old.close();
      final upgraded = await factory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: manager.latestVersion,
          onUpgrade: manager.migrate,
        ),
      );
      try {
        final row = (await upgraded.query('bankAccount')).single;
        expect(row['startingValue'], 12.34);
        expect(row['currencyCode'], isNull);
        expect(await upgraded.query('bankRemoteTransaction'), isEmpty);
        expect(await upgraded.query('bankSyncState'), isEmpty);
      } finally {
        await upgraded.close();
        await factory.deleteDatabase(path);
      }
    },
  );
}
