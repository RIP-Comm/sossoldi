// dart format width=400

import '../bank_consent_service.dart';
import '../banking_authorization.dart';
import '../banking_connection.dart';
import '../banking_exception.dart';
import '../banking_reference.dart';
import 'enable_banking_api.dart';
import 'enable_banking_config.dart';
import 'enable_banking_consent_mapper.dart';
import 'enable_banking_errors.dart';
import 'enable_banking_reference.dart';

class EnableBankingConsentService implements BankConsentService {
  final EnableBankingApi _api;
  final _mapper = const EnableBankingConsentMapper();

  EnableBankingConsentService(this._api);

  @override
  Future<BankingAuthorization> startAuthorization(BankingAuthorizationRequest request) => withEnableBankingErrors(() async {
    checkEnableBankingReference(request.institution.providerId, request.institution.id);
    if (request.state.trim().isEmpty) throw const BankingException(providerId: enableBankingId, failure: BankingFailure.rejected);
    return _mapper.authorization(await _api.startAuthorization(aspspName: request.institution.name, aspspCountry: request.institution.country, state: request.state, validUntil: request.validUntil, psuType: request.customerType.name, language: request.language, redirectUri: request.redirectUri?.toString() ?? kEbRedirectUri));
  });

  @override
  Future<BankingConnectionResult> createConnection(String authorizationCode) => withEnableBankingErrors(() async {
    if (authorizationCode.trim().isEmpty) throw const BankingException(providerId: enableBankingId, failure: BankingFailure.rejected);
    return _mapper.created(await _api.createSession(authorizationCode));
  });

  @override
  Future<BankingConnection> getConnection(BankingConnectionReference reference) => withEnableBankingErrors(() async {
    checkEnableBankingReference(reference.providerId, reference.remoteId);
    return _mapper.connection(await _api.getSession(reference.remoteId), reference);
  });

  @override
  Future<void> revokeConnection(BankingConnectionReference reference) => withEnableBankingErrors(() async {
    checkEnableBankingReference(reference.providerId, reference.remoteId);
    await _api.deleteSession(reference.remoteId);
  });
}
