import '../enable_banking_exception.dart';

enum EbSessionStatus {
  authorized,
  cancelled,
  closed,
  expired,
  invalid,
  pendingAuthorization,
  returnedFromBank,
  revoked;

  static EbSessionStatus fromApi(String value) => switch (value) {
    'AUTHORIZED' => EbSessionStatus.authorized,
    'CANCELLED' => EbSessionStatus.cancelled,
    'CLOSED' => EbSessionStatus.closed,
    'EXPIRED' => EbSessionStatus.expired,
    'INVALID' => EbSessionStatus.invalid,
    'PENDING_AUTHORIZATION' => EbSessionStatus.pendingAuthorization,
    'RETURNED_FROM_BANK' => EbSessionStatus.returnedFromBank,
    'REVOKED' => EbSessionStatus.revoked,
    _ => throw EnableBankingException(
      message: 'Unknown session status: $value',
      kind: EnableBankingFailureKind.invalidResponse,
    ),
  };
}

class EbSessionAccount {
  final String uid;
  final String? identificationHash;
  final List<String> identificationHashes;

  const EbSessionAccount({
    required this.uid,
    this.identificationHash,
    this.identificationHashes = const [],
  });

  static EbSessionAccount fromJson(Map<String, dynamic> json) =>
      EbSessionAccount(
        uid: json['uid'] as String,
        identificationHash: json['identification_hash'] as String?,
        identificationHashes:
            ((json['identification_hashes'] as List?) ?? const [])
                .map((value) => value as String)
                .toList(growable: false),
      );
}

/// Session state returned by `GET /sessions/{session_id}`.
///
/// This response intentionally has its own model: unlike `POST /sessions`,
/// `accounts` contains UIDs and the response does not contain `session_id`.
class EbSessionDetails {
  final EbSessionStatus status;
  final List<String> accountUids;
  final List<EbSessionAccount> accountsData;
  final String aspspName;
  final String aspspCountry;
  final String psuType;
  final String? psuIdHash;
  final DateTime validUntil;
  final DateTime created;
  final DateTime? authorized;
  final DateTime? closed;

  const EbSessionDetails({
    required this.status,
    this.accountUids = const [],
    this.accountsData = const [],
    required this.aspspName,
    required this.aspspCountry,
    required this.psuType,
    this.psuIdHash,
    required this.validUntil,
    required this.created,
    this.authorized,
    this.closed,
  });

  static EbSessionDetails fromJson(Map<String, dynamic> json) {
    try {
      final aspsp = json['aspsp'] as Map<String, dynamic>;
      final access = json['access'] as Map<String, dynamic>;
      return EbSessionDetails(
        status: EbSessionStatus.fromApi(json['status'] as String),
        accountUids: ((json['accounts'] as List?) ?? const [])
            .map((value) => value as String)
            .toList(growable: false),
        accountsData: ((json['accounts_data'] as List?) ?? const [])
            .map(
              (value) =>
                  EbSessionAccount.fromJson(value as Map<String, dynamic>),
            )
            .toList(growable: false),
        aspspName: aspsp['name'] as String,
        aspspCountry: aspsp['country'] as String,
        psuType: json['psu_type'] as String,
        psuIdHash: json['psu_id_hash'] as String?,
        validUntil: DateTime.parse(access['valid_until'] as String),
        created: DateTime.parse(json['created'] as String),
        authorized: _optionalDate(json['authorized']),
        closed: _optionalDate(json['closed']),
      );
    } catch (error) {
      throw FormatException('Malformed Enable Banking session: $error');
    }
  }

  static DateTime? _optionalDate(Object? value) =>
      value == null ? null : DateTime.parse(value as String);
}
