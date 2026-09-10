import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_config.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_exception.dart';

void main() {
  group('EnableBankingConfig.fromJson', () {
    test('parses a well-formed config', () {
      final config = EnableBankingConfig.fromJson({
        'app_id': 'app-1',
        'environment': 'sandbox',
        'redirect_uri': 'https://example.com/callback',
        'default_country': 'IT',
      });

      expect(config.appId, 'app-1');
      expect(config.environment, EnableBankingEnvironment.sandbox);
      expect(config.redirectUri, 'https://example.com/callback');
      expect(config.defaultCountry, 'IT');
    });

    test('defaults environment and redirectUri when absent', () {
      final config = EnableBankingConfig.fromJson({'app_id': 'app-1'});

      expect(config.environment, EnableBankingEnvironment.production);
      expect(config.redirectUri, kEbRedirectUri);
      expect(config.defaultCountry, isNull);
    });

    test('throws EnableBankingException instead of a raw TypeError when '
        'app_id is missing', () {
      expect(
        () => EnableBankingConfig.fromJson({'environment': 'sandbox'}),
        throwsA(isA<EnableBankingException>()),
      );
    });

    test(
      'rejects an unknown stored environment instead of assuming production',
      () {
        expect(
          () => EnableBankingConfig.fromJson({
            'app_id': 'app-1',
            'environment': 'staging',
          }),
          throwsA(isA<EnableBankingException>()),
        );
      },
    );

    test('throws EnableBankingException instead of a raw TypeError when '
        'app_id is the wrong type (corrupted/incompatible stored blob)', () {
      expect(
        () => EnableBankingConfig.fromJson({'app_id': 42}),
        throwsA(isA<EnableBankingException>()),
      );
    });
  });
}
