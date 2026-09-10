// dart format width=400

import '../bank_institution_directory.dart';
import '../bank_consent_service.dart';
import '../bank_account_data_source.dart';
import '../banking_provider.dart';
import 'enable_banking_api.dart';
import 'enable_banking_errors.dart';
import 'enable_banking_institution_directory.dart';
import 'enable_banking_consent_service.dart';
import 'enable_banking_account_data_source.dart';

class EnableBankingProvider implements BankingProvider {
  @override
  String get id => enableBankingId;

  @override
  final BankInstitutionDirectory institutions;
  @override
  final BankConsentService consent;
  @override
  final BankAccountDataSource accountData;

  EnableBankingProvider(EnableBankingApi api) : institutions = EnableBankingInstitutionDirectory(api), consent = EnableBankingConsentService(api), accountData = EnableBankingAccountDataSource(api);
}
