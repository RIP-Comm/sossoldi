import 'banking_money.dart';
import 'banking_request_context.dart';

enum BankingTransactionStatus {
  booked,
  pending,
  cancelled,
  rejected,
  held,
  scheduled,
  unknown,
}

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

  BankingTransaction({
    this.entryId,
    this.transactionId,
    required this.status,
    required this.direction,
    required this.amount,
    this.bookingDate,
    this.valueDate,
    this.transactionDate,
    this.creditorName,
    this.debtorName,
    this.note,
    List<String> remittanceInformation = const [],
  }) : remittanceInformation = List.unmodifiable(remittanceInformation);
}

enum BankingHistoryStrategy { standard, longest }

class BankingTransactionQuery {
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final BankingTransactionStatus? status;
  final String? cursor;
  final BankingHistoryStrategy strategy;
  final BankingRequestContext context;
  final bool collectRejectedRecords;

  const BankingTransactionQuery({
    this.dateFrom,
    this.dateTo,
    this.status,
    this.cursor,
    this.strategy = BankingHistoryStrategy.standard,
    this.context = const BankingRequestContext(),
    this.collectRejectedRecords = false,
  });
}

class BankingTransactionsPage {
  final List<BankingTransaction> transactions;
  final String? nextCursor;
  final DateTime? serverTime;
  final int rejectedRecords;

  BankingTransactionsPage({
    required List<BankingTransaction> transactions,
    this.nextCursor,
    this.serverTime,
    this.rejectedRecords = 0,
  }) : transactions = List.unmodifiable(transactions);
}
