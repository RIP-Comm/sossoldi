import 'eb_amount.dart';

/// An account balance as returned by `GET /accounts/{uid}/balances`.
class EbBalance {
  final String name;
  final EbAmount balanceAmount;
  final String? balanceType;

  const EbBalance({
    required this.name,
    required this.balanceAmount,
    this.balanceType,
  });

  static EbBalance fromJson(Map<String, dynamic> json) => EbBalance(
    name: json['name'] as String,
    balanceAmount: EbAmount.fromJson(
      json['balance_amount'] as Map<String, dynamic>,
    ),
    balanceType: json['balance_type'] as String?,
  );
}
