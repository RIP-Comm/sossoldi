import 'enable_banking_exception.dart';

/// Default OAuth callback URI registered with Enable Banking.
const String kEbRedirectUri = 'sossoldi://eb-callback';

enum EnableBankingEnvironment {
  production,
  sandbox;

  static EnableBankingEnvironment fromJson(String value) =>
      EnableBankingEnvironment.values.firstWhere(
        (e) => e.name == value,
        orElse: () => EnableBankingEnvironment.production,
      );

  String toJson() => name;
}

/// Non-secret configuration for a user's Enable Banking application.
///
/// The `app_id` and private key are BYOC credentials owned by the user and
/// live in [EnableBankingCredentialsStore], not here.
class EnableBankingConfig {
  final String appId;
  final EnableBankingEnvironment environment;
  final String redirectUri;
  final String? defaultCountry;

  const EnableBankingConfig({
    required this.appId,
    this.environment = EnableBankingEnvironment.production,
    this.redirectUri = kEbRedirectUri,
    this.defaultCountry,
  });

  /// Enable Banking serves the same host for both production and sandbox;
  /// the environment is fixed at application registration time.
  String get baseUrl => 'https://api.enablebanking.com';

  /// Throws [EnableBankingException] (not a raw [TypeError]) if [json] is a
  /// corrupted or otherwise incompatible blob — e.g. leftover from a
  /// previous, incompatible app version — instead of the required `app_id`
  /// field being missing or of an unexpected type.
  static EnableBankingConfig fromJson(Map<String, dynamic> json) {
    try {
      return EnableBankingConfig(
        appId: json['app_id'] as String,
        environment: EnableBankingEnvironment.fromJson(
          json['environment'] as String? ?? 'production',
        ),
        redirectUri: json['redirect_uri'] as String? ?? kEbRedirectUri,
        defaultCountry: json['default_country'] as String?,
      );
    } catch (e) {
      throw EnableBankingException(
        message: 'Malformed Enable Banking configuration: $e',
      );
    }
  }

  Map<String, dynamic> toJson() => {
    'app_id': appId,
    'environment': environment.toJson(),
    'redirect_uri': redirectUri,
    'default_country': defaultCountry,
  };
}
