import '../enable_banking_config.dart';

/// Application metadata returned by `GET /application`.
class EbApplication {
  final String name;
  final String? description;
  final String kid;
  final EnableBankingEnvironment environment;
  final List<String> redirectUrls;
  final bool active;
  final List<String> countries;
  final List<String> services;

  const EbApplication({
    required this.name,
    this.description,
    required this.kid,
    required this.environment,
    this.redirectUrls = const [],
    required this.active,
    this.countries = const [],
    this.services = const [],
  });

  static EbApplication fromJson(Map<String, dynamic> json) {
    try {
      return EbApplication(
        name: json['name'] as String,
        description: json['description'] as String?,
        kid: json['kid'] as String,
        environment: EnableBankingEnvironment.fromApi(
          json['environment'] as String,
        ),
        redirectUrls: ((json['redirect_urls'] as List?) ?? const [])
            .map((value) => value as String)
            .toList(growable: false),
        active: json['active'] as bool,
        countries:
            ((json['countries'] as List?) ?? const [])
                .map((value) => (value as String).toUpperCase())
                .toSet()
                .toList(growable: false)
              ..sort(),
        services:
            ((json['services'] as List?) ?? const [])
                .map((value) => (value as String).toUpperCase())
                .toSet()
                .toList(growable: false)
              ..sort(),
      );
    } catch (error) {
      throw FormatException('Malformed Enable Banking application: $error');
    }
  }
}
