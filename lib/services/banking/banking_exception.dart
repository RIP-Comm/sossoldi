enum BankingFailure {
  authentication,
  forbidden,
  rateLimited,
  unavailable,
  invalidResponse,
  rejected,
  connectionExpired,
  connectionRevoked,
  connectionClosed,
  notFound,
  unsupportedHistoryPeriod,
}

class BankingException implements Exception {
  final String providerId;
  final BankingFailure failure;
  final Duration? retryAfter;

  const BankingException({
    required this.providerId,
    required this.failure,
    this.retryAfter,
  });

  bool get isRetryable =>
      failure == BankingFailure.rateLimited ||
      failure == BankingFailure.unavailable;

  bool get confirmsMissingConnection => {
    BankingFailure.connectionRevoked,
    BankingFailure.connectionClosed,
    BankingFailure.notFound,
  }.contains(failure);

  @override
  String toString() => 'BankingException($providerId, ${failure.name})';
}
