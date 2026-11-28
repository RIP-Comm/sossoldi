import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite/sqflite.dart';
import '../test/support/bank_sync_harness.dart';
import '../test/support/bank_sync_edge_cases.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  for (final entry in syncAuditCases.entries) {
    testWidgets(entry.key, (tester) async {
      final h = BankSyncHarness(databaseFactory);
      await h.open();
      try {
        await entry.value(h);
      } finally {
        await h.close();
      }
    });
  }
}
