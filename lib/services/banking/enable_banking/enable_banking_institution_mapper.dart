// dart format width=400

import 'dart:convert';

import '../bank_institution.dart';
import 'models/aspsp.dart';
import 'enable_banking_errors.dart';

class EnableBankingInstitutionMapper {
  static const providerId = enableBankingId;

  const EnableBankingInstitutionMapper();

  BankInstitution institution(Aspsp value) => BankInstitution(
    providerId: providerId,
    id: jsonEncode([value.country, value.name]),
    name: value.name,
    country: value.country,
    logoUri: value.logo == null ? null : Uri.tryParse(value.logo!),
    customerTypes: {if (value.psuTypes.contains('personal')) BankingCustomerType.personal, if (value.psuTypes.contains('business')) BankingCustomerType.business},
    maximumConsentDuration: value.maximumConsentValidity == null ? null : Duration(seconds: value.maximumConsentValidity!),
    isSandbox: value.sandbox != null,
    isBeta: value.beta,
  );
}
