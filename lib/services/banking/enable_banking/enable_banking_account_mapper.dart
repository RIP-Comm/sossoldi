// dart format width=400

import '../banking_account.dart';
import '../banking_reference.dart';
import 'enable_banking_errors.dart';
import 'models/eb_account.dart';

class EnableBankingAccountMapper {
  const EnableBankingAccountMapper();

  BankingAccount account(EbAccount value) => BankingAccount(
    reference: BankingAccountReference(providerId: enableBankingId, remoteId: value.uid, identityKeys: [if (value.identificationHash != null) value.identificationHash!, ...value.identificationHashes]),
    iban: value.iban,
    name: value.name,
    details: value.details,
    currency: value.currency,
    product: value.product,
    accountType: value.cashAccountType,
    usage: value.usage,
  );
}
