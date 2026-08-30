import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import 'enable_banking_credentials_store.dart';

const _kIssuer = 'enablebanking.com';
const _kAudience = 'api.enablebanking.com';
const _kMaxTtl = Duration(hours: 24);
const _kRefreshMargin = Duration(minutes: 5);

/// Thrown when the Enable Banking JWT cannot be built: an unparsable private
/// key PEM or missing BYOC credentials.
class EnableBankingAuthException implements Exception {
  final String message;

  const EnableBankingAuthException(this.message);

  @override
  String toString() => 'EnableBankingAuthException: $message';
}

/// Signs Enable Banking API requests with an RS256 JWT built from the
/// user's BYOC `app_id` + private key, on-device. The signed token is only
/// ever cached in memory (never persisted) and reused until close to expiry.
class EnableBankingAuth {
  final Duration _tokenTtl;
  final Duration _refreshMargin;
  final DateTime Function() _now;

  String? _cachedToken;
  DateTime? _cachedExpiry;

  void clearCache() {
    _cachedToken = null;
    _cachedExpiry = null;
  }

  /// [tokenTtl] and [refreshMargin] default to the production values; they
  /// (and [now]) are only overridden in tests to make cache expiry
  /// deterministic without real waiting.
  EnableBankingAuth({
    Duration tokenTtl = const Duration(hours: 1),
    Duration refreshMargin = _kRefreshMargin,
    DateTime Function() now = DateTime.now,
  }) : _tokenTtl = tokenTtl,
       _refreshMargin = refreshMargin,
       _now = now;

  /// Builds and signs a new RS256 JWT for the Enable Banking API.
  String buildJwt({
    required String appId,
    required String privateKeyPem,
    Duration ttl = const Duration(hours: 1),
  }) {
    assert(ttl <= _kMaxTtl, 'ttl must not exceed 24h');

    final RSAPrivateKey key;
    try {
      key = RSAPrivateKey(privateKeyPem);
    } catch (_) {
      throw const EnableBankingAuthException('Invalid private key');
    }

    final jwt = JWT(
      {'iss': _kIssuer, 'aud': _kAudience},
      header: {'kid': appId},
    );

    try {
      return jwt.sign(key, algorithm: JWTAlgorithm.RS256, expiresIn: ttl);
    } catch (e) {
      throw EnableBankingAuthException('Could not sign the request: $e');
    }
  }

  /// Returns a cached token while it still has more than [_refreshMargin]
  /// left before expiry, otherwise signs and caches a fresh one.
  Future<String> getValidToken(EnableBankingCredentialsStore store) async {
    final now = _now();
    final cachedExpiry = _cachedExpiry;
    if (_cachedToken != null &&
        cachedExpiry != null &&
        cachedExpiry.isAfter(now.add(_refreshMargin))) {
      return _cachedToken!;
    }

    final credentials = await store.readCredentials();
    if (credentials == null) {
      throw const EnableBankingAuthException(
        'Enable Banking credentials are not configured',
      );
    }

    final token = buildJwt(
      appId: credentials.config.appId,
      privateKeyPem: credentials.privateKeyPem,
      ttl: _tokenTtl,
    );

    _cachedToken = token;
    _cachedExpiry = now.add(_tokenTtl);
    return token;
  }
}
