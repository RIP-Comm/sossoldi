import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'enable_banking_config.dart';
import 'enable_banking_exception.dart';

const _kCredentialSetKey = 'eb_credentials_v1';
const _kLegacyAppIdKey = 'eb_app_id';
const _kLegacyPrivateKeyPemKey = 'eb_private_key_pem';
const _kLegacyConfigJsonKey = 'eb_config_json';

class EnableBankingCredentials {
  final EnableBankingConfig config;
  final String privateKeyPem;

  const EnableBankingCredentials({
    required this.config,
    required this.privateKeyPem,
  });
}

/// Encrypted persistence for a verified BYOC credential set.
///
/// Configuration and private key are stored in one versioned value so readers
/// cannot observe a torn app-id/key pair after an interrupted write.
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
    if (config.appId != appId) {
      throw const EnableBankingException(
        message: 'Credential app ID does not match its configuration',
      );
    }
    final encoded = jsonEncode({
      'version': 1,
      'config': config.toJson(),
      'private_key_pem': privateKeyPem,
    });
    await _storage.write(key: _kCredentialSetKey, value: encoded);
    await _clearLegacyKeys();
  }

  Future<EnableBankingCredentials?> readCredentials() async {
    final encoded = await _storage.read(key: _kCredentialSetKey);
    if (encoded == null) return _readLegacyCredentials();

    try {
      final json = jsonDecode(encoded) as Map<String, dynamic>;
      if (json['version'] != 1) {
        throw const FormatException('unsupported credential version');
      }
      final config = EnableBankingConfig.fromJson(
        json['config'] as Map<String, dynamic>,
      );
      final privateKeyPem = json['private_key_pem'] as String;
      if (privateKeyPem.trim().isEmpty) {
        throw const FormatException('empty private key');
      }
      return EnableBankingCredentials(
        config: config,
        privateKeyPem: privateKeyPem,
      );
    } catch (error) {
      throw EnableBankingException(
        message: 'Malformed Enable Banking credential set: $error',
      );
    }
  }

  Future<EnableBankingConfig?> readConfig() async =>
      (await readCredentials())?.config;

  Future<String?> readPrivateKey() async =>
      (await readCredentials())?.privateKeyPem;

  Future<bool> hasCredentials() async {
    try {
      return await readCredentials() != null;
    } on EnableBankingException {
      return false;
    }
  }

  Future<void> clear() async {
    await _storage.delete(key: _kCredentialSetKey);
    await _clearLegacyKeys();
  }

  Future<EnableBankingCredentials?> _readLegacyCredentials() async {
    final appId = await _storage.read(key: _kLegacyAppIdKey);
    final privateKeyPem = await _storage.read(key: _kLegacyPrivateKeyPemKey);
    if (appId == null && privateKeyPem == null) return null;
    if (appId == null || privateKeyPem == null) {
      throw const EnableBankingException(
        message: 'Incomplete legacy Enable Banking credentials',
      );
    }

    final configJson = await _storage.read(key: _kLegacyConfigJsonKey);
    final config = configJson == null
        ? EnableBankingConfig(appId: appId)
        : EnableBankingConfig.fromJson(
            jsonDecode(configJson) as Map<String, dynamic>,
          );
    if (config.appId != appId) {
      throw const EnableBankingException(
        message: 'Legacy credential app IDs do not match',
      );
    }
    return EnableBankingCredentials(
      config: config,
      privateKeyPem: privateKeyPem,
    );
  }

  Future<void> _clearLegacyKeys() async {
    await _storage.delete(key: _kLegacyAppIdKey);
    await _storage.delete(key: _kLegacyPrivateKeyPemKey);
    await _storage.delete(key: _kLegacyConfigJsonKey);
  }
}
