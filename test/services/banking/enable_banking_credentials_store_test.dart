import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_config.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_credentials_store.dart';

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('EnableBankingCredentialsStore', () {
    test('hasCredentials is false before anything is saved', () async {
      final store = const EnableBankingCredentialsStore();
      expect(await store.hasCredentials(), isFalse);
      expect(await store.readConfig(), isNull);
      expect(await store.readPrivateKey(), isNull);
    });

    test('saves and reads back appId, private key and config', () async {
      final store = const EnableBankingCredentialsStore();
      const config = EnableBankingConfig(
        appId: 'app-123',
        environment: EnableBankingEnvironment.sandbox,
        defaultCountry: 'IT',
      );

      await store.saveCredentials(
        appId: 'app-123',
        privateKeyPem:
            '-----BEGIN PRIVATE KEY-----\nabc\n-----END PRIVATE KEY-----',
        config: config,
      );

      expect(await store.hasCredentials(), isTrue);
      expect(
        await store.readPrivateKey(),
        '-----BEGIN PRIVATE KEY-----\nabc\n-----END PRIVATE KEY-----',
      );

      final readConfig = await store.readConfig();
      expect(readConfig, isNotNull);
      expect(readConfig!.appId, 'app-123');
      expect(readConfig.environment, EnableBankingEnvironment.sandbox);
      expect(readConfig.defaultCountry, 'IT');
      expect(readConfig.supportedCountries, isEmpty);
      expect(readConfig.redirectUri, kEbRedirectUri);
      expect(readConfig.baseUrl, 'https://api.enablebanking.com');
    });

    test('rejects mismatched app IDs before changing storage', () async {
      final store = const EnableBankingCredentialsStore();

      await expectLater(
        () => store.saveCredentials(
          appId: 'app-123',
          privateKeyPem: 'pem',
          config: const EnableBankingConfig(appId: 'different-app'),
        ),
        throwsA(isA<Exception>()),
      );

      expect(await store.hasCredentials(), isFalse);
    });

    test('treats a partial legacy credential pair as invalid', () async {
      FlutterSecureStorage.setMockInitialValues({'eb_app_id': 'app-123'});
      final store = const EnableBankingCredentialsStore();

      expect(await store.hasCredentials(), isFalse);
      await expectLater(store.readCredentials, throwsA(isA<Exception>()));
    });

    test('reads a complete legacy pair without mixing app IDs', () async {
      FlutterSecureStorage.setMockInitialValues({
        'eb_app_id': 'legacy-app',
        'eb_private_key_pem': 'legacy-key',
        'eb_config_json': '{"app_id":"legacy-app"}',
      });
      final store = const EnableBankingCredentialsStore();

      final credentials = await store.readCredentials();

      expect(credentials?.config.appId, 'legacy-app');
      expect(credentials?.privateKeyPem, 'legacy-key');
    });

    test('clear removes appId, private key and config', () async {
      final store = const EnableBankingCredentialsStore();
      await store.saveCredentials(
        appId: 'app-123',
        privateKeyPem: 'pem',
        config: const EnableBankingConfig(appId: 'app-123'),
      );

      await store.clear();

      expect(await store.hasCredentials(), isFalse);
      expect(await store.readConfig(), isNull);
      expect(await store.readPrivateKey(), isNull);
    });
  });
}
