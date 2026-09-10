// dart format width=400

enum BankingFailure { authentication, forbidden, rateLimited, unavailable, invalidResponse, rejected }

class BankingException implements Exception {
  final String providerId;
  final BankingFailure failure;

  const BankingException({required this.providerId, required this.failure});

  @override
  String toString() => 'BankingException($providerId, ${failure.name})';
}
