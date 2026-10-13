// dart format width=400

import 'bank_account.dart';

class BankAccountLink {
  final String uid;
  final Set<String> identificationHashes;
  final String? iban;
  final BankAccount? newAccount;

  const BankAccountLink({required this.uid, required this.identificationHashes, this.iban, this.newAccount});
}
