import 'eb_account.dart';

/// An authorized session as returned by `POST /sessions` and
/// `GET /sessions/{id}`.
///
/// [aspspName]/[aspspCountry] come from the nested `aspsp` object and
/// [validUntil] from `access.valid_until`.
class EbSession {
  final String sessionId;
  final List<EbAccount> accounts;
  final String aspspName;
  final String aspspCountry;
  final DateTime validUntil;
  final String? psuType;

  const EbSession({
    required this.sessionId,
    this.accounts = const [],
    required this.aspspName,
    required this.aspspCountry,
    required this.validUntil,
    this.psuType,
  });

  static EbSession fromJson(Map<String, dynamic> json) {
    final aspsp = json['aspsp'] as Map<String, dynamic>?;
    final access = json['access'] as Map<String, dynamic>?;
    return EbSession(
      sessionId: json['session_id'] as String,
      accounts: ((json['accounts'] as List?) ?? const [])
          .map((e) => EbAccount.fromJson(e as Map<String, dynamic>))
          .toList(),
      aspspName: (aspsp?['name'] as String?) ?? '',
      aspspCountry: (aspsp?['country'] as String?) ?? '',
      validUntil: DateTime.parse(access?['valid_until'] as String),
      psuType: json['psu_type'] as String?,
    );
  }
}
