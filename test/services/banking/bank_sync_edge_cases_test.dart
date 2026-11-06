import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../support/bank_sync_harness.dart';
import '../../support/bank_sync_edge_cases.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  for (final entry in syncAuditCases.entries) {
    test(entry.key, () async {
      final h = BankSyncHarness(databaseFactoryFfi);
      await h.open();
      try {
        await entry.value(h);
      } finally {
        await h.close();
      }
    });
  }
}
