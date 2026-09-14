import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_api.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_auth.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_config.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_credentials_service.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_credentials_store.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_exception.dart';
import 'package:sossoldi/services/banking/enable_banking/models/eb_application.dart';

class _FakeApplicationApi extends EnableBankingApi {
  _FakeApplicationApi(this.application, {this.failure})
    : super(
        auth: EnableBankingAuth(),
        store: const EnableBankingCredentialsStore(),
      );

  final EbApplication application;
  final Object? failure;
  int calls = 0;

  @override
  Future<EbApplication> verifyApplicationCredentials({
    required String appId,
    required String privateKeyPem,
  }) async {
    calls++;
    if (failure case final failure?) throw failure;
    return application;
  }
}

const _productionApplication = EbApplication(
  name: 'Sossoldi',
  kid: 'app-123',
  environment: EnableBankingEnvironment.production,
  redirectUrls: [kEbRedirectUri],
  active: true,
  countries: ['GB', 'IT'],
  services: ['AIS'],
);

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test(
    'persists server-derived environment and countries after verification',
    () async {
      final store = const EnableBankingCredentialsStore();
      final api = _FakeApplicationApi(_productionApplication);
      final service = EnableBankingCredentialsService(
        api: api,
        store: store,
        allowSandbox: false,
      );

      final config = await service.saveVerifiedCredentials(
        appId: 'app-123',
        privateKeyPem: 'private-key',
        defaultCountry: 'it',
      );

      expect(api.calls, 1);
      expect(config.environment, EnableBankingEnvironment.production);
      expect(config.defaultCountry, 'IT');
      expect(config.supportedCountries, ['GB', 'IT']);
      expect(config.redirectUrls, [kEbRedirectUri]);
      expect((await store.readCredentials())?.privateKeyPem, 'private-key');
    },
  );

  test(
    'does not replace working credentials when remote verification fails',
    () async {
      final store = const EnableBankingCredentialsStore();
      await store.saveCredentials(
        appId: 'old-app',
        privateKeyPem: 'old-private-key',
        config: const EnableBankingConfig(appId: 'old-app'),
      );
      final service = EnableBankingCredentialsService(
        api: _FakeApplicationApi(
          _productionApplication,
          failure: const EnableBankingException(message: 'invalid credentials'),
        ),
        store: store,
        allowSandbox: false,
      );

      await expectLater(
        () => service.saveVerifiedCredentials(
          appId: 'app-123',
          privateKeyPem: 'bad-private-key',
        ),
        throwsA(isA<EnableBankingException>()),
      );

      final credentials = await store.readCredentials();
      expect(credentials?.config.appId, 'old-app');
      expect(credentials?.privateKeyPem, 'old-private-key');
    },
  );

  test('rejects sandbox credentials when sandbox is disabled', () async {
    const sandbox = EbApplication(
      name: 'Sandbox',
      kid: 'app-123',
      environment: EnableBankingEnvironment.sandbox,
      redirectUrls: [kEbRedirectUri],
      active: true,
      countries: ['IT'],
      services: ['AIS'],
    );
    final service = EnableBankingCredentialsService(
      api: _FakeApplicationApi(sandbox),
      store: const EnableBankingCredentialsStore(),
      allowSandbox: false,
    );

    await expectLater(
      () => service.saveVerifiedCredentials(
        appId: 'app-123',
        privateKeyPem: 'private-key',
      ),
      throwsA(
        isA<EnableBankingException>().having(
          (error) => error.message,
          'message',
          contains('Sandbox'),
        ),
      ),
    );
  });

  test('rejects inactive or non-AIS applications', () async {
    const inactive = EbApplication(
      name: 'Inactive',
      kid: 'app-123',
      environment: EnableBankingEnvironment.production,
      redirectUrls: [kEbRedirectUri],
      active: false,
      countries: ['IT'],
      services: ['AIS'],
    );
    const paymentOnly = EbApplication(
      name: 'PIS only',
      kid: 'app-123',
      environment: EnableBankingEnvironment.production,
      redirectUrls: [kEbRedirectUri],
      active: true,
      countries: ['IT'],
      services: ['PIS'],
    );

    for (final application in [inactive, paymentOnly]) {
      final service = EnableBankingCredentialsService(
        api: _FakeApplicationApi(application),
        store: const EnableBankingCredentialsStore(),
      );
      await expectLater(
        () => service.saveVerifiedCredentials(
          appId: 'app-123',
          privateKeyPem: 'private-key',
        ),
        throwsA(isA<EnableBankingException>()),
      );
    }
  });

  test(
    'rejects an unregistered redirect or unavailable default country',
    () async {
      final redirectService = EnableBankingCredentialsService(
        api: _FakeApplicationApi(_productionApplication),
        store: const EnableBankingCredentialsStore(),
      );
      await expectLater(
        () => redirectService.saveVerifiedCredentials(
          appId: 'app-123',
          privateKeyPem: 'private-key',
          redirectUri: 'https://unregistered.example/callback',
        ),
        throwsA(isA<EnableBankingException>()),
      );

      final countryService = EnableBankingCredentialsService(
        api: _FakeApplicationApi(_productionApplication),
        store: const EnableBankingCredentialsStore(),
      );
      await expectLater(
        () => countryService.saveVerifiedCredentials(
          appId: 'app-123',
          privateKeyPem: 'private-key',
          defaultCountry: 'FR',
        ),
        throwsA(isA<EnableBankingException>()),
      );
    },
  );

  test('rejects malformed or lookalike custom callbacks', () async {
    final service = EnableBankingCredentialsService(
      api: _FakeApplicationApi(
        const EbApplication(
          name: 'Sossoldi',
          kid: 'app-123',
          environment: EnableBankingEnvironment.production,
          redirectUrls: ['sossoldi://eb-callback/other'],
          active: true,
          countries: ['IT'],
          services: ['AIS'],
        ),
      ),
      store: const EnableBankingCredentialsStore(),
    );

    await expectLater(
      () => service.saveVerifiedCredentials(
        appId: 'app-123',
        privateKeyPem: 'private-key',
        redirectUri: 'sossoldi://eb-callback/other',
      ),
      throwsA(isA<EnableBankingException>()),
    );
  });

  test(
    'accepts only the versioned HTTPS relay when server-registered',
    () async {
      const relayApplication = EbApplication(
        name: 'Sossoldi',
        kid: 'app-123',
        environment: EnableBankingEnvironment.production,
        redirectUrls: [kEbRelayRedirectUri],
        active: true,
        countries: ['IT'],
        services: ['AIS'],
      );
      final service = EnableBankingCredentialsService(
        api: _FakeApplicationApi(relayApplication),
        store: const EnableBankingCredentialsStore(),
      );

      final config = await service.saveVerifiedCredentials(
        appId: 'app-123',
        privateKeyPem: 'private-key',
        redirectUri: kEbRelayRedirectUri,
      );

      expect(config.redirectUri, kEbRelayRedirectUri);
    },
  );
}
