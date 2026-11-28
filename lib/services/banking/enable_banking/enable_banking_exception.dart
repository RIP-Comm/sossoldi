enum EnableBankingFailureKind {
  applicationAuthentication,
  sessionExpired,
  sessionRevoked,
  sessionClosed,
  notFound,
  rateLimited,
  timeout,
  server,
  invalidRequest,
  invalidResponse,
  network,
  unknown,
}

class EnableBankingException implements Exception {
  final int? statusCode;
  final String? error;
  final String? message;
  final EnableBankingFailureKind kind;
  final Duration? retryAfter;

  const EnableBankingException({
    this.statusCode,
    this.error,
    this.message,
    this.kind = EnableBankingFailureKind.unknown,
    this.retryAfter,
  });

  bool get isRetryable => switch (kind) {
    EnableBankingFailureKind.rateLimited ||
    EnableBankingFailureKind.timeout ||
    EnableBankingFailureKind.server ||
    EnableBankingFailureKind.network => true,
    _ => false,
  };

  bool get isUnauthorized => statusCode == 401;

  bool get confirmsMissingSession => switch (kind) {
    EnableBankingFailureKind.sessionRevoked ||
    EnableBankingFailureKind.sessionClosed ||
    EnableBankingFailureKind.notFound => true,
    _ => false,
  };

  @override
  String toString() =>
      'EnableBankingException(statusCode: $statusCode, error: $error, '
      'kind: $kind, message: $message)';
}
