import 'eb_amount.dart';

DateTime? _parseDate(Object? value) {
  if (value == null) return null;
  if (value is! String || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
    throw const FormatException('Invalid bank transaction date');
  }
  final date = DateTime.tryParse(value);
  if (date == null || date.toIso8601String().substring(0, 10) != value) {
    throw const FormatException('Invalid bank transaction date');
  }
  return date;
}

/// A single transaction as returned by `GET /accounts/{uid}/transactions`.
class EbTransaction {
  final String? entryReference;
  final String? transactionId;
  final String status;
  final DateTime? bookingDate;
  final DateTime? valueDate;
  final DateTime? transactionDate;
  final EbAmount transactionAmount;
  final String creditDebitIndicator;
  final String? creditorName;
  final String? debtorName;
  final List<String> remittanceInformation;
  final String? note;

  const EbTransaction({
    this.entryReference,
    this.transactionId,
    required this.status,
    this.bookingDate,
    this.valueDate,
    this.transactionDate,
    required this.transactionAmount,
    required this.creditDebitIndicator,
    this.creditorName,
    this.debtorName,
    this.remittanceInformation = const [],
    this.note,
  });

  static EbTransaction fromJson(Map<String, dynamic> json) => EbTransaction(
    entryReference: json['entry_reference'] as String?,
    transactionId: json['transaction_id'] as String?,
    status: json['status'] as String,
    bookingDate: _parseDate(json['booking_date']),
    valueDate: _parseDate(json['value_date']),
    transactionDate: _parseDate(json['transaction_date']),
    transactionAmount: EbAmount.fromJson(
      json['transaction_amount'] as Map<String, dynamic>,
    ),
    creditDebitIndicator: json['credit_debit_indicator'] as String,
    creditorName:
        (json['creditor'] as Map<String, dynamic>?)?['name'] as String?,
    debtorName: (json['debtor'] as Map<String, dynamic>?)?['name'] as String?,
    remittanceInformation:
        ((json['remittance_information'] as List?) ?? const [])
            .map((e) => e as String)
            .toList(),
    note: json['note'] as String?,
  );

  /// Signed amount: positive for credits (`CRDT`), negative otherwise.
  ///
  /// Anything that is not `CRDT` (e.g. `DBIT`/`DBDT`) is treated as an outflow.
  num get signedAmount => creditDebitIndicator == 'CRDT'
      ? transactionAmount.amount
      : -transactionAmount.amount;

  /// Stable dedup key: `entry_reference` when present, else `transaction_id`.
  String? get stableId => entryReference ?? transactionId;

  bool get isBooked => status == 'BOOK';
}
