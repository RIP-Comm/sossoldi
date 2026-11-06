import 'enable_banking_config.dart';

/// One atomic secure-storage snapshot keeps the generated certificate paired with its private key across interrupted setup.
class EnableBankingSetupDraft {
  final int step;
  final bool existingCredentials;
  final String appId;
  final String redirectUri;
  final String? privateKeyPem;
  final String? certificatePem;

  const EnableBankingSetupDraft({
    this.step = 0,
    this.existingCredentials = false,
    this.appId = '',
    this.redirectUri = kEbRelayRedirectUri,
    this.privateKeyPem,
    this.certificatePem,
  });

  Map<String, Object?> toJson() => {
    'version': 1,
    'step': step,
    'existingCredentials': existingCredentials,
    'appId': appId,
    'redirectUri': redirectUri,
    'privateKeyPem': privateKeyPem,
    'certificatePem': certificatePem,
  };

  factory EnableBankingSetupDraft.fromJson(Map<String, dynamic> json) {
    if (json['version'] != 1 ||
        json['step'] is! int ||
        (json['step'] as int) < 0 ||
        (json['step'] as int) > 3) {
      throw const FormatException('Invalid setup draft');
    }
    return EnableBankingSetupDraft(
      step: json['step'] as int,
      existingCredentials: json['existingCredentials'] as bool,
      appId: json['appId'] as String,
      redirectUri: json['redirectUri'] as String,
      privateKeyPem: json['privateKeyPem'] as String?,
      certificatePem: json['certificatePem'] as String?,
    );
  }
}
