// dart format width=400

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sossoldi/model/bank_account.dart';
import 'package:sossoldi/model/bank_connection.dart';
import 'package:sossoldi/services/banking/banking_exception.dart';
import 'package:sossoldi/services/banking/banking_reference.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_api.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_auth.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_config.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_credentials_store.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_dependencies.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_provider.dart';
import 'package:sossoldi/services/banking/lifecycle/bank_authorization_callback.dart';
import 'package:sossoldi/services/banking/lifecycle/bank_consent_lifecycle_service.dart';
import 'package:sossoldi/services/banking/lifecycle/pending_bank_authorization_store.dart';
import 'package:sossoldi/services/database/migration_manager.dart';
import 'package:sossoldi/services/database/repositories/bank_connection_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _Auth extends EnableBankingAuth {
  @override
  Future<String> getValidToken(EnableBankingCredentialsStore store) async => 'synthetic';
}

void main() {
  const store = EnableBankingCredentialsStore();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('foundation adapters preserve relay, staging, account identities and revocation through SQLite', () async {
    sqfliteFfiInit();
    final manager = MigrationManager();
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(version: manager.latestVersion, onCreate: (db, version) => manager.migrate(db, 0, version)),
    );
    addTearDown(db.close);
    await store.saveCredentials(
      appId: 'app',
      privateKeyPem: 'synthetic',
      config: const EnableBankingConfig(appId: 'app', redirectUri: kEbRelayRedirectUri, redirectUrls: [kEbRelayRedirectUri]),
    );
    final requests = <String>[];
    final remote = EnableBankingProvider(
      EnableBankingApi(
        auth: _Auth(),
        store: store,
        client: MockClient((request) async {
          final route = '${request.method} ${request.url.path}';
          requests.add(route);
          final body = switch (route) {
            'GET /aspsps' => {
              'aspsps': [
                {
                  'name': 'Bank',
                  'country': 'IT',
                  'psu_types': ['personal'],
                  'maximum_consent_validity': 86400,
                },
              ],
            },
            'POST /auth' => {'url': 'https://bank.example/consent', 'authorization_id': 'auth', 'psu_id_hash': 'psu'},
            'POST /sessions' => {
              'session_id': 'session',
              'aspsp': {'name': 'Bank', 'country': 'IT'},
              'psu_type': 'personal',
              'access': {'valid_until': '2026-10-01T00:00:00Z'},
              'accounts': [
                {
                  'uid': 'account',
                  'identification_hash': ' primary ',
                  'identification_hashes': ['alias', ''],
                  'account_id': {'iban': 'IT00SYNTHETIC'},
                },
              ],
            },
            'GET /sessions/session' => {
              'status': 'AUTHORIZED',
              'aspsp': {'name': 'Bank', 'country': 'IT'},
              'psu_type': 'personal',
              'access': {'valid_until': '2026-10-01T00:00:00Z'},
              'created': '2026-09-11T00:00:00Z',
              'accounts': ['account'],
              'accounts_data': [
                {
                  'uid': 'account',
                  'identification_hashes': ['alias'],
                },
              ],
            },
            'DELETE /sessions/session' => <String, Object?>{},
            _ => throw StateError('Unexpected request $route'),
          };
          if (route == 'POST /auth') {
            final posted = jsonDecode(request.body) as Map<String, dynamic>;
            expect(posted['redirect_url'], kEbRelayRedirectUri);
            expect(posted['psu_type'], 'personal');
          }
          if (route == 'POST /sessions') expect(jsonDecode(request.body), {'code': ' code-preserved '});
          return http.Response(jsonEncode(body), 200);
        }),
      ),
    );
    final repository = BankConnectionRepository.withDatabase(db);
    BankConsentLifecycleService lifecycle() => BankConsentLifecycleService(consent: remote.consent, institutions: remote.institutions, readContext: () => readEnableBankingAuthorizationContext(store), pendingStore: const SecurePendingBankAuthorizationStore(), connections: repository, clock: () => DateTime.utc(2026, 9, 11), callbackSupported: () => true);
    await lifecycle().startAuthorization((await remote.institutions.getInstitutions()).single);
    final pending = await const SecurePendingBankAuthorizationStore().read();
    final staged = await lifecycle().completeCallback(BankAuthorizationCallback(code: ' code-preserved ', state: pending!.state));
    expect(staged.connection.providerId, 'enable_banking');
    final resumed = (await lifecycle().resumeAwaitingImports()).single;
    expect(resumed.details.accounts.single.identityKeys, {'alias'});
    final active = await lifecycle().activateConnection(staged.connection.id!, [(remote: staged.createdConnection!.accounts.single, newAccount: const BankAccount(name: 'Imported', symbol: 'wallet', color: 1, startingValue: 0, active: true, countNetWorth: true, mainAccount: false, order: 0))]);
    expect(active.status, BankConnectionStatus.active);
    final account = (await db.query(bankAccountTable)).single;
    expect(account[BankAccountFields.ebAccountUid], 'account');
    final identities = await db.query(bankAccountIdentityTable);
    expect(identities.map((row) => row[BankAccountIdentityFields.identificationHash]).toSet(), {'primary', 'alias'});
    await lifecycle().revoke(active);
    expect((await repository.selectById(active.id!)).status, BankConnectionStatus.revoked);
    expect(requests.where((route) => route == 'POST /sessions'), hasLength(1));
    expect(await const SecurePendingBankAuthorizationStore().read(), isNull);
  });

  for (final entry in {'EXPIRED_SESSION': BankingFailure.connectionExpired, 'REVOKED_SESSION': BankingFailure.connectionRevoked, 'CLOSED_SESSION': BankingFailure.connectionClosed}.entries) {
    test('adapter preserves ${entry.key} independently of HTTP 401', () async {
      final provider = EnableBankingProvider(EnableBankingApi(auth: _Auth(), store: store, client: MockClient((_) async => http.Response(jsonEncode({'error': entry.key}), 401))));
      await expectLater(provider.consent.getConnection(const BankingConnectionReference(providerId: 'enable_banking', remoteId: 'session')), throwsA(isA<BankingException>().having((error) => error.failure, 'failure', entry.value)));
    });
  }

  test('missing credentials are reported through the generic context boundary', () async {
    await expectLater(readEnableBankingAuthorizationContext(store), throwsA(isA<BankingException>().having((error) => error.failure, 'failure', BankingFailure.authentication)));
  });
}
