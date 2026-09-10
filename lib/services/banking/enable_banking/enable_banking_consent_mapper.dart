// dart format width=400

import '../banking_authorization.dart';
import '../banking_connection.dart';
import '../banking_reference.dart';
import 'enable_banking_account_mapper.dart';
import 'enable_banking_errors.dart';
import 'enable_banking_institution_mapper.dart';
import 'models/aspsp.dart';
import 'models/eb_auth.dart';
import 'models/eb_session.dart';
import 'models/eb_session_details.dart';

class EnableBankingConsentMapper {
  final _institutions = const EnableBankingInstitutionMapper();
  final _accounts = const EnableBankingAccountMapper();

  const EnableBankingConsentMapper();

  BankingAuthorization authorization(EbAuthorization value) {
    final uri = Uri.parse(value.url);
    if (uri.scheme != 'https' || uri.host.isEmpty || uri.userInfo.isNotEmpty) throw const FormatException('Invalid authorization URL');
    return BankingAuthorization(providerId: enableBankingId, authorizationId: value.authorizationId, uri: uri);
  }

  BankingConnectionResult created(EbSession value) {
    final accounts = value.accounts.map(_accounts.account).toList();
    final connection = BankingConnection(
      reference: BankingConnectionReference(providerId: enableBankingId, remoteId: value.sessionId),
      institution: _institutions.institution(Aspsp(name: value.aspspName, country: value.aspspCountry, psuTypes: [if (value.psuType != null) value.psuType!])),
      validUntil: value.validUntil,
      status: BankingConnectionStatus.active,
      accounts: accounts.map((account) => account.reference).toList(),
    );
    return BankingConnectionResult(connection: connection, accounts: accounts);
  }

  BankingConnection connection(EbSessionDetails value, BankingConnectionReference reference) {
    final identities = {
      for (final account in value.accountsData) account.uid: {account.identificationHash, ...account.identificationHashes},
    };
    return BankingConnection(
      reference: reference,
      institution: _institutions.institution(Aspsp(name: value.aspspName, country: value.aspspCountry, psuTypes: [value.psuType])),
      validUntil: value.validUntil,
      status: switch (value.status) {
        EbSessionStatus.authorized => BankingConnectionStatus.active,
        EbSessionStatus.pendingAuthorization || EbSessionStatus.returnedFromBank => BankingConnectionStatus.pending,
        EbSessionStatus.cancelled => BankingConnectionStatus.cancelled,
        EbSessionStatus.closed => BankingConnectionStatus.closed,
        EbSessionStatus.expired => BankingConnectionStatus.expired,
        EbSessionStatus.invalid => BankingConnectionStatus.invalid,
        EbSessionStatus.revoked => BankingConnectionStatus.revoked,
      },
      accounts: [for (final uid in value.accountUids) BankingAccountReference(providerId: enableBankingId, remoteId: uid, identityKeys: identities[uid] ?? const {})],
      createdAt: value.created,
      authorizedAt: value.authorized,
      closedAt: value.closed,
    );
  }
}
