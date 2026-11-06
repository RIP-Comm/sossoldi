import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sossoldi/providers/banking_ui_provider.dart';
import '../support/banking_setup_edge_cases.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_credentials_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late EnableBankingKeyMaterial material;
  setUpAll(() {
    material = generateEnableBankingKeyMaterial(1024);
  });
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  final names = uiAuditCases(
    const EnableBankingKeyMaterial(privateKeyPem: '', certificatePem: ''),
  ).keys;
  for (final name in names) {
    testWidgets(name, (tester) async {
      try {
        await uiAuditCases(material)[name]!(tester);
      } finally {
        await const EnableBankingCredentialsStore().flushSetupWrites();
      }
    });
  }
}
