/// Sandbox metadata attached to an [Aspsp] in the `/aspsps` response.
///
/// Only present for sandbox ASPSPs; captured defensively as the shape of the
/// nested `users` entries is not stable across banks.
class SandboxInfo {
  final List<Map<String, dynamic>> users;

  const SandboxInfo({this.users = const []});

  static SandboxInfo fromJson(Map<String, dynamic> json) => SandboxInfo(
    users: ((json['users'] as List?) ?? const []).cast<Map<String, dynamic>>(),
  );
}

/// A bank (ASPSP) as returned by `GET /aspsps`.
class Aspsp {
  final String name;
  final String country;
  final String? logo;
  final List<String> psuTypes;

  /// Maximum consent validity in **seconds** (`maximum_consent_validity`).
  final int? maximumConsentValidity;
  final bool beta;
  final SandboxInfo? sandbox;

  const Aspsp({
    required this.name,
    required this.country,
    this.logo,
    this.psuTypes = const [],
    this.maximumConsentValidity,
    this.beta = false,
    this.sandbox,
  });

  static Aspsp fromJson(Map<String, dynamic> json) => Aspsp(
    name: json['name'] as String,
    country: json['country'] as String,
    logo: json['logo'] as String?,
    psuTypes: ((json['psu_types'] as List?) ?? const [])
        .map((e) => e as String)
        .toList(),
    maximumConsentValidity: json['maximum_consent_validity'] as int?,
    beta: (json['beta'] as bool?) ?? false,
    sandbox: json['sandbox'] == null
        ? null
        : SandboxInfo.fromJson(json['sandbox'] as Map<String, dynamic>),
  );
}
