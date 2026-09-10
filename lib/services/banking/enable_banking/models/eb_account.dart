/// A bank account (AccountResource) as returned inside a session or accounts
/// list.
///
/// The IBAN is nested under `account_id.iban`.
class EbAccount {
  final String uid;
  final String? iban;
  final String? name;
  final String? details;
  final String? currency;
  final String? product;
  final String? cashAccountType;
  final String? usage;
  final String? identificationHash;
  final List<String> identificationHashes;

  const EbAccount({
    required this.uid,
    this.iban,
    this.name,
    this.details,
    this.currency,
    this.product,
    this.cashAccountType,
    this.usage,
    this.identificationHash,
    this.identificationHashes = const [],
  });

  static EbAccount fromJson(Map<String, dynamic> json) => EbAccount(
    uid: json['uid'] as String,
    iban: (json['account_id'] as Map<String, dynamic>?)?['iban'] as String?,
    name: json['name'] as String?,
    details: json['details'] as String?,
    currency: json['currency'] as String?,
    product: json['product'] as String?,
    cashAccountType: json['cash_account_type'] as String?,
    usage: json['usage'] as String?,
    identificationHash: json['identification_hash'] as String?,
    identificationHashes: ((json['identification_hashes'] as List?) ?? const [])
        .cast<String>(),
  );
}
