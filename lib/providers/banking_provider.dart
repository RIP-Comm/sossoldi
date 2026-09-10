// dart format width=400

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/banking/banking_provider.dart';
import '../services/banking/bank_institution_directory.dart' as domain;
import '../services/banking/bank_consent_service.dart' as domain;
import '../services/banking/bank_account_data_source.dart' as domain;
import '../services/banking/enable_banking/enable_banking_dependencies.dart';
import '../services/banking/enable_banking/enable_banking_provider.dart';

part 'banking_provider.g.dart';

@Riverpod(keepAlive: true)
BankingProvider bankingService(Ref ref) => EnableBankingProvider(ref.watch(enableBankingApiProvider));

@Riverpod(keepAlive: true)
domain.BankInstitutionDirectory bankInstitutionDirectory(Ref ref) => ref.watch(bankingServiceProvider).institutions;

@Riverpod(keepAlive: true)
domain.BankConsentService bankConsentService(Ref ref) => ref.watch(bankingServiceProvider).consent;

@Riverpod(keepAlive: true)
domain.BankAccountDataSource bankAccountDataSource(Ref ref) => ref.watch(bankingServiceProvider).accountData;
