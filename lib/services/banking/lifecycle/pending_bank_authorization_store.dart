// dart format width=400

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../banking_exception.dart';
import 'pending_bank_authorization.dart';

// Preserve the storage key used by existing pending authorizations.
const _kPendingAuthorizationKey = 'eb_pending_authorization_v1';

abstract class PendingBankAuthorizationStore {
  Future<void> save(PendingBankAuthorization pending);

  Future<PendingBankAuthorization?> read();

  Future<void> clear();
}

class SecurePendingBankAuthorizationStore implements PendingBankAuthorizationStore {
  final FlutterSecureStorage _storage;

  const SecurePendingBankAuthorizationStore({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> save(PendingBankAuthorization pending) => _storage.write(key: _kPendingAuthorizationKey, value: jsonEncode(pending.toJson()));

  @override
  Future<PendingBankAuthorization?> read() async {
    final value = await _storage.read(key: _kPendingAuthorizationKey);
    if (value == null) return null;
    try {
      return PendingBankAuthorization.fromJson(jsonDecode(value) as Map<String, dynamic>);
    } on BankingException {
      rethrow;
    } catch (error) {
      throw const BankingException(providerId: 'application', failure: BankingFailure.invalidResponse);
    }
  }

  @override
  Future<void> clear() => _storage.delete(key: _kPendingAuthorizationKey);
}
