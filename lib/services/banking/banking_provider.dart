// dart format width=400

import 'bank_institution_directory.dart';
import 'bank_consent_service.dart';
import 'bank_account_data_source.dart';

abstract interface class BankingProvider {
  String get id;
  BankInstitutionDirectory get institutions;
  BankConsentService get consent;
  BankAccountDataSource get accountData;
}
