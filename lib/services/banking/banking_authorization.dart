// dart format width=400

import 'bank_institution.dart';

class BankingAuthorizationRequest {
  final BankInstitution institution;
  final BankingCustomerType customerType;
  final DateTime validUntil;
  final String state;
  final String? language;
  final Uri? redirectUri;

  const BankingAuthorizationRequest({required this.institution, required this.validUntil, required this.state, this.customerType = BankingCustomerType.personal, this.language, this.redirectUri});
}

class BankingAuthorization {
  final String providerId;
  final String authorizationId;
  final Uri uri;

  const BankingAuthorization({required this.providerId, required this.authorizationId, required this.uri});
}
