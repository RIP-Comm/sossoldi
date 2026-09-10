// dart format width=400

import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sossoldi/providers/banking_provider.dart' as providers;
import 'package:sossoldi/services/banking/bank_account_data_source.dart';
import 'package:sossoldi/services/banking/bank_consent_service.dart';
import 'package:sossoldi/services/banking/bank_institution.dart';
import 'package:sossoldi/services/banking/bank_institution_directory.dart';
import 'package:sossoldi/services/banking/banking_account.dart';
import 'package:sossoldi/services/banking/banking_authorization.dart';
import 'package:sossoldi/services/banking/banking_balance.dart';
import 'package:sossoldi/services/banking/banking_connection.dart';
import 'package:sossoldi/services/banking/banking_exception.dart';
import 'package:sossoldi/services/banking/banking_money.dart';
import 'package:sossoldi/services/banking/banking_provider.dart';
import 'package:sossoldi/services/banking/banking_reference.dart';
import 'package:sossoldi/services/banking/banking_transaction.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_api.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_auth.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_credentials_store.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_provider.dart';

class _Auth extends EnableBankingAuth {
  @override
  Future<String> getValidToken(EnableBankingCredentialsStore store) async => 'test';
}

BankingProvider _provider(MockClientHandler handler) {
  final client = MockClient(handler);
  addTearDown(client.close);
  return EnableBankingProvider(EnableBankingApi(auth: _Auth(), store: const EnableBankingCredentialsStore(), client: client));
}

http.Response _json(Object value, {int status = 200}) => http.Response(jsonEncode(value), status);
Map<String, dynamic> _fixture(String name) => jsonDecode(File('test/fixtures/$name.json').readAsStringSync()) as Map<String, dynamic>;
final _account = BankingAccountReference(providerId: 'enable_banking', remoteId: 'acc-uid-123');
const _connection = BankingConnectionReference(providerId: 'enable_banking', remoteId: 'session');
Matcher _failure(BankingFailure failure) => isA<BankingException>().having((error) => error.failure, 'failure', failure);

class _Directory implements BankInstitutionDirectory {
  @override
  Future<List<BankInstitution>> getInstitutions({String? country, BankingCustomerType customerType = BankingCustomerType.personal}) async => [BankInstitution(providerId: 'alternative', id: 'bank', name: 'Alternative', country: country ?? 'IT')];
}

class _Data implements BankAccountDataSource {
  @override
  Future<BankingAccount> getAccount(BankingAccountReference reference) async => BankingAccount(reference: reference, name: 'Alternative account', currency: 'EUR');
  @override
  Future<List<BankingBalance>> getBalances(BankingAccountReference reference) async => [
    BankingBalance(
      name: 'Booked',
      amount: BankingMoney(decimalAmount: '232.75', currency: 'EUR'),
      kind: BankingBalanceKind.interimBooked,
    ),
  ];
  @override
  Future<BankingTransactionsPage> getTransactions(BankingAccountReference reference, {BankingTransactionQuery query = const BankingTransactionQuery()}) async => BankingTransactionsPage(transactions: []);
}

class _Consent implements BankConsentService {
  BankingConnectionStatus status = BankingConnectionStatus.active;
  @override
  Future<BankingAuthorization> startAuthorization(BankingAuthorizationRequest request) async => BankingAuthorization(providerId: 'alternative', authorizationId: 'auth', uri: Uri.https('example.com', '/consent'));
  @override
  Future<BankingConnectionResult> createConnection(String authorizationCode) async => BankingConnectionResult(
    connection: await getConnection(const BankingConnectionReference(providerId: 'alternative', remoteId: 'session')),
    accounts: [],
  );
  @override
  Future<BankingConnection> getConnection(BankingConnectionReference reference) async => BankingConnection(reference: reference, institution: (await _Directory().getInstitutions()).single, validUntil: DateTime.utc(2027), status: status, accounts: []);
  @override
  Future<void> revokeConnection(BankingConnectionReference reference) async {
    status = BankingConnectionStatus.revoked;
  }
}

class _Alternative implements BankingProvider {
  @override
  String get id => 'alternative';
  @override
  final institutions = _Directory();
  @override
  final consent = _Consent();
  @override
  final accountData = _Data();
}

void main() {
  test('composition exposes three replaceable capabilities without EB credentials', () async {
    final alternative = _Alternative();
    final container = ProviderContainer(overrides: [providers.bankingServiceProvider.overrideWithValue(alternative)]);
    addTearDown(container.dispose);
    final directory = container.read(providers.bankInstitutionDirectoryProvider);
    final consent = container.read(providers.bankConsentServiceProvider);
    final data = container.read(providers.bankAccountDataSourceProvider);
    expect(directory, same(alternative.institutions));
    expect(consent, same(alternative.consent));
    expect(data, same(alternative.accountData));
    final bank = (await directory.getInstitutions()).single;
    expect((await consent.startAuthorization(BankingAuthorizationRequest(institution: bank, validUntil: DateTime.utc(2027), state: 'state'))).providerId, 'alternative');
    final result = await consent.createConnection('alternative-code');
    expect(result.connection.status, BankingConnectionStatus.active);
    final account = BankingAccountReference(providerId: 'alternative', remoteId: 'account');
    expect((await data.getAccount(account)).name, 'Alternative account');
    expect((await data.getBalances(account)).single.amount.decimalAmount, '232.75');
    expect((await data.getTransactions(account)).transactions, isEmpty);
    await consent.revokeConnection(result.connection.reference);
    expect((await consent.getConnection(result.connection.reference)).status, BankingConnectionStatus.revoked);
    expect(data, isNot(isA<BankConsentService>()));
  });

  test('data dependency can be replaced independently without constructing the provider', () async {
    final container = ProviderContainer(overrides: [providers.bankAccountDataSourceProvider.overrideWithValue(_Data()), providers.bankingServiceProvider.overrideWith((ref) => throw StateError('Unexpected provider access'))]);
    addTearDown(container.dispose);
    final data = container.read(providers.bankAccountDataSourceProvider);
    expect((await data.getBalances(_account)).single.amount.decimalAmount, '232.75');
  });

  test('authorization uses only consent capability and preserves state and inputs', () async {
    final provider = _provider((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/auth');
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['aspsp'], {'name': 'Test Bank', 'country': 'IT'});
      expect(body['state'], 'stored-state');
      expect(body['psu_type'], 'business');
      expect(body['language'], 'it');
      expect(body['access']['valid_until'], '2027-01-01T00:00:00.000Z');
      expect(body['redirect_url'], 'sossoldi://eb-callback');
      return _json({'url': 'https://example.com/consent', 'authorization_id': 'auth', 'psu_id_hash': 'internal'});
    });
    final consent = provider.consent;
    expect(consent, isNot(isA<BankAccountDataSource>()));
    final bank = BankInstitution(providerId: provider.id, id: 'bank', name: 'Test Bank', country: 'IT');
    final result = await consent.startAuthorization(BankingAuthorizationRequest(institution: bank, validUntil: DateTime.utc(2027), state: 'stored-state', customerType: BankingCustomerType.business, language: 'it'));
    expect(result.authorizationId, 'auth');
    expect(result.uri, Uri.parse('https://example.com/consent'));
  });

  test('creation returns account details and rereading preserves reference-only semantics', () async {
    final provider = _provider((request) async {
      if (request.method == 'POST') {
        expect(request.url.path, '/sessions');
        expect(jsonDecode(request.body), {'code': 'verified-code'});
        return _json(_fixture('eb_session'));
      }
      expect(request.url.path, '/sessions/sess-789');
      return _json(_fixture('eb_get_session'));
    });
    final result = await provider.consent.createConnection('verified-code');
    expect(result.connection.reference.remoteId, 'sess-789');
    expect(result.accounts.single.name, 'Main Account');
    expect(result.accounts.single.reference.identityKeys, {'idhash-abc'});
    expect(result.connection.accounts.single, result.accounts.single.reference);
    final reread = await provider.consent.getConnection(result.connection.reference);
    expect(reread.reference, result.connection.reference);
    expect(reread.status, BankingConnectionStatus.active);
    expect(reread.institution.name, 'Nordea');
    expect(reread.accounts.single.identityKeys, {'primary-hash', 'alternate-hash'});
    expect(reread.isExpiredAt(reread.validUntil), isTrue);
    expect(reread.isExpiredAt(reread.validUntil.subtract(const Duration(seconds: 1))), isFalse);
    expect(() => result.accounts.clear(), throwsUnsupportedError);
    expect(() => reread.accounts.single.identityKeys.clear(), throwsUnsupportedError);
  });

  for (final code in ['', '   ']) {
    test('empty authorization code is rejected before HTTP: "$code"', () async {
      var requests = 0;
      final service = _provider((_) async {
        requests++;
        return _json({});
      }).consent;
      await expectLater(service.createConnection(code), throwsA(_failure(BankingFailure.rejected)));
      expect(requests, 0);
    });
  }

  for (final entry in {
    'AUTHORIZED': BankingConnectionStatus.active,
    'PENDING_AUTHORIZATION': BankingConnectionStatus.pending,
    'RETURNED_FROM_BANK': BankingConnectionStatus.pending,
    'CANCELLED': BankingConnectionStatus.cancelled,
    'CLOSED': BankingConnectionStatus.closed,
    'EXPIRED': BankingConnectionStatus.expired,
    'INVALID': BankingConnectionStatus.invalid,
    'REVOKED': BankingConnectionStatus.revoked,
  }.entries) {
    test('maps connection state ${entry.key}', () async {
      final service = _provider((_) async => _json({..._fixture('eb_get_session'), 'status': entry.key})).consent;
      expect((await service.getConnection(_connection)).status, entry.value);
    });
  }

  test('unknown connection state fails closed', () async {
    final service = _provider((_) async => _json({..._fixture('eb_get_session'), 'status': 'FUTURE'})).consent;
    await expectLater(service.getConnection(_connection), throwsA(_failure(BankingFailure.invalidResponse)));
  });

  test('remote revoke propagates errors instead of reporting local success', () async {
    var requests = 0;
    final service = _provider((request) async {
      requests++;
      expect(request.method, 'DELETE');
      expect(request.url.path, '/sessions/session');
      return _json({}, status: requests == 1 ? 200 : 503);
    }).consent;
    await service.revokeConnection(_connection);
    await expectLater(service.revokeConnection(_connection), throwsA(_failure(BankingFailure.unavailable)));
  });

  test('foreign provider references cannot invoke any remote operation', () async {
    var requests = 0;
    final provider = _provider((_) async {
      requests++;
      return _json({});
    });
    const connection = BankingConnectionReference(providerId: 'other', remoteId: 'session');
    final account = BankingAccountReference(providerId: 'other', remoteId: 'account');
    final bank = BankInstitution(providerId: 'other', id: 'bank', name: 'Bank', country: 'IT');
    for (final operation in <Future<Object?> Function()>[
      () => provider.consent.startAuthorization(BankingAuthorizationRequest(institution: bank, validUntil: DateTime.utc(2027), state: 'state')),
      () => provider.consent.getConnection(connection),
      () => provider.consent.revokeConnection(connection),
      () => provider.accountData.getAccount(account),
      () => provider.accountData.getBalances(account),
      () => provider.accountData.getTransactions(account),
    ]) {
      await expectLater(operation(), throwsA(_failure(BankingFailure.rejected)));
    }
    expect(requests, 0);
  });

  test('account detail request preserves all known reconnect identities', () async {
    final service = _provider((request) async {
      expect(request.url.path, '/accounts/acc-uid-123/details');
      return _json({
        ..._fixture('eb_account'),
        'uid': _account.remoteId,
        'identification_hashes': ['alternate', 'idhash-abc'],
      });
    }).accountData;
    final account = await service.getAccount(_account);
    expect(account.reference, _account);
    expect(account.reference.identityKeys, contains('alternate'));
    expect(account.iban, isNotNull);
  });

  test('account response for another UID is rejected', () async {
    final service = _provider((_) async => _json({..._fixture('eb_account'), 'uid': 'other'})).accountData;
    await expectLater(service.getAccount(_account), throwsA(_failure(BankingFailure.invalidResponse)));
  });

  test('balance projection preserves precision, kind and reconciliation anchor', () async {
    final service = _provider(
      (_) async => _json({
        'balances': [
          {
            'name': 'Booked',
            'balance_amount': {'amount': '9007199254740993.01', 'currency': 'EUR'},
            'balance_type': 'ITBD',
            'reference_date': '2026-09-09',
            'last_change_date_time': '2026-09-09T10:00:00Z',
            'last_committed_transaction': 'entry',
          },
          {
            'name': 'Available',
            'balance_amount': {'amount': '-10.10', 'currency': 'EUR'},
            'balance_type': 'ITAV',
          },
          {
            'name': 'Other',
            'balance_amount': {'amount': '10', 'currency': 'EUR'},
            'balance_type': 'FUTURE',
          },
        ],
      }),
    ).accountData;
    final balances = await service.getBalances(_account);
    expect(balances.first.amount.decimalAmount, '9007199254740993.01');
    expect(balances.first.kind, BankingBalanceKind.interimBooked);
    expect(balances.first.lastCommittedEntryId, 'entry');
    expect(balances.first.observedAt, DateTime.utc(2026, 9, 9, 10));
    expect(balances[1].kind, BankingBalanceKind.available);
    expect(balances[1].amount.decimalAmount, '-10.10');
    expect(balances[2].kind, BankingBalanceKind.other);
    expect(balances[2].observedAt, isNull);
    expect(() => balances.clear(), throwsUnsupportedError);
  });

  test('transaction filters, pagination, separate IDs and exact amount cross the boundary', () async {
    final service = _provider((request) async {
      expect(request.url.queryParameters, {'date_from': '2026-01-01', 'date_to': '2026-01-31', 'continuation_key': 'opaque+/cursor', 'transaction_status': 'BOOK'});
      return _json({
        'transactions': [
          {
            'entry_reference': 'entry',
            'transaction_id': 'transaction',
            'status': 'BOOK',
            'booking_date': '2026-01-02',
            'credit_debit_indicator': 'DBIT',
            'transaction_amount': {'amount': '9007199254740993.01', 'currency': 'EUR'},
            'remittance_information': ['invoice'],
          },
          {
            'status': 'FUTURE',
            'credit_debit_indicator': 'FUTURE',
            'transaction_amount': {'amount': '1.00', 'currency': 'EUR'},
          },
        ],
        'continuation_key': 'next',
      });
    }).accountData;
    final page = await service.getTransactions(
      _account,
      query: BankingTransactionQuery(dateFrom: DateTime(2026, 1, 1), dateTo: DateTime(2026, 1, 31), cursor: 'opaque+/cursor', status: BankingTransactionStatus.booked),
    );
    expect(page.nextCursor, 'next');
    expect(page.transactions.first.entryId, 'entry');
    expect(page.transactions.first.transactionId, 'transaction');
    expect(page.transactions.first.amount.decimalAmount, '9007199254740993.01');
    expect(page.transactions.first.direction, BankingDirection.debit);
    expect(page.transactions.last.direction, BankingDirection.unknown);
    expect(page.transactions.last.status, BankingTransactionStatus.unknown);
    expect(() => page.transactions.clear(), throwsUnsupportedError);
    expect(() => page.transactions.first.remittanceInformation.clear(), throwsUnsupportedError);
  });

  for (final record in [
    {'booking_date': '2026-02-30', 'amount': '1.00'},
    {'booking_date': 'not-a-date', 'amount': '1.00'},
    {'booking_date': '2026-01-01', 'amount': 'NaN'},
    {'booking_date': '2026-01-01', 'amount': '-1.00'},
  ]) {
    test('invalid transaction cannot silently disappear: $record', () async {
      final service = _provider(
        (_) async => _json({
          'transactions': [
            {
              'status': 'BOOK',
              'booking_date': record['booking_date'],
              'credit_debit_indicator': 'DBIT',
              'transaction_amount': {'amount': record['amount'], 'currency': 'EUR'},
            },
          ],
        }),
      ).accountData;
      await expectLater(service.getTransactions(_account), throwsA(_failure(BankingFailure.invalidResponse)));
    });
  }

  test('missing transaction envelope fails instead of reporting no transactions', () async {
    final service = _provider((_) async => _json({})).accountData;
    await expectLater(service.getTransactions(_account), throwsA(_failure(BankingFailure.invalidResponse)));
  });

  test('invalid filter is rejected without an HTTP call', () async {
    var requests = 0;
    final service = _provider((_) async {
      requests++;
      return _json({});
    }).accountData;
    await expectLater(service.getTransactions(_account, query: const BankingTransactionQuery(status: BankingTransactionStatus.unknown)), throwsA(_failure(BankingFailure.rejected)));
    await expectLater(
      service.getTransactions(
        _account,
        query: BankingTransactionQuery(dateFrom: DateTime(2026, 2), dateTo: DateTime(2026, 1)),
      ),
      throwsA(_failure(BankingFailure.rejected)),
    );
    expect(requests, 0);
  });

  test('opaque remote identifiers cannot inject extra URL path segments', () async {
    final service = _provider((request) async {
      expect(request.url.pathSegments, ['sessions', 'opaque/part?query']);
      expect(request.url.hasQuery, isFalse);
      return _json({});
    }).consent;
    await service.revokeConnection(const BankingConnectionReference(providerId: 'enable_banking', remoteId: 'opaque/part?query'));
  });

  test('unsafe authorization URL is not exposed to the app', () async {
    final service = _provider((_) async => _json({'url': 'http://example.com/consent', 'authorization_id': 'auth', 'psu_id_hash': 'internal'})).consent;
    final bank = BankInstitution(providerId: 'enable_banking', id: 'bank', name: 'Bank', country: 'IT');
    await expectLater(service.startAuthorization(BankingAuthorizationRequest(institution: bank, validUntil: DateTime.utc(2027), state: 'state')), throwsA(_failure(BankingFailure.invalidResponse)));
  });

  test('empty state and unsafe references are refused before networking', () async {
    var requests = 0;
    final provider = _provider((_) async {
      requests++;
      return _json({});
    });
    final bank = BankInstitution(providerId: provider.id, id: 'bank', name: 'Bank', country: 'IT');
    await expectLater(provider.consent.startAuthorization(BankingAuthorizationRequest(institution: bank, validUntil: DateTime.utc(2027), state: '')), throwsA(_failure(BankingFailure.rejected)));
    for (final id in ['', ' ', '.', '..']) {
      await expectLater(provider.consent.getConnection(BankingConnectionReference(providerId: provider.id, remoteId: id)), throwsA(_failure(BankingFailure.rejected)));
      await expectLater(provider.accountData.getBalances(BankingAccountReference(providerId: provider.id, remoteId: id)), throwsA(_failure(BankingFailure.rejected)));
    }
    expect(requests, 0);
  });

  test('missing balance list and malformed timestamp fail instead of producing a usable balance', () async {
    for (final body in [
      <String, dynamic>{},
      {
        'balances': [
          {
            'name': 'Booked',
            'balance_amount': {'amount': '1.00', 'currency': 'EUR'},
            'last_change_date_time': '2026-02-30T00:00:00Z',
          },
        ],
      },
    ]) {
      final service = _provider((_) async => _json(body)).accountData;
      await expectLater(service.getBalances(_account), throwsA(_failure(BankingFailure.invalidResponse)));
    }
  });

  test('authentication failure reading data is not treated as an expired consent', () async {
    final service = _provider((_) async => _json({'message': 'private detail'}, status: 401)).accountData;
    await expectLater(service.getBalances(_account), throwsA(_failure(BankingFailure.authentication)));
  });

  test('provider is part of remote identity and account identities are copied', () {
    final identities = ['primary'];
    final first = BankingAccountReference(providerId: 'one', remoteId: 'account', identityKeys: identities);
    identities.add('mutated');
    final same = BankingAccountReference(providerId: 'one', remoteId: 'account', identityKeys: ['alternative']);
    expect(first.identityKeys, {'primary'});
    expect(first, same);
    expect(first.hashCode, same.hashCode);
    expect(first, isNot(BankingAccountReference(providerId: 'two', remoteId: 'account')));
    expect(const BankingConnectionReference(providerId: 'one', remoteId: 'session'), isNot(const BankingConnectionReference(providerId: 'two', remoteId: 'session')));
  });

  test('banking domain remains independent of frameworks and persistence', () {
    for (final file in Directory('lib/services/banking').listSync().whereType<File>().where((file) => file.path.endsWith('.dart'))) {
      final imports = RegExp(r'''import\s+['"]([^'"]+)['"]''').allMatches(file.readAsStringSync()).map((match) => match.group(1)!);
      expect(imports.any((path) => path.startsWith('package:') || path.contains('enable_banking/') || path.contains('database/') || path.contains('providers/')), isFalse, reason: file.path);
    }
    for (final name in ['enable_banking_institution_directory.dart', 'enable_banking_consent_service.dart', 'enable_banking_account_data_source.dart']) {
      final source = File('lib/services/banking/enable_banking/$name').readAsStringSync();
      expect(source.contains('database/'), isFalse);
      expect(source.contains('banking_provider.dart'), isFalse);
      expect(source.contains('enable_banking_credentials_store.dart'), isFalse);
    }
  });
}
