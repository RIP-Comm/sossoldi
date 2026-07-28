import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'enable_banking_config.dart';

const _kAppIdKey = 'eb_app_id';
const _kPrivateKeyPemKey = 'eb_private_key_pem';
const _kConfigJsonKey = 'eb_config_json';

/// Encrypted persistence for the user's BYOC Enable Banking credentials
/// (Keychain on iOS/macOS, Keystore-backed EncryptedSharedPreferences on
/// Android). The private key is never logged nor exposed beyond this store.
class EnableBankingCredentialsStore {
  final FlutterSecureStorage _storage;

  const EnableBankingCredentialsStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  Future<void> saveCredentials({
    required String appId,
    required String privateKeyPem,
    required EnableBankingConfig config,
  }) async {
    await _storage.write(key: _kAppIdKey, value: appId);
    await _storage.write(key: _kPrivateKeyPemKey, value: privateKeyPem);
    await _storage.write(
      key: _kConfigJsonKey,
      value: jsonEncode(config.toJson()),
    );
  }

  Future<EnableBankingConfig?> readConfig() async {
    final appId = await _storage.read(key: _kAppIdKey);
    if (appId == null) {
      return null;
    }
    final configJson = await _storage.read(key: _kConfigJsonKey);
    if (configJson == null) {
      return EnableBankingConfig(appId: appId);
    }
    return EnableBankingConfig.fromJson(
      jsonDecode(configJson) as Map<String, dynamic>,
    );
  }

  Future<String?> readPrivateKey() => _storage.read(key: _kPrivateKeyPemKey);

  Future<bool> hasCredentials() async =>
      await _storage.containsKey(key: _kAppIdKey) &&
      await _storage.containsKey(key: _kPrivateKeyPemKey);

  Future<void> clear() async {
    await _storage.delete(key: _kAppIdKey);
    await _storage.delete(key: _kPrivateKeyPemKey);
    await _storage.delete(key: _kConfigJsonKey);
  }
}
