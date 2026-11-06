import 'eb_transaction.dart';

/// Paginated envelope from `GET /accounts/{uid}/transactions`.
///
/// [continuationKey] is echoed back on the next request to fetch more pages.
class EbTransactionsPage {
  final List<EbTransaction> transactions;
  final String? continuationKey;
  final int rejectedRecords;
  final DateTime? serverTime;

  const EbTransactionsPage({
    this.transactions = const [],
    this.continuationKey,
    this.rejectedRecords = 0,
    this.serverTime,
  });

  static EbTransactionsPage fromJson(
    Map<String, dynamic> json, {
    bool collectRejectedRecords = false,
  }) {
    final raw = json['transactions'];
    if (raw is! List) throw const FormatException('Missing transaction list');
    final transactions = <EbTransaction>[];
    var rejected = 0;
    for (final record in raw) {
      try {
        transactions.add(
          EbTransaction.fromJson(record as Map<String, dynamic>),
        );
      } on FormatException {
        if (!collectRejectedRecords) rethrow;
        rejected++;
      } on TypeError {
        if (!collectRejectedRecords) rethrow;
        rejected++;
      }
    }
    final key = json['continuation_key'] as String?;
    return EbTransactionsPage(
      transactions: transactions,
      continuationKey: key == null || key.trim().isEmpty ? null : key,
      rejectedRecords: rejected,
      serverTime: json['_server_date'] == null
          ? null
          : DateTime.parse(json['_server_date'] as String),
    );
  }
}
