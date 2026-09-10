// dart format width=400

class BankingConnectionReference {
  final String providerId;
  final String remoteId;

  const BankingConnectionReference({required this.providerId, required this.remoteId});

  @override
  bool operator ==(Object other) => other is BankingConnectionReference && providerId == other.providerId && remoteId == other.remoteId;

  @override
  int get hashCode => Object.hash(providerId, remoteId);
}

class BankingAccountReference {
  final String providerId;
  final String remoteId;
  final Set<String> identityKeys;

  BankingAccountReference({required this.providerId, required this.remoteId, Iterable<String> identityKeys = const []}) : identityKeys = Set.unmodifiable(identityKeys);

  @override
  bool operator ==(Object other) => other is BankingAccountReference && providerId == other.providerId && remoteId == other.remoteId;

  @override
  int get hashCode => Object.hash(providerId, remoteId);
}
