import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../storage/banking_secure_storage.dart';
import 'enable_banking_config.dart';
import 'enable_banking_setup_draft.dart';

export 'enable_banking_setup_draft.dart';
import 'enable_banking_exception.dart';

const _kDraftPrivateKey = 'eb_draft_private_key';
const _kSetupDraftKey = 'eb_setup_draft_v1';

const _kCredentialSetKey = 'eb_credentials_v1';
const _kLegacyAppIdKey = 'eb_app_id';
const _kLegacyPrivateKeyPemKey = 'eb_private_key_pem';
const _kLegacyConfigJsonKey = 'eb_config_json';

// Editor revisions reject stale submissions; cancellation also invalidates queued mutations.
class _SetupWrites {
  int revision = 0;
  int invalidation = 0;
  Future<void>? pending;

  Future<bool> run(int? expected, Future<void> Function() operation) {
    if (expected != null && expected != revision) return Future.value(false);
    final generation = invalidation;
    final result = (pending ?? Future<void>.value()).then((_) async {
      if (generation != invalidation) return false;
      await operation();
      return true;
    });
    final tail = result.then<void>((_) {}).catchError((Object _) {});
    pending = tail;
    unawaited(
      tail.then((_) {
        if (identical(pending, tail)) pending = null;
      }),
    );
    return result;
  }
}

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
/// Configuration and private key are stored in one versioned value so readers cannot observe a torn app-id/key pair after an interrupted write.
class EnableBankingCredentialsStore {
  final FlutterSecureStorage _storage;
  static final _queues = Expando<_SetupWrites>();
  _SetupWrites get _writes => _queues[_storage] ??= _SetupWrites();

  int beginSetupEditing() => ++_writes.revision;
  int get setupRevision => _writes.revision;
  int get setupInvalidation => _writes.invalidation;
  Future<void> flushSetupWrites() => _writes.pending ?? Future<void>.value();

  Future<bool> saveSetupDraftIfCurrent(
    EnableBankingSetupDraft draft,
    int revision,
  ) async {
    final saved = await _writes.run(revision, () => saveSetupDraft(draft));
    return saved && revision == _writes.revision;
  }

  Future<void> clearCredentialsIfCurrent(int revision) async {
    await _writes.run(revision, () async {
      await _storage.delete(key: _kCredentialSetKey);
      await _clearLegacyKeys();
    });
  }

  Future<void> clearVerifiedSetupDraft() async {
    await _writes.run(null, () async {
      final credentials = await readCredentials();
      final draft = await readSetupDraft();
      if (credentials != null &&
          draft != null &&
          draft.appId == credentials.config.appId &&
          draft.redirectUri == credentials.config.redirectUri &&
          draft.privateKeyPem == credentials.privateKeyPem) {
        await _deleteDraft();
      }
    });
  }

  const EnableBankingCredentialsStore({FlutterSecureStorage? storage})
    : _storage = storage ?? bankingSecureStorage;

  Future<void> saveCredentials({
    required String appId,
    required String privateKeyPem,
    required EnableBankingConfig config,
    int? expectedSetupRevision,
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
    final saved = await _writes.run(expectedSetupRevision, () async {
      await _storage.write(key: _kCredentialSetKey, value: encoded);
      await _clearLegacyKeys();
    });
    if (!saved) {
      throw const EnableBankingException(
        message: 'Setup changed before credentials could be saved',
      );
    }
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

  Future<void> saveDraftPrivateKey(String pem) => saveSetupDraft(
    EnableBankingSetupDraft(
      step: 3,
      existingCredentials: true,
      privateKeyPem: pem,
    ),
  );

  Future<String?> readDraftPrivateKey() async =>
      (await readSetupDraft())?.privateKeyPem;

  Future<void> saveSetupDraft(EnableBankingSetupDraft draft) =>
      _storage.write(key: _kSetupDraftKey, value: jsonEncode(draft.toJson()));

  Future<EnableBankingSetupDraft?> readSetupDraft() async {
    final encoded = await _storage.read(key: _kSetupDraftKey);
    if (encoded != null) {
      try {
        return EnableBankingSetupDraft.fromJson(
          jsonDecode(encoded) as Map<String, dynamic>,
        );
      } catch (_) {
        throw const FormatException('Could not read the saved bank setup');
      }
    }
    final legacyKey = await _storage.read(key: _kDraftPrivateKey);
    return legacyKey == null
        ? null
        : EnableBankingSetupDraft(
            step: 3,
            existingCredentials: true,
            privateKeyPem: legacyKey,
          );
  }

  Future<void> _deleteDraft() async {
    await _storage.delete(key: _kSetupDraftKey);
    await _storage.delete(key: _kDraftPrivateKey);
  }

  Future<void> clearDraftPrivateKey() async {
    ++_writes.revision;
    ++_writes.invalidation;
    await _writes.run(null, _deleteDraft);
  }

  Future<void> clear() async {
    ++_writes.revision;
    ++_writes.invalidation;
    await _writes.run(null, () async {
      await _deleteDraft();
      await _storage.delete(key: _kCredentialSetKey);
      await _clearLegacyKeys();
    });
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
