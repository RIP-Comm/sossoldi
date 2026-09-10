/// Error surfaced by the Enable Banking REST API (HTTP status >= 400).
///
/// [statusCode] lets callers detect an expired/revoked consent (401) to
/// mark the connection as `EXPIRED` (see Step 14 of the implementation
/// plan) instead of failing the whole sync.
class EnableBankingException implements Exception {
  final int? statusCode;
  final String? error;
  final String? message;

  const EnableBankingException({this.statusCode, this.error, this.message});

  /// True when the consent/session is no longer valid.
  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() =>
      'EnableBankingException(statusCode: $statusCode, error: $error, '
      'message: $message)';
}
