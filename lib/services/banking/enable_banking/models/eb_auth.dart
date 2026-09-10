/// Authorization start response from `POST /auth`.
///
/// [url] is the consent page the PSU must be sent to.
class EbAuthorization {
  final String url;
  final String authorizationId;
  final String psuIdHash;

  const EbAuthorization({
    required this.url,
    required this.authorizationId,
    required this.psuIdHash,
  });

  static EbAuthorization fromJson(Map<String, dynamic> json) => EbAuthorization(
    url: json['url'] as String,
    authorizationId: json['authorization_id'] as String,
    psuIdHash: json['psu_id_hash'] as String,
  );
}
