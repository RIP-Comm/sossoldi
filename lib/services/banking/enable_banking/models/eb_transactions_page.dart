import 'eb_transaction.dart';

/// Paginated envelope from `GET /accounts/{uid}/transactions`.
///
/// [continuationKey] is echoed back on the next request to fetch more pages.
class EbTransactionsPage {
  final List<EbTransaction> transactions;
  final String? continuationKey;

  const EbTransactionsPage({
    this.transactions = const [],
    this.continuationKey,
  });

  static EbTransactionsPage fromJson(Map<String, dynamic> json) =>
      EbTransactionsPage(
        transactions: (json['transactions'] as List)
            .map((e) => EbTransaction.fromJson(e as Map<String, dynamic>))
            .toList(),
        continuationKey: json['continuation_key'] as String?,
      );
}
