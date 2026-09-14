// dart format width=400

class BankAuthorizationContext {
  final String providerId;
  final String applicationId;
  final String redirectUri;

  const BankAuthorizationContext({required this.providerId, required this.applicationId, required this.redirectUri});
}

typedef BankAuthorizationContextReader = Future<BankAuthorizationContext> Function();
