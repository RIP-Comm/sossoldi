// dart format width=400

import '../banking_exception.dart';

enum PendingAuthorizationPhase {
  awaitingCallback,
  connectionStaged;

  // Keep the serialized phase compatible with pending authorizations saved before the naming cleanup.
  String get code => switch (this) {
    PendingAuthorizationPhase.awaitingCallback => 'awaitingCallback',
    PendingAuthorizationPhase.connectionStaged => 'sessionStaged',
  };

  static PendingAuthorizationPhase fromCode(String code) => PendingAuthorizationPhase.values.firstWhere((phase) => phase.code == code);
}

class PendingBankAuthorization {
  static const _unset = Object();

  final String providerId;
  final String state;
  final String authorizationId;
  final String authorizationUrl;
  final String applicationId;
  final String institutionName;
  final String institutionCountry;
  final String redirectUri;
  final DateTime expiresAt;
  final DateTime consentValidUntil;
  final int? reconnectConnectionId;
  final int? stagedConnectionId;
  final PendingAuthorizationPhase phase;

  const PendingBankAuthorization({
    required this.providerId,
    required this.state,
    required this.authorizationId,
    required this.authorizationUrl,
    required this.applicationId,
    required this.institutionName,
    required this.institutionCountry,
    required this.redirectUri,
    required this.expiresAt,
    required this.consentValidUntil,
    this.reconnectConnectionId,
    this.stagedConnectionId,
    this.phase = PendingAuthorizationPhase.awaitingCallback,
  });

  PendingBankAuthorization copy({Object? stagedConnectionId = _unset, PendingAuthorizationPhase? phase}) => PendingBankAuthorization(
    providerId: providerId,
    state: state,
    authorizationId: authorizationId,
    authorizationUrl: authorizationUrl,
    applicationId: applicationId,
    institutionName: institutionName,
    institutionCountry: institutionCountry,
    redirectUri: redirectUri,
    expiresAt: expiresAt,
    consentValidUntil: consentValidUntil,
    reconnectConnectionId: reconnectConnectionId,
    stagedConnectionId: stagedConnectionId == _unset ? this.stagedConnectionId : stagedConnectionId as int?,
    phase: phase ?? this.phase,
  );

  Map<String, Object?> toJson() => {
    'version': 1,
    'provider_id': providerId,
    'state': state,
    'authorization_id': authorizationId,
    'authorization_url': authorizationUrl,
    'application_id': applicationId,
    'aspsp_name': institutionName,
    'aspsp_country': institutionCountry,
    'redirect_uri': redirectUri,
    'expires_at': expiresAt.toUtc().toIso8601String(),
    'consent_valid_until': consentValidUntil.toUtc().toIso8601String(),
    'reconnect_connection_id': reconnectConnectionId,
    'staged_connection_id': stagedConnectionId,
    'phase': phase.code,
  };

  static PendingBankAuthorization fromJson(Map<String, dynamic> json) {
    try {
      if (json['version'] != 1) {
        throw const FormatException('unsupported pending authorization');
      }
      return PendingBankAuthorization(
        providerId: json['provider_id'] as String? ?? 'enable_banking',
        state: json['state'] as String,
        authorizationId: json['authorization_id'] as String,
        authorizationUrl: json['authorization_url'] as String,
        applicationId: json['application_id'] as String,
        institutionName: json['aspsp_name'] as String,
        institutionCountry: json['aspsp_country'] as String,
        redirectUri: json['redirect_uri'] as String,
        expiresAt: DateTime.parse(json['expires_at'] as String).toUtc(),
        consentValidUntil: DateTime.parse(json['consent_valid_until'] as String).toUtc(),
        reconnectConnectionId: json['reconnect_connection_id'] as int?,
        stagedConnectionId: json['staged_connection_id'] as int?,
        phase: PendingAuthorizationPhase.fromCode(json['phase'] as String),
      );
    } catch (error) {
      throw const BankingException(providerId: 'application', failure: BankingFailure.invalidResponse);
    }
  }
}
