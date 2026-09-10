/// Monetary amount as returned by Enable Banking.
///
/// The API decimal string is retained for exact arithmetic; [amount] is a legacy projection.
class EbAmount {
  final num amount;
  final String currency;
  final String? decimalAmount;

  const EbAmount({
    required this.amount,
    required this.currency,
    this.decimalAmount,
  });

  String get exactAmount => decimalAmount ?? amount.toString();

  static EbAmount fromJson(Map<String, dynamic> json) => EbAmount(
    amount: num.parse(json['amount'] as String),
    currency: json['currency'] as String,
    decimalAmount: json['amount'] as String,
  );
}
