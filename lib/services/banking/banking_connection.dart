// dart format width=400

import 'bank_institution.dart';
import 'banking_account.dart';
import 'banking_reference.dart';

enum BankingConnectionStatus { pending, active, cancelled, closed, expired, invalid, revoked }

class BankingConnection {
  final BankingConnectionReference reference;
  final BankInstitution institution;
  final DateTime validUntil;
  final BankingConnectionStatus status;
  final List<BankingAccountReference> accounts;
  final DateTime? createdAt;
  final DateTime? authorizedAt;
  final DateTime? closedAt;

  BankingConnection({required this.reference, required this.institution, required this.validUntil, required this.status, required List<BankingAccountReference> accounts, this.createdAt, this.authorizedAt, this.closedAt}) : accounts = List.unmodifiable(accounts);

  bool isExpiredAt(DateTime now) => !now.isBefore(validUntil);
}

class BankingConnectionResult {
  final BankingConnection connection;
  final List<BankingAccount> accounts;

  BankingConnectionResult({required this.connection, required List<BankingAccount> accounts}) : accounts = List.unmodifiable(accounts);
}
