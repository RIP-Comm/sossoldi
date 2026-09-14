import 'enable_banking_exception.dart';

/// Default OAuth callback URI registered with Enable Banking.
///
/// The custom scheme can be claimed by another local app and the HTTPS relay
/// is an external availability dependency. OAuth state validation is therefore
/// mandatory; relay or browser failures must remain observable and retryable.
const String kEbRedirectUri = 'sossoldi://eb-callback';
const String kEbRelayRedirectUri =
    'https://rip-comm.github.io/sossoldi/enablebanking/eb-callback.html';

Uri validateEnableBankingRedirect(
  String value, {
  Iterable<String>? registeredRedirects,
}) {
  final uri = Uri.tryParse(value);
  final isAppCallback = value == kEbRedirectUri;
  final isRelayCallback = value == kEbRelayRedirectUri;
  if (uri == null ||
      !uri.hasScheme ||
      (!isAppCallback && !isRelayCallback) ||
      uri.hasQuery ||
      uri.hasFragment ||
      uri.userInfo.isNotEmpty) {
    throw const EnableBankingException(
      message: 'Unsupported Enable Banking redirect URI',
      kind: EnableBankingFailureKind.invalidRequest,
    );
  }
  if (registeredRedirects != null && !registeredRedirects.contains(value)) {
    throw const EnableBankingException(
      message: 'Redirect URI is not registered for this application',
      kind: EnableBankingFailureKind.invalidRequest,
    );
  }
  return uri;
}

enum EnableBankingEnvironment {
  production,
  sandbox;

  static EnableBankingEnvironment fromApi(String value) =>
      switch (value.toUpperCase()) {
        'PRODUCTION' => EnableBankingEnvironment.production,
        'SANDBOX' => EnableBankingEnvironment.sandbox,
        _ => throw EnableBankingException(
          message: 'Unknown Enable Banking environment: $value',
        ),
      };

  static EnableBankingEnvironment fromJson(String value) =>
      switch (value.toLowerCase()) {
        'production' => EnableBankingEnvironment.production,
        'sandbox' => EnableBankingEnvironment.sandbox,
        _ => throw EnableBankingException(
          message: 'Unknown stored Enable Banking environment: $value',
        ),
      };

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
  final List<String> supportedCountries;
  final List<String> redirectUrls;

  const EnableBankingConfig({
    required this.appId,
    this.environment = EnableBankingEnvironment.production,
    this.redirectUri = kEbRedirectUri,
    this.defaultCountry,
    this.supportedCountries = const [],
    this.redirectUrls = const [],
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
        supportedCountries: ((json['supported_countries'] as List?) ?? const [])
            .map((value) => value as String)
            .toList(growable: false),
        redirectUrls: ((json['redirect_urls'] as List?) ?? const [])
            .map((value) => value as String)
            .toList(growable: false),
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
    'supported_countries': supportedCountries,
    'redirect_urls': redirectUrls,
  };
}
