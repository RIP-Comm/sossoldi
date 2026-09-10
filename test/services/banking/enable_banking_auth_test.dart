import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_auth.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_config.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_credentials_store.dart';

const _testAppId = 'test-app-id';

// Test-only RSA key pair (2048 bit), generated locally with openssl. Not
// used anywhere outside this test.
const _testPrivateKeyPem = '''-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCK8tcYKu5wY289
mQaXvehFJDyUnWxIKaKPNa+Vj1HV+mYtciLBBvLFjXmG8av4FFSctXNHSlkBDhjY
h0L5QASYI2vgVLn9NFb7F8Y97v2/T64AXf26PbeDrOdWmgKieliX8/36h2iVoEJD
1dq7yCtO8gLRkHLbFk3+Uc8T+p2yILcLcQVjWSwZH3o1egmTG8VUoxY5MxU7gbfG
iL5Y+UzxGgzR0EZYY+lG8vkZrBBw2RKbOMr9W/OIJivA/ycDf8tci+IyJUbW5jOB
xskpoA0s4uP3QI054tiWepHJlOL8JsQvlBi8TDGuSzzxgJy67JG1a45HZigPUwQD
+viEBlXFAgMBAAECggEAALlaOJSEsI48FqiU+bZyHuYc8LNPTKL252MiupdIGGLZ
JHR7TOEx46ikkPjyafUFKdniM2VmSFSf+YTe6viT7Y0Fs2INpA2hRGav0EPOC7Cp
GfRjbZSDv8pnXDKqP9l+W7BYSvVorJrsrXjQTnkxDJTDQf9MMesQVfpsJ1D/gF2c
T19QmPS0dSG5CQbYM5qfXY39z+mMeaHpYUOrAa4GcKrSua7B+7FRaAxaPTQ8ADvF
4e7fjSXZtp8CMKXcoFd83uzzsV/S6EtSxSlduQiTFQ6uX5bxbA54gAGyg3Y7ycd3
zvrgn0FDWb0F6Pf/dvZTZlC6NSujSuDoxMadtDVLswKBgQC91mCVwgrXo9nscJ2F
TbzVnFRKvAQJTiBIuNZWKgYLFZkF3xl98sZZmF/o5gr52i5L6D8rdF0WyBd/6Wlt
HG36AiLV4QcsEcHRA/p0itm2FwGMrrCjcNrum2EQxWZyTgXpg4LmZdTOshGPQTJb
157/wdA7vWwzKosa0Hx/UIoSwwKBgQC7YBMVGKVaM+sZA4vCh3hyZfSQVw6Fm2Fs
rDVjzLlyEIfatyF7OMlXL1FBQqRO1c5L+r+Jx6niBNt2gDaxIRSoMDBcqG/6coJq
X7Xtnu07//GCjypUO84mV+gDVVTb3kmkvMtndmlwekIwIZHFOmrozaesklaQbi//
7R1pNzvc1wKBgQCjagokgC/TJwHuDZcbbCq0euj4mFalJ/KUh0BCVdRz8DiUnFMW
X0ktUQSmuHgUUiNuRlMyde24MbBA9M1DFqj5AKO6FwaUggikg1cywV/d5nn3/1yg
pQJhSbHJvROOK+nc9M9Ww6vn7dM9zPKrqrX9FXrKIiok9WdfQr8Y3Vyt/wKBgGGU
jRuFdEdflmW2dQhfqJhbBFxPGh72ZmxD2qIYsdL3TOjYSjVzw1cGK1jDLfJoYkEr
WqiUNKKiSPCToOfqBGn6fpUimv5guA5Rvdr70yxWBB4sFK09YAST7x4dSE4gm1WR
hJRjFFIhOWr7cIC4BYkr4NB8fVxGJfUwNQrgWuqNAoGALvVqAS0Tk0iPX9xMdEe2
TKQiIDtjdJ/X/CVOI+v6FJ25xgnrUaQ8lAuGATJrHtnE0DiotGdtUF4q8qZvCLIu
B2eonlqf99uayj7vqYbyVsQkD7c7Ykj1nxC3ZKpD+ptmkCbsni5uanzbIIyXQAw1
f6fEtvtDl8wdWoHhdmPPNfQ=
-----END PRIVATE KEY-----''';

const _testPublicKeyPem = '''-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAivLXGCrucGNvPZkGl73o
RSQ8lJ1sSCmijzWvlY9R1fpmLXIiwQbyxY15hvGr+BRUnLVzR0pZAQ4Y2IdC+UAE
mCNr4FS5/TRW+xfGPe79v0+uAF39uj23g6znVpoConpYl/P9+odolaBCQ9Xau8gr
TvIC0ZBy2xZN/lHPE/qdsiC3C3EFY1ksGR96NXoJkxvFVKMWOTMVO4G3xoi+WPlM
8RoM0dBGWGPpRvL5GawQcNkSmzjK/VvziCYrwP8nA3/LXIviMiVG1uYzgcbJKaAN
LOLj90CNOeLYlnqRyZTi/CbEL5QYvEwxrks88YCcuuyRtWuOR2YoD1MEA/r4hAZV
xQIDAQAB
-----END PUBLIC KEY-----''';

/// Spies on how many times credentials are fetched from the store, so tests
/// can assert whether [EnableBankingAuth] reused its in-memory cache or
/// signed a fresh token.
class _CountingCredentialsStore extends EnableBankingCredentialsStore {
  int readConfigCalls = 0;

  @override
  Future<EnableBankingCredentials?> readCredentials() async {
    readConfigCalls++;
    return super.readCredentials();
  }
}

void main() {
  group('EnableBankingAuth.buildJwt', () {
    test('produces an RS256 token with the expected header and claims', () {
      final auth = EnableBankingAuth();
      const ttl = Duration(hours: 1);

      final token = auth.buildJwt(
        appId: _testAppId,
        privateKeyPem: _testPrivateKeyPem,
        ttl: ttl,
      );

      final decoded = JWT.decode(token);
      expect(decoded.header?['typ'], 'JWT');
      expect(decoded.header?['alg'], 'RS256');
      expect(decoded.header?['kid'], _testAppId);

      final payload = decoded.payload as Map;
      expect(payload['iss'], 'enablebanking.com');
      expect(payload['aud'], 'api.enablebanking.com');

      final iat = payload['iat'] as int;
      final exp = payload['exp'] as int;
      expect(exp - iat, greaterThan(0));
      expect(exp - iat, lessThanOrEqualTo(ttl.inSeconds));

      // Signature must verify against the matching public key.
      final verified = JWT.verify(token, RSAPublicKey(_testPublicKeyPem));
      expect(verified.payload['iss'], 'enablebanking.com');
    });

    test('throws EnableBankingAuthException on an unparsable PEM', () {
      final auth = EnableBankingAuth();

      expect(
        () => auth.buildJwt(appId: _testAppId, privateKeyPem: 'not a pem'),
        throwsA(isA<EnableBankingAuthException>()),
      );
    });
  });

  group('EnableBankingAuth.getValidToken', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
    });

    Future<_CountingCredentialsStore> storeWithCredentials() async {
      final store = _CountingCredentialsStore();
      await store.saveCredentials(
        appId: _testAppId,
        privateKeyPem: _testPrivateKeyPem,
        config: const EnableBankingConfig(appId: _testAppId),
      );
      return store;
    }

    test('throws when no credentials are configured', () {
      final store = _CountingCredentialsStore();
      final auth = EnableBankingAuth();

      expect(
        () => auth.getValidToken(store),
        throwsA(isA<EnableBankingAuthException>()),
      );
    });

    test('reuses the cached token within the refresh margin', () async {
      final store = await storeWithCredentials();
      var now = DateTime(2026);
      final auth = EnableBankingAuth(
        tokenTtl: const Duration(hours: 1),
        refreshMargin: const Duration(minutes: 5),
        now: () => now,
      );

      final first = await auth.getValidToken(store);
      now = now.add(const Duration(minutes: 30));
      final second = await auth.getValidToken(store);

      expect(second, first);
      expect(store.readConfigCalls, 1);
    });

    test('signs a fresh token once inside the refresh margin', () async {
      final store = await storeWithCredentials();
      var now = DateTime(2026);
      final auth = EnableBankingAuth(
        tokenTtl: const Duration(hours: 1),
        refreshMargin: const Duration(minutes: 5),
        now: () => now,
      );

      await auth.getValidToken(store);
      now = now.add(const Duration(minutes: 56));
      await auth.getValidToken(store);

      expect(store.readConfigCalls, 2);
    });

    test(
      'clearCache forces credentials to be read again after rotation',
      () async {
        final store = await storeWithCredentials();
        final auth = EnableBankingAuth();

        await auth.getValidToken(store);
        auth.clearCache();
        await auth.getValidToken(store);

        expect(store.readConfigCalls, 2);
      },
    );
  });
}
