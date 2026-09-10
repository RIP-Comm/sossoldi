import 'package:flutter/foundation.dart';

import 'enable_banking_api.dart';
import 'enable_banking_config.dart';
import 'enable_banking_credentials_store.dart';
import 'enable_banking_exception.dart';

/// Validates a candidate credential pair remotely before replacing the
/// previously working credential set.
class EnableBankingCredentialsService {
  final EnableBankingApi _api;
  final EnableBankingCredentialsStore _store;
  final bool _allowSandbox;

  const EnableBankingCredentialsService({
    required EnableBankingApi api,
    required EnableBankingCredentialsStore store,
    bool allowSandbox = !kReleaseMode,
  }) : _api = api,
       _store = store,
       _allowSandbox = allowSandbox;

  Future<EnableBankingConfig> saveVerifiedCredentials({
    required String appId,
    required String privateKeyPem,
    String redirectUri = kEbRedirectUri,
    String? defaultCountry,
  }) async {
    final application = await _api.verifyApplicationCredentials(
      appId: appId,
      privateKeyPem: privateKeyPem,
    );

    if (!application.active) {
      throw const EnableBankingException(
        message: 'The Enable Banking application is not active',
      );
    }
    if (!application.services.contains('AIS')) {
      throw const EnableBankingException(
        message: 'The Enable Banking application does not provide AIS',
      );
    }
    if (!_allowSandbox &&
        application.environment == EnableBankingEnvironment.sandbox) {
      throw const EnableBankingException(
        message: 'Sandbox credentials are not allowed in release builds',
      );
    }
    if (!application.redirectUrls.contains(redirectUri)) {
      throw const EnableBankingException(
        message: 'Redirect URI is not registered for this application',
      );
    }

    final normalizedDefaultCountry = defaultCountry?.toUpperCase();
    if (normalizedDefaultCountry != null &&
        !application.countries.contains(normalizedDefaultCountry)) {
      throw const EnableBankingException(
        message: 'Default country is not enabled for this application',
      );
    }

    final config = EnableBankingConfig(
      appId: appId,
      environment: application.environment,
      redirectUri: redirectUri,
      defaultCountry: normalizedDefaultCountry,
      supportedCountries: application.countries,
      redirectUrls: application.redirectUrls,
    );
    await _store.saveCredentials(
      appId: appId,
      privateKeyPem: privateKeyPem,
      config: config,
    );
    return config;
  }
}
