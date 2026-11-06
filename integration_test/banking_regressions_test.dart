import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'pending_authorization_storage_test.dart' as storage;
import 'bank_sync_edge_cases_test.dart' as sync;
import 'banking_setup_edge_cases_test.dart' as setup;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('storage', storage.main);
  group('sync', sync.main);
  group('setup', setup.main);
}
