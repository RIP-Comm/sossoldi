import 'eb_amount.dart';

DateTime? _balanceDate(Object? raw, {bool timestamp = false}) {
  if (raw == null) return null;
  if (raw is! String) throw const FormatException('Invalid balance date');
  if (!timestamp && !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(raw)) {
    throw const FormatException('Invalid balance reference date');
  }
  if (timestamp &&
      !RegExp(
        r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:\d{2})$',
      ).hasMatch(raw)) {
    throw const FormatException('Balance timestamp requires a timezone');
  }
  final calendar = DateTime.tryParse(raw.substring(0, 10));
  if (calendar == null ||
      calendar.toIso8601String().substring(0, 10) != raw.substring(0, 10)) {
    throw const FormatException('Invalid balance calendar date');
  }
  if (timestamp &&
      (int.parse(raw.substring(11, 13)) > 23 ||
          int.parse(raw.substring(14, 16)) > 59 ||
          int.parse(raw.substring(17, 19)) > 59)) {
    throw const FormatException('Invalid balance time');
  }
  final date = DateTime.tryParse(raw);
  if (date == null ||
      (!timestamp && date.toIso8601String().substring(0, 10) != raw)) {
    throw const FormatException('Invalid balance date');
  }
  return timestamp
      ? date.toUtc()
      : DateTime.utc(date.year, date.month, date.day);
}

/// An account balance as returned by `GET /accounts/{uid}/balances`.
class EbBalance {
  final String name;
  final EbAmount balanceAmount;
  final String? balanceType;
  final DateTime? referenceDate;
  final DateTime? lastChangeDateTime;
  final String? lastCommittedTransaction;

  const EbBalance({
    required this.name,
    required this.balanceAmount,
    this.balanceType,
    this.referenceDate,
    this.lastChangeDateTime,
    this.lastCommittedTransaction,
  });

  static EbBalance fromJson(Map<String, dynamic> json) => EbBalance(
    name: json['name'] as String,
    balanceAmount: EbAmount.fromJson(
      json['balance_amount'] as Map<String, dynamic>,
    ),
    balanceType: json['balance_type'] as String?,
    referenceDate: _balanceDate(json['reference_date']),
    lastChangeDateTime: _balanceDate(
      json['last_change_date_time'],
      timestamp: true,
    ),
    lastCommittedTransaction: json['last_committed_transaction'] as String?,
  );
}
