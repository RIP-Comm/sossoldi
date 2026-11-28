import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sossoldi/services/banking/storage/banking_secure_storage.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_credentials_store.dart';
import 'package:sossoldi/services/banking/lifecycle/pending_bank_authorization.dart';
import 'package:sossoldi/services/banking/lifecycle/pending_bank_authorization_store.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const key = 'eb_pending_authorization_v1';
  const legacy = FlutterSecureStorage();
  const store = SecurePendingBankAuthorizationStore();
  final pending = PendingBankAuthorization(
    providerId: 'enable_banking',
    state: 'synthetic-state',
    authorizationId: 'synthetic-authorization',
    authorizationUrl: 'https://example.test/consent',
    applicationId: 'synthetic-app',
    institutionName: 'Synthetic Bank',
    institutionCountry: 'IT',
    redirectUri: 'sossoldi://eb-callback',
    expiresAt: DateTime.utc(2026, 10, 17, 12),
    consentValidUntil: DateTime.utc(2026, 11, 17),
  );
  tearDown(() async {
    await store.clear();
    await legacy.delete(key: key);
  });
  testWidgets(
    'legacy pending survives credential reads and cold store recreation',
    (tester) async {
      await store.clear();
      await legacy.write(key: key, value: jsonEncode(pending.toJson()));
      expect((await store.read())?.state, pending.state);
      await const EnableBankingCredentialsStore().readConfig();
      expect(
        (await const SecurePendingBankAuthorizationStore().read())?.state,
        pending.state,
      );
      await store.clear();
      expect(await bankingSecureStorage.read(key: key), isNull);
      expect(await legacy.read(key: key), isNull);
    },
  );
  testWidgets(
    'previously migrated pending is recovered and cancellation removes it',
    (tester) async {
      await bankingSecureStorage.write(
        key: key,
        value: jsonEncode(pending.toJson()),
      );
      expect((await store.read())?.authorizationId, pending.authorizationId);
      await store.clear();
      expect(await bankingSecureStorage.read(key: key), isNull);
      expect(await legacy.read(key: key), isNull);
      await store.save(pending);
      await const EnableBankingCredentialsStore().readConfig();
      expect((await store.read())?.state, pending.state);
    },
  );
}
