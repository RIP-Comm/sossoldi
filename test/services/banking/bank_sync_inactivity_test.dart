import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sossoldi/services/banking/sync/bank_sync_result.dart';
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
    expect(await h.state(), before);
    expect(await h.transactions(), hasLength(1));
  });

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
}
