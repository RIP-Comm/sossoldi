// dart format width=400

import 'banking_money.dart';

enum BankingBalanceKind { closingBooked, interimBooked, available, other }

class BankingBalance {
  final String name;
  final BankingMoney amount;
  final BankingBalanceKind kind;
  final DateTime? referenceDate;
  final DateTime? observedAt;
  final String? lastCommittedEntryId;

  const BankingBalance({required this.name, required this.amount, required this.kind, this.referenceDate, this.observedAt, this.lastCommittedEntryId});
}
