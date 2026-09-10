// dart format width=400

import 'banking_authorization.dart';
import 'banking_connection.dart';
import 'banking_reference.dart';

abstract interface class BankConsentService {
  Future<BankingAuthorization> startAuthorization(BankingAuthorizationRequest request);

  /// Exchanges an authorization code after the application lifecycle has validated and accepted the callback.
  Future<BankingConnectionResult> createConnection(String authorizationCode);
  Future<BankingConnection> getConnection(BankingConnectionReference reference);
  Future<void> revokeConnection(BankingConnectionReference reference);
}
