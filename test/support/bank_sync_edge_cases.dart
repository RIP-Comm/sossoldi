import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/model/bank_connection.dart';
import 'package:sossoldi/services/banking/sync/bank_sync_result.dart';
import 'package:sossoldi/services/banking/sync/bank_sync_request.dart';
import 'package:sossoldi/services/database/repositories/bank_sync_repository.dart';
import 'bank_sync_harness.dart';

final syncAuditCases = <String, Future<void> Function(BankSyncHarness)>{
  'SYNC01 retrograde server clock never regresses a completed checkpoint':
      (h) async {
        await h.service.syncAccount(1);
        final before = await h.state();
        h.serverTime = DateTime.utc(2026, 9, 5, 12);
        h.pages = [[]];
        final result = await h.service.syncAccount(1);
        expect(result.completed, isFalse);
        expect(await h.state(), before);
      },
  'SYNC02 one missing account must not invalidate the other accounts in its consent':
      (h) async {
        await h.addAccount(2);
        h.intercept = (r) async =>
            r.url.path.contains('synthetic-uid-1/') &&
                r.url.path.endsWith('/details')
            ? h.response({'error': 'NOT_FOUND'}, status: 404)
            : null;
        final result = await h.service.syncConnection(1);
        expect(
          result.accounts.firstWhere((r) => r.accountId == 2).completed,
          isTrue,
        );
        expect((await h.db.query('bankConnection')).single['status'], 'ACTIVE');
      },
  'SYNC03 zero booked balance with pending-only history is importable':
      (h) async {
        h.pages = [
          [bankRecord(status: 'PDNG')],
        ];
        h.balance = '0.00';
        h.balanceMarker = null;
        expect((await h.service.syncAccount(1)).completed, isTrue);
        expect(await h.total(), 0);
      },
  'SYNC04 zero booked balance with cancelled-only history is importable':
      (h) async {
        h.pages = [
          [bankRecord(status: 'CNCL')],
        ];
        h.balance = '0.00';
        h.balanceMarker = null;
        expect((await h.service.syncAccount(1)).completed, isTrue);
        expect(await h.total(), 0);
      },
  'SYNC05 malformed balance offset hour 25 is rejected': (h) async {
    h.intercept = (r) async => r.url.path.endsWith('/balances')
        ? h.response({
            'balances': [
              {
                'name': 'Booked',
                'balance_amount': {'amount': '232.75', 'currency': 'EUR'},
                'balance_type': 'ITBD',
                'last_change_date_time': '2026-09-08T12:00:00+25:00',
                'last_committed_transaction': 'ref-1',
              },
            ],
          })
        : null;
    expect((await h.service.syncAccount(1)).completed, isFalse);
    expect(await h.transactions(), isEmpty);
  },
  'SYNC06 malformed balance offset minute 99 is rejected': (h) async {
    h.intercept = (r) async => r.url.path.endsWith('/balances')
        ? h.response({
            'balances': [
              {
                'name': 'Booked',
                'balance_amount': {'amount': '232.75', 'currency': 'EUR'},
                'balance_type': 'ITBD',
                'last_change_date_time': '2026-09-07T12:00:00+00:99',
                'last_committed_transaction': 'ref-1',
              },
            ],
          })
        : null;
    expect((await h.service.syncAccount(1)).completed, isFalse);
    expect(await h.transactions(), isEmpty);
  },
  'SYNC07 late failure from previous provider never changes replacement provider':
      (h) async {
        final old = await h.repository.readContext(1);
        await h.db.update('bankConnection', {
          'providerId': 'replacement-provider',
        }, where: 'id = 1');
        await h.repository.markConsentFailure(
          old,
          BankConnectionStatus.expired,
        );
        expect((await h.db.query('bankConnection')).single['status'], 'ACTIVE');
      },
  'SYNC08 transaction insert failure rolls back ledger and checkpoint': (h) async {
    await h.db.execute(
      "CREATE TRIGGER audit_fail BEFORE INSERT ON 'transaction' BEGIN SELECT RAISE(ABORT, 'synthetic disk failure'); END",
    );
    expect((await h.service.syncAccount(1)).completed, isFalse);
    expect(await h.transactions(), isEmpty);
    expect(await h.db.query('bankRemoteTransaction'), isEmpty);
    expect(await h.db.query('bankSyncState'), isEmpty);
  },
  'SYNC09 audit write failure rolls back the whole financial commit': (h) async {
    await h.db.execute(
      "CREATE TRIGGER audit_fail BEFORE INSERT ON bankSyncAudit BEGIN SELECT RAISE(ABORT, 'synthetic audit failure'); END",
    );
    final result = await h.service.syncAccount(1);
    expect(result.completed, isFalse);
    expect(result.warnings, contains('audit_write_failed'));
    expect(await h.transactions(), isEmpty);
    expect(await h.db.query('bankRemoteTransaction'), isEmpty);
  },
  'SYNC10 corrected direction changes debit into credit without changing opening':
      (h) async {
        await h.service.syncAccount(1);
        h.pages = [
          [bankRecord(indicator: 'CRDT')],
        ];
        h.balance = '379.03';
        expect((await h.service.syncAccount(1)).completed, isTrue);
        expect((await h.transactions()).single['type'], 'IN');
        expect((await h.state())['openingMinor'], '30589');
      },
  'SYNC11 malformed leap day rejects the whole batch': (h) async {
    h.pages = [
      [bankRecord(date: '2026-02-29')],
    ];
    expect((await h.service.syncAccount(1)).completed, isFalse);
    expect(await h.transactions(), isEmpty);
  },
  'SYNC12 huge amount cannot overflow legacy UI projection': (h) async {
    h.pages = [
      [bankRecord(amount: '99999999999999999999999999999.99')],
    ];
    expect((await h.service.syncAccount(1)).completed, isFalse);
    expect(await h.transactions(), isEmpty);
  },
  'SYNC13 oversized Unicode note cannot partly commit': (h) async {
    h.pages = [
      [bankRecord(note: List.filled(5000, '😀').join())],
    ];
    expect((await h.service.syncAccount(1)).completed, isFalse);
    expect(await h.transactions(), isEmpty);
  },
  'SYNC14 account deletion during fetch cannot resurrect its transactions':
      (h) async {
        h.intercept = (r) async {
          if (r.url.path.endsWith('/balances')) {
            await h.db.update('bankAccount', {
              'deletedAt': h.serverTime.toIso8601String(),
            }, where: 'id = 1');
          }
          return null;
        };
        expect((await h.service.syncAccount(1)).completed, isFalse);
        expect(await h.transactions(), isEmpty);
      },
  'SYNC15 global currency switch during fetch cannot commit mixed currency':
      (h) async {
        h.intercept = (r) async {
          if (r.url.path.endsWith('/balances')) {
            await h.db.update('currency', {
              'code': 'USD',
            }, where: 'mainCurrency = 1');
          }
          return null;
        };
        expect((await h.service.syncAccount(1)).completed, isFalse);
        expect(await h.transactions(), isEmpty);
      },
  'SYNC16 absent manual context never sends partial PSU information':
      (h) async {
        h.requiredHeaders = ['Psu-Ip-Address', 'Psu-User-Agent'];
        final result = await h.service.syncAccount(
          1,
          request: const BankSyncRequest(
            trigger: BankSyncTrigger.manual,
            psuHeaders: {'Psu-Ip-Address': '192.0.2.1'},
          ),
        );
        expect(result.completed, isFalse);
        expect(
          h.requests.where((r) => r.url.path.startsWith('/accounts/')),
          isEmpty,
        );
      },
  'SYNC17 nonzero balance without any history cannot initialize silently':
      (h) async {
        h.pages = [[]];
        h.balanceMarker = null;
        h.balance = '500.00';
        expect((await h.service.syncAccount(1)).completed, isFalse);
        expect(await h.db.query('bankSyncState'), isEmpty);
      },
  'SYNC18 negative booked balance can initialize an overdrawn account':
      (h) async {
        h.balance = '-10.00';
        expect((await h.service.syncAccount(1)).completed, isTrue);
        expect(await h.total(), closeTo(-10, 0.000001));
      },
  'SYNC19 multi-account partial result preserves successful account':
      (h) async {
        await h.addAccount(2);
        h.intercept = (r) async => r.url.path.contains('synthetic-uid-1/')
            ? h.response({'error': 'ASPSP_ERROR'}, status: 503)
            : null;
        final result = await h.service.syncConnection(1);
        expect(result.status, BankSyncStatus.partial);
        expect(
          result.accounts.firstWhere((r) => r.accountId == 2).completed,
          isTrue,
        );
      },
  'SYNC20 reopen database preserves exact state and idempotency': (h) async {
    await h.service.syncAccount(1);
    await h.db.close();
    h.db = await h.factory.openDatabase(h.path);
    h.repository = BankSyncRepository.withDatabase(h.db);
    h.resetService();
    expect((await h.service.syncAccount(1)).status, BankSyncStatus.noChange);
    expect(await h.transactions(), hasLength(1));
    expect(await h.total(), closeTo(232.75, 0.000001));
  },
  'SYNC21 account not found with missing session invalidates that consent':
      (h) async {
        h.intercept = (r) async =>
            r.url.path.endsWith('/details') ||
                r.url.path.startsWith('/sessions/')
            ? h.response({'error': 'NOT_FOUND'}, status: 404)
            : null;
        expect((await h.service.syncAccount(1)).completed, isFalse);
        expect(
          h.requests.any((r) => r.url.path.startsWith('/sessions/')),
          isTrue,
        );
        expect(
          (await h.db.query('bankConnection')).single['status'],
          'REAUTH_REQUIRED',
        );
      },
  'SYNC22 inconclusive session check preserves other accounts': (h) async {
    await h.addAccount(2);
    h.intercept = (r) async {
      if (r.url.path.startsWith('/sessions/')) {
        return h.response({'error': 'ASPSP_ERROR'}, status: 503);
      }
      if (r.url.path.contains('synthetic-uid-1/') &&
          r.url.path.endsWith('/details')) {
        return h.response({'error': 'NOT_FOUND'}, status: 404);
      }
      return null;
    };
    final result = await h.service.syncConnection(1);
    expect(
      result.accounts.firstWhere((a) => a.accountId == 2).completed,
      isTrue,
    );
    expect((await h.db.query('bankConnection')).single['status'], 'ACTIVE');
  },
  'SYNC23 delayed session failure cannot expire a renewed session': (h) async {
    h.intercept = (r) async {
      if (r.url.path.endsWith('/details')) {
        return h.response({'error': 'NOT_FOUND'}, status: 404);
      }
      if (r.url.path.startsWith('/sessions/')) {
        await h.db.update('bankConnection', {
          'sessionId': 'renewed-session',
        }, where: 'id = 1');
        return h.response({'error': 'NOT_FOUND'}, status: 404);
      }
      return null;
    };
    await h.service.syncAccount(1);
    expect((await h.db.query('bankConnection')).single['status'], 'ACTIVE');
  },
  'SYNC24 server clock equal to last completion remains idempotent': (h) async {
    await h.service.syncAccount(1);
    expect((await h.service.syncAccount(1)).status, BankSyncStatus.noChange);
    expect(await h.transactions(), hasLength(1));
  },
};
