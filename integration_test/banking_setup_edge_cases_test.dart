import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sossoldi/providers/banking_ui_provider.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_credentials_store.dart';
import '../test/support/banking_setup_edge_cases.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late EnableBankingKeyMaterial material;
  setUpAll(() {
    material = generateEnableBankingKeyMaterial(1024);
  });
  setUp(() => const EnableBankingCredentialsStore().clear());
  tearDown(() => const EnableBankingCredentialsStore().clear());
  final names = uiAuditCases(
    const EnableBankingKeyMaterial(privateKeyPem: '', certificatePem: ''),
  ).keys;
  for (final name in names) {
    testWidgets(name, (tester) => uiAuditCases(material)[name]!(tester));
  }
}
