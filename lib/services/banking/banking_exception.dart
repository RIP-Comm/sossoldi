// dart format width=400

enum BankingFailure { authentication, forbidden, rateLimited, unavailable, invalidResponse, rejected, connectionExpired, connectionRevoked, connectionClosed, notFound }

class BankingException implements Exception {
  final String providerId;
  final BankingFailure failure;

  const BankingException({required this.providerId, required this.failure});

  bool get isRetryable => failure == BankingFailure.rateLimited || failure == BankingFailure.unavailable;

  bool get confirmsMissingConnection => {BankingFailure.connectionRevoked, BankingFailure.connectionClosed, BankingFailure.notFound}.contains(failure);

  @override
  String toString() => 'BankingException($providerId, ${failure.name})';
}
