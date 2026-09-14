// dart format width=400

enum BankReconciliationFailure { missingStableIdentity, identityCollision, missingLocalAccount, invalidConnectionState }

class BankReconciliationException implements Exception {
  final BankReconciliationFailure failure;
  final String message;

  const BankReconciliationException(this.failure, this.message);

  @override
  String toString() => 'BankReconciliationException($failure, $message)';
}
