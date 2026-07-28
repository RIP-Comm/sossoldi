import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sossoldi/services/banking/enable_banking_api.dart';
import 'package:sossoldi/services/banking/enable_banking_auth.dart';
import 'package:sossoldi/services/banking/enable_banking_config.dart';
import 'package:sossoldi/services/banking/enable_banking_credentials_store.dart';
import 'package:sossoldi/services/banking/enable_banking_exception.dart';

/// Bypasses credential/JWT signing entirely: the API client only needs a
/// valid bearer token string, not a real signature.
class _FakeAuth extends EnableBankingAuth {
  @override
  Future<String> getValidToken(EnableBankingCredentialsStore store) async =>
      'test-token';
}

EnableBankingApi _apiWith(MockClientHandler handler) => EnableBankingApi(
  auth: _FakeAuth(),
  store: const EnableBankingCredentialsStore(),
  client: MockClient(handler),
);

http.Response _json(Object body, {int statusCode = 200}) => http.Response(
  jsonEncode(body),
  statusCode,
  headers: {'content-type': 'application/json'},
);

void main() {
  group('EnableBankingApi', () {
    test('getAspsps sends auth/query headers and parses the list', () async {
      late http.Request captured;
      final api = _apiWith((request) async {
        captured = request;
        return _json({
          'aspsps': [
            {'name': 'Test Bank', 'country': 'IT'},
          ],
        });
      });

      final aspsps = await api.getAspsps(country: 'IT');

      expect(captured.method, 'GET');
      expect(captured.url.path, '/aspsps');
      expect(captured.url.queryParameters['country'], 'IT');
      expect(captured.url.queryParameters['psu_type'], 'personal');
      expect(captured.headers['Authorization'], 'Bearer test-token');
      expect(captured.headers['Content-Type'], 'application/json');
      expect(captured.headers['Accept'], 'application/json');
      expect(aspsps, hasLength(1));
      expect(aspsps.single.name, 'Test Bank');
    });

    test(
      'startAuthorization posts scope, redirect_url and UTC valid_until',
      () async {
        late http.Request captured;
        final api = _apiWith((request) async {
          captured = request;
          return _json({
            'url': 'https://bank.example/consent',
            'authorization_id': 'auth-1',
            'psu_id_hash': 'hash',
          });
        });

        final validUntil = DateTime.utc(2026, 8, 1, 12);
        final authorization = await api.startAuthorization(
          aspspName: 'Test Bank',
          aspspCountry: 'IT',
          state: 'csrf-state',
          validUntil: validUntil,
        );

        expect(captured.method, 'POST');
        expect(captured.url.path, '/auth');

        final body = jsonDecode(captured.body) as Map<String, dynamic>;
        expect(body['access'], {
          'valid_until': validUntil.toIso8601String(),
          'balances': true,
          'transactions': true,
        });
        expect(body['aspsp'], {'name': 'Test Bank', 'country': 'IT'});
        expect(body['state'], 'csrf-state');
        expect(body['redirect_url'], kEbRedirectUri);
        expect(body['psu_type'], 'personal');
        expect(body.containsKey('language'), isFalse);
        expect(authorization.url, 'https://bank.example/consent');
        expect(authorization.authorizationId, 'auth-1');
      },
    );

    test('createSession posts the code and parses the session', () async {
      late http.Request captured;
      final api = _apiWith((request) async {
        captured = request;
        return _json({
          'session_id': 'sess-1',
          'accounts': [],
          'aspsp': {'name': 'Test Bank', 'country': 'IT'},
          'access': {'valid_until': '2026-12-31T00:00:00.000Z'},
        });
      });

      final session = await api.createSession('auth-code');

      expect(captured.method, 'POST');
      expect(captured.url.path, '/sessions');
      expect(jsonDecode(captured.body), {'code': 'auth-code'});
      expect(session.sessionId, 'sess-1');
      expect(session.aspspName, 'Test Bank');
    });

    test('getSession issues a GET to /sessions/{id}', () async {
      late http.Request captured;
      final api = _apiWith((request) async {
        captured = request;
        return _json({
          'session_id': 'sess-1',
          'accounts': [],
          'aspsp': {'name': 'Test Bank', 'country': 'IT'},
          'access': {'valid_until': '2026-12-31T00:00:00.000Z'},
        });
      });

      final session = await api.getSession('sess-1');

      expect(captured.method, 'GET');
      expect(captured.url.path, '/sessions/sess-1');
      expect(session.sessionId, 'sess-1');
    });

    test('deleteSession issues a DELETE to /sessions/{id}', () async {
      late http.Request captured;
      final api = _apiWith((request) async {
        captured = request;
        return http.Response('', 204);
      });

      await api.deleteSession('sess-1');

      expect(captured.method, 'DELETE');
      expect(captured.url.path, '/sessions/sess-1');
    });

    test('getBalances parses the balances list', () async {
      final api = _apiWith(
        (request) async => _json({
          'balances': [
            {
              'name': 'closingBooked',
              'balance_amount': {'amount': '100.00', 'currency': 'EUR'},
              'balance_type': 'closingBooked',
            },
          ],
        }),
      );

      final balances = await api.getBalances('acc-uid');

      expect(balances, hasLength(1));
      expect(balances.single.balanceAmount.amount, 100.0);
      expect(balances.single.balanceAmount.currency, 'EUR');
    });

    test('getTransactions formats dates and forwards continuation_key, '
        'parses the envelope', () async {
      late http.Request captured;
      final api = _apiWith((request) async {
        captured = request;
        return _json({
          'transactions': [
            {
              'status': 'BOOK',
              'transaction_amount': {'amount': '12.50', 'currency': 'EUR'},
              'credit_debit_indicator': 'CRDT',
            },
          ],
          'continuation_key': 'next-page',
        });
      });

      final page = await api.getTransactions(
        'acc-uid',
        dateFrom: DateTime.utc(2026, 1, 5),
        dateTo: DateTime.utc(2026, 1, 31),
        continuationKey: 'prev-page',
        transactionStatus: 'BOOK',
      );

      expect(captured.url.path, '/accounts/acc-uid/transactions');
      expect(captured.url.queryParameters['date_from'], '2026-01-05');
      expect(captured.url.queryParameters['date_to'], '2026-01-31');
      expect(captured.url.queryParameters['continuation_key'], 'prev-page');
      expect(captured.url.queryParameters['transaction_status'], 'BOOK');
      expect(page.continuationKey, 'next-page');
      expect(page.transactions, hasLength(1));
      expect(page.transactions.single.signedAmount, 12.5);
    });

    test(
      'throws EnableBankingException with the decoded error body on 4xx',
      () async {
        final api = _apiWith(
          (request) async => _json({
            'error': 'invalid_request',
            'message': 'bad country',
          }, statusCode: 400),
        );

        await expectLater(
          () => api.getAspsps(country: 'XX'),
          throwsA(
            isA<EnableBankingException>()
                .having((e) => e.statusCode, 'statusCode', 400)
                .having((e) => e.error, 'error', 'invalid_request')
                .having((e) => e.message, 'message', 'bad country'),
          ),
        );
      },
    );

    test('flags a 401 response as unauthorized', () async {
      final api = _apiWith((request) async => http.Response('', 401));

      await expectLater(
        () => api.getBalances('acc-uid'),
        throwsA(
          isA<EnableBankingException>().having(
            (e) => e.isUnauthorized,
            'isUnauthorized',
            isTrue,
          ),
        ),
      );
    });
  });
}
