// dart format width=400

import 'banking_reference.dart';

class BankingAccount {
  final BankingAccountReference reference;
  final String? iban;
  final String? name;
  final String? details;
  final String? currency;
  final String? product;
  final String? accountType;
  final String? usage;

  const BankingAccount({required this.reference, this.iban, this.name, this.details, this.currency, this.product, this.accountType, this.usage});
}
