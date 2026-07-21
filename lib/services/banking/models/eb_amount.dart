/// Monetary amount as returned by Enable Banking.
///
/// ⚠️ The API serializes [amount] as a STRING (e.g. `"10.33"`), so it must be
/// parsed with [num.parse].
class EbAmount {
  final num amount;
  final String currency;

  const EbAmount({required this.amount, required this.currency});

  static EbAmount fromJson(Map<String, dynamic> json) => EbAmount(
    amount: num.parse(json['amount'] as String),
    currency: json['currency'] as String,
  );
}
