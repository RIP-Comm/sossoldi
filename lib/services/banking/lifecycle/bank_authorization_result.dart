// dart format width=400

import '../../../model/bank_connection.dart';
import '../banking_connection.dart';

class AuthorizationAttempt {
  final Uri url;
  final DateTime consentValidUntil;

  const AuthorizationAttempt({required this.url, required this.consentValidUntil});
}

class AuthorizationLaunchResult {
  final Uri url;
  final bool opened;

  const AuthorizationLaunchResult({required this.url, required this.opened});
}

class StagedBankConnection {
  final BankConnection connection;
  final BankingConnectionResult? createdConnection;

  const StagedBankConnection({required this.connection, this.createdConnection});
}

class ResumableBankConnection {
  final BankConnection connection;
  final BankingConnection details;

  const ResumableBankConnection({required this.connection, required this.details});
}

typedef AuthorizationUrlLauncher = Future<bool> Function(Uri url);
