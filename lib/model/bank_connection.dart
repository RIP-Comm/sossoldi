// dart format width=400

import 'base_entity.dart';

const String bankConnectionTable = 'bankConnection';
const String bankAccountIdentityTable = 'bankAccountIdentity';

class BankConnectionFields extends BaseEntityFields {
  static String id = BaseEntityFields.getId;
  static String providerId = 'providerId';
  static String institutionName = 'aspspName';
  static String institutionCountry = 'aspspCountry';
  static String applicationId = 'applicationId';
  static String remoteConnectionId = 'sessionId';
  static String pendingRemoteConnectionId = 'pendingSessionId';
  static String pendingAuthorizationId = 'pendingAuthorizationId';
  static String validUntil = 'validUntil';
  static String pendingValidUntil = 'pendingValidUntil';
  static String status = 'status';
  static String psuType = 'psuType';
  static String createdAt = BaseEntityFields.getCreatedAt;
  static String updatedAt = BaseEntityFields.getUpdatedAt;

  static final List<String> allFields = [id, providerId, institutionName, institutionCountry, applicationId, remoteConnectionId, pendingRemoteConnectionId, pendingAuthorizationId, validUntil, pendingValidUntil, status, psuType, createdAt, updatedAt];
}

class BankAccountIdentityFields {
  static String connectionId = 'connectionId';
  static String bankAccountId = 'bankAccountId';
  static String identificationHash = 'identificationHash';
}

enum BankConnectionStatus {
  authorizing,
  awaitingImport,
  active,
  expired,
  revoked,
  reauthRequired,
  revocationPending,
  disconnected;

  String get code => switch (this) {
    BankConnectionStatus.authorizing => 'AUTHORIZING',
    BankConnectionStatus.awaitingImport => 'AWAITING_IMPORT',
    BankConnectionStatus.active => 'ACTIVE',
    BankConnectionStatus.expired => 'EXPIRED',
    BankConnectionStatus.revoked => 'REVOKED',
    BankConnectionStatus.reauthRequired => 'REAUTH_REQUIRED',
    BankConnectionStatus.revocationPending => 'REVOCATION_PENDING',
    BankConnectionStatus.disconnected => 'DISCONNECTED',
  };

  static BankConnectionStatus fromJson(String code) => BankConnectionStatus.values.firstWhere((status) => status.code == code, orElse: () => throw FormatException('Unknown bank connection status: $code'));
}

class BankConnection extends BaseEntity {
  static const _unset = Object();

  final String providerId;
  final String institutionName;
  final String institutionCountry;
  final String applicationId;
  final String? remoteConnectionId;
  final String? pendingRemoteConnectionId;
  final String? pendingAuthorizationId;
  final DateTime? validUntil;
  final DateTime? pendingValidUntil;
  final BankConnectionStatus status;
  final String psuType;

  const BankConnection({super.id, required this.providerId, required this.institutionName, required this.institutionCountry, required this.applicationId, this.remoteConnectionId, this.pendingRemoteConnectionId, this.pendingAuthorizationId, this.validUntil, this.pendingValidUntil, required this.status, this.psuType = 'personal', super.createdAt, super.updatedAt});

  BankConnection copy({
    int? id,
    String? providerId,
    String? institutionName,
    String? institutionCountry,
    String? applicationId,
    Object? remoteConnectionId = _unset,
    Object? pendingRemoteConnectionId = _unset,
    Object? pendingAuthorizationId = _unset,
    Object? validUntil = _unset,
    Object? pendingValidUntil = _unset,
    BankConnectionStatus? status,
    String? psuType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => BankConnection(
    id: id ?? this.id,
    providerId: providerId ?? this.providerId,
    institutionName: institutionName ?? this.institutionName,
    institutionCountry: institutionCountry ?? this.institutionCountry,
    applicationId: applicationId ?? this.applicationId,
    remoteConnectionId: remoteConnectionId == _unset ? this.remoteConnectionId : remoteConnectionId as String?,
    pendingRemoteConnectionId: pendingRemoteConnectionId == _unset ? this.pendingRemoteConnectionId : pendingRemoteConnectionId as String?,
    pendingAuthorizationId: pendingAuthorizationId == _unset ? this.pendingAuthorizationId : pendingAuthorizationId as String?,
    validUntil: validUntil == _unset ? this.validUntil : validUntil as DateTime?,
    pendingValidUntil: pendingValidUntil == _unset ? this.pendingValidUntil : pendingValidUntil as DateTime?,
    status: status ?? this.status,
    psuType: psuType ?? this.psuType,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  static BankConnection fromJson(Map<String, Object?> json) => BankConnection(
    id: json[BankConnectionFields.id] as int?,
    providerId: json[BankConnectionFields.providerId] as String? ?? 'enable_banking',
    institutionName: json[BankConnectionFields.institutionName] as String,
    institutionCountry: json[BankConnectionFields.institutionCountry] as String,
    applicationId: json[BankConnectionFields.applicationId] as String,
    remoteConnectionId: json[BankConnectionFields.remoteConnectionId] as String?,
    pendingRemoteConnectionId: json[BankConnectionFields.pendingRemoteConnectionId] as String?,
    pendingAuthorizationId: json[BankConnectionFields.pendingAuthorizationId] as String?,
    validUntil: _date(json[BankConnectionFields.validUntil]),
    pendingValidUntil: _date(json[BankConnectionFields.pendingValidUntil]),
    status: BankConnectionStatus.fromJson(json[BankConnectionFields.status] as String),
    psuType: json[BankConnectionFields.psuType] as String? ?? 'personal',
    createdAt: _date(json[BankConnectionFields.createdAt]),
    updatedAt: _date(json[BankConnectionFields.updatedAt]),
  );

  Map<String, Object?> toJson({bool update = false, DateTime? clock}) {
    final now = (clock ?? DateTime.now()).toUtc().toIso8601String();
    return {
      BankConnectionFields.id: id,
      BankConnectionFields.providerId: providerId,
      BankConnectionFields.institutionName: institutionName,
      BankConnectionFields.institutionCountry: institutionCountry,
      BankConnectionFields.applicationId: applicationId,
      BankConnectionFields.remoteConnectionId: remoteConnectionId,
      BankConnectionFields.pendingRemoteConnectionId: pendingRemoteConnectionId,
      BankConnectionFields.pendingAuthorizationId: pendingAuthorizationId,
      BankConnectionFields.validUntil: validUntil?.toUtc().toIso8601String(),
      BankConnectionFields.pendingValidUntil: pendingValidUntil?.toUtc().toIso8601String(),
      BankConnectionFields.status: status.code,
      BankConnectionFields.psuType: psuType,
      BankConnectionFields.createdAt: update ? createdAt?.toUtc().toIso8601String() : now,
      BankConnectionFields.updatedAt: now,
    };
  }

  static DateTime? _date(Object? value) => value == null ? null : DateTime.parse(value as String).toUtc();
}
