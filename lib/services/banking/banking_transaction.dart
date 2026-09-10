// dart format width=400

import 'banking_money.dart';

enum BankingTransactionStatus { booked, pending, unknown }

enum BankingDirection { credit, debit, unknown }

class BankingTransaction {
  final String? entryId;
  final String? transactionId;
  final BankingTransactionStatus status;
  final BankingDirection direction;
  final BankingMoney amount;
  final DateTime? bookingDate;
  final DateTime? valueDate;
  final DateTime? transactionDate;
  final String? creditorName;
  final String? debtorName;
  final String? note;
  final List<String> remittanceInformation;

  BankingTransaction({this.entryId, this.transactionId, required this.status, required this.direction, required this.amount, this.bookingDate, this.valueDate, this.transactionDate, this.creditorName, this.debtorName, this.note, List<String> remittanceInformation = const []}) : remittanceInformation = List.unmodifiable(remittanceInformation);
}

class BankingTransactionQuery {
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final BankingTransactionStatus? status;
  final String? cursor;

  const BankingTransactionQuery({this.dateFrom, this.dateTo, this.status, this.cursor});
}

class BankingTransactionsPage {
  final List<BankingTransaction> transactions;
  final String? nextCursor;

  BankingTransactionsPage({required List<BankingTransaction> transactions, this.nextCursor}) : transactions = List.unmodifiable(transactions);
}
