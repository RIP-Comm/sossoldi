import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/model/bank_connection.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sossoldi/services/banking/sync/bank_sync_result.dart';
import 'package:sossoldi/providers/banking_ui_provider.dart';
import '../../support/bank_sync_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late BankSyncHarness h;
  setUp(() async {
    h = BankSyncHarness(databaseFactoryFfi);
    await h.open();
  });
  tearDown(() => h.close());

  test(
    'EDGE01 six months away and renewed consent preserve exact ledger',
    () async {
      await h.service.syncAccount(1);
      h.localTime = DateTime.utc(2027, 3, 7, 12);
      h.serverTime = h.localTime;
      await h.db.update('bankConnection', {
        'validUntil': '2027-06-01T00:00:00Z',
      }, where: 'id = 1');
      h.resetService();
      expect((await h.service.syncAccount(1)).status, BankSyncStatus.noChange);
      expect(await h.transactions(), hasLength(1));
      expect(await h.total(), closeTo(232.75, 0.000001));
    },
  );

  test('EDGE02 expired consent after six months preserves data', () async {
    await h.service.syncAccount(1);
    final before = await h.state();
    h.serverTime = DateTime.utc(2027, 3, 7, 12);
    h.localTime = h.serverTime;
    final result = await h.service.syncAccount(1);
    expect(result.warnings, contains('consent_expired'));
    expect((await h.db.query('bankConnection')).single['status'], 'EXPIRED');
    expect(await h.state(), before);
    expect(await h.transactions(), hasLength(1));
  });

  test(
    'EDGE03 remotely revoked consent should stop appearing active',
    () async {
      await h.service.syncAccount(1);
      h.intercept = (request) async => request.url.path.endsWith('/details')
          ? h.response({'error': 'REVOKED_SESSION'}, status: 403)
          : null;
      final result = await h.service.syncAccount(1);
      expect(result.status, BankSyncStatus.terminalFailure);
      expect(
        (await h.db.query('bankConnection')).single['status'],
        'REAUTH_REQUIRED',
      );
    },
  );

  test(
    'EDGE04 long gap with truncated feed must expose missing history',
    () async {
      await h.service.syncAccount(1);
      final before = await h.state();
      final rows = await h.transactions();
      h.serverTime = DateTime.utc(2026, 12, 7, 12);
      h.localTime = h.serverTime;
      h.pages = [
        [bankRecord(reference: 'recent', date: '2026-12-06', amount: '10.00')],
      ];
      h.balanceMarker = 'recent';
      h.balance = '122.75';
      final result = await h.service.syncAccount(1);
      expect(await h.state(), before);
      expect(await h.transactions(), rows);
      expect(result.warnings, contains('balance_mismatch'));
      expect(
        bankSyncNeedsAttention(await h.repository.latestResults(1)),
        isTrue,
      );
      final state = await h.state();
      expect(
        result.completed,
        isFalse,
        reason:
            'Missing October debit 100 is absent from the returned history; opening became ${state['openingMinor']} and only ${(await h.transactions()).length} records exist.',
      );
    },
  );

  test(
    'EDGE05 correction older than overlap must not turn into opening adjustment',
    () async {
      await h.service.syncAccount(1);
      h.serverTime = DateTime.utc(2026, 9, 21, 12);
      h.localTime = h.serverTime;
      final recent = bankRecord(
        reference: 'recent',
        date: '2026-09-20',
        amount: '10.00',
      );
      h.pages = [
        [bankRecord(), recent],
      ];
      h.balance = '222.75';
      h.balanceMarker = 'recent';
      await h.service.syncAccount(1);
      h.serverTime = DateTime.utc(2026, 10, 30, 12);
      h.localTime = h.serverTime;
      h.balance = '225.89';
      h.intercept = (request) async {
        if (!request.url.path.endsWith('/transactions')) return null;
        final from = request.url.queryParameters['date_from'];
        final corrected = bankRecord(amount: '70.00');
        final rows = [corrected, recent]
            .where(
              (row) =>
                  from == null ||
                  (row['booking_date'] as String).compareTo(from) >= 0,
            )
            .toList();
        return h.response({'transactions': rows});
      };
      await h.service.syncAccount(1);
      expect((await h.transactions()).first['amount'], 70.00);
      expect((await h.state())['openingMinor'], '30589');
    },
  );

  test(
    'EDGE06 last successful refresh should show refresh date not old booking date',
    () async {
      await h.service.syncAccount(1);
      h.serverTime = DateTime.utc(2026, 12, 7, 12);
      h.localTime = h.serverTime;
      expect((await h.service.syncAccount(1)).completed, isTrue);
      final account = (await h.db.query('bankAccount')).single;
      expect(DateTime.parse(account['lastSyncAt'] as String), h.serverTime);
    },
  );

  test(
    'EDGE07 new empty bank account with zero booked balance should initialize',
    () async {
      h.pages = [[]];
      h.balance = '0.00';
      h.balanceMarker = null;
      expect((await h.service.syncAccount(1)).completed, isTrue);
      expect(await h.total(), 0);
    },
  );

  test(
    'EDGE09 missing fresh balance must not produce unqualified up-to-date UI',
    () async {
      await h.service.syncAccount(1);
      h.serverTime = DateTime.utc(2026, 12, 7, 12);
      h.localTime = h.serverTime;
      h.balanceTime = DateTime.utc(2026, 9, 7);
      h.pages = [[]];
      final result = await h.service.syncAccount(1);
      expect(result.warnings, contains('no_comparable_booked_balance'));
      expect(
        bankSyncMessage(BankSyncSummary([result])),
        isNot('Bank accounts are up to date'),
      );
    },
  );

  test(
    'EDGE10 bank unavailable after long gap must preserve all financial state',
    () async {
      await h.service.syncAccount(1);
      final before = await h.state();
      final rows = await h.transactions();
      h.serverTime = DateTime.utc(2026, 12, 7, 12);
      h.localTime = h.serverTime;
      h.intercept = (request) async =>
          h.response({'error': 'ASPSP_ERROR'}, status: 503);
      expect(
        (await h.service.syncAccount(1)).status,
        BankSyncStatus.retryableFailure,
      );
      expect(await h.state(), before);
      expect(await h.transactions(), rows);
    },
  );
  test(
    'empty account can later import its first credit without rebasing',
    () async {
      h.pages = [[]];
      h.balance = '0.00';
      h.balanceMarker = null;
      expect(
        (await h.service.syncAccount(1)).warnings,
        contains('empty_account_history_unverified'),
      );
      h.pages = [
        [
          bankRecord(
            reference: 'first-credit',
            amount: '20.00',
            indicator: 'CRDT',
          ),
        ],
      ];
      h.balance = '20.00';
      h.balanceMarker = 'first-credit';
      expect((await h.service.syncAccount(1)).completed, isTrue);
      expect((await h.state())['openingMinor'], '0');
      expect(await h.total(), 20);
    },
  );

  test(
    'application authentication failure does not expire bank consent',
    () async {
      h.intercept = (request) async =>
          h.response({'error': 'UNAUTHORIZED'}, status: 401);
      expect((await h.service.syncAccount(1)).completed, isFalse);
      expect((await h.db.query('bankConnection')).single['status'], 'ACTIVE');
    },
  );

  test(
    'late failure from an old session cannot overwrite renewed consent',
    () async {
      final old = await h.repository.readContext(1);
      await h.db.update('bankConnection', {
        'sessionId': 'renewed-session',
      }, where: 'id = 1');
      await h.repository.markConsentFailure(old, BankConnectionStatus.expired);
      expect((await h.db.query('bankConnection')).single['status'], 'ACTIVE');
    },
  );

  test(
    'old cancellation is fetched outside the previous seven day overlap',
    () async {
      await h.service.syncAccount(1);
      h.serverTime = DateTime.utc(2026, 12, 7, 12);
      h.localTime = h.serverTime;
      h.pages = [
        [
          bankRecord(status: 'CNCL'),
          bankRecord(
            reference: 'new',
            date: '2026-12-06',
            amount: '10.00',
            indicator: 'CRDT',
          ),
        ],
      ];
      h.balance = '315.89';
      h.balanceMarker = 'new';
      final result = await h.service.syncAccount(1);
      expect(result.completed, isTrue);
      expect(result.cancelled, 1);
      expect(await h.transactions(), hasLength(1));
      expect(await h.total(), closeTo(315.89, 0.000001));
      expect((await h.state())['openingMinor'], '30589');
    },
  );
  test(
    'balanced history gap still warns when no old checkpoint overlaps',
    () async {
      await h.service.syncAccount(1);
      h.serverTime = DateTime.utc(2026, 12, 7, 12);
      h.localTime = h.serverTime;
      h.pages = [
        [
          bankRecord(
            reference: 'recent',
            date: '2026-12-06',
            amount: '10.00',
            indicator: 'CRDT',
          ),
        ],
      ];
      h.balance = '242.75';
      h.balanceMarker = 'recent';
      final result = await h.service.syncAccount(1);
      expect(result.completed, isTrue);
      expect(result.warnings, contains('history_overlap_missing'));
      expect(bankSyncNeedsAttention(BankSyncSummary([result])), isTrue);
      expect(
        bankSyncMessage(BankSyncSummary([result])),
        contains('Some transactions may be missing'),
      );
      expect((await h.state())['openingMinor'], '30589');
    },
  );
}
