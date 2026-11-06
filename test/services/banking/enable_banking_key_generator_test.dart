import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_auth.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_key_generator.dart';

const _testAppId = 'test-app-id';

// A small (but still supported) key size keeps this test fast; production always calls generateEnableBankingKeyMaterial with kEnableBankingKeySize (4096).
const _testKeySize = 1024;

void main() {
  group('generateEnableBankingKeyMaterial', () {
    test('produces a PKCS8 private key PEM', () {
      final material = generateEnableBankingKeyMaterial(_testKeySize);

      expect(material.privateKeyPem, startsWith('-----BEGIN PRIVATE KEY-----'));
      expect(material.privateKeyPem, contains('-----END PRIVATE KEY-----'));
    });

    test('produces a self-signed certificate PEM', () {
      final material = generateEnableBankingKeyMaterial(_testKeySize);

      expect(
        material.certificatePem,
        startsWith('-----BEGIN CERTIFICATE-----'),
      );
      expect(material.certificatePem, contains('-----END CERTIFICATE-----'));
    });

    test('the private key is usable by EnableBankingAuth.buildJwt', () {
      final material = generateEnableBankingKeyMaterial(_testKeySize);
      final auth = EnableBankingAuth();

      final token = auth.buildJwt(
        appId: _testAppId,
        privateKeyPem: material.privateKeyPem,
      );

      final decoded = JWT.decode(token);
      expect(decoded.header?['alg'], 'RS256');
    });

    test('the certificate embeds the matching public key', () {
      final material = generateEnableBankingKeyMaterial(_testKeySize);
      final auth = EnableBankingAuth();

      final token = auth.buildJwt(
        appId: _testAppId,
        privateKeyPem: material.privateKeyPem,
      );

      final verified = JWT.verify(
        token,
        RSAPublicKey.cert(material.certificatePem),
      );
      expect(verified.payload['iss'], 'enablebanking.com');
    });
  });
}
