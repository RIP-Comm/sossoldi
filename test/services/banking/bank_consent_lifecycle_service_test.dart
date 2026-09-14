// dart format width=400

import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/model/bank_connection.dart';
import 'package:sossoldi/services/banking/bank_authorization_context.dart';
import 'package:sossoldi/services/banking/bank_consent_service.dart';
import 'package:sossoldi/services/banking/bank_institution.dart';
import 'package:sossoldi/services/banking/bank_institution_directory.dart';
import 'package:sossoldi/services/banking/banking_authorization.dart';
import 'package:sossoldi/services/banking/banking_connection.dart';
import 'package:sossoldi/services/banking/banking_exception.dart';
import 'package:sossoldi/services/banking/banking_reference.dart';
import 'package:sossoldi/services/banking/lifecycle/bank_authorization_callback.dart';
import 'package:sossoldi/services/banking/lifecycle/bank_consent_lifecycle_service.dart';
import 'package:sossoldi/services/banking/lifecycle/pending_bank_authorization.dart';
import 'package:sossoldi/services/banking/lifecycle/pending_bank_authorization_store.dart';
import 'package:sossoldi/services/database/migration_manager.dart';
import 'package:sossoldi/services/database/repositories/bank_connection_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _MemoryPendingStore implements PendingBankAuthorizationStore {
  PendingBankAuthorization? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<PendingBankAuthorization?> read() async => value;

  @override
  Future<void> save(PendingBankAuthorization pending) async => value = pending;
}

class _FakeApi implements BankConsentService, BankInstitutionDirectory {
  List<BankInstitution> aspsps = [];
  Object? createFailure;
  Object? deleteFailure;
  Object? getSessionFailure;
  DateTime validUntil = DateTime.utc(2026, 10, 1);
  BankingConnectionStatus sessionStatus = BankingConnectionStatus.active;
  int createCalls = 0;
  int startCalls = 0;
  int deleteCalls = 0;
  DateTime? requestedValidUntil;

  @override
  Future<List<BankInstitution>> getInstitutions({String? country, BankingCustomerType customerType = BankingCustomerType.personal}) async => aspsps;

  @override
  Future<BankingAuthorization> startAuthorization(BankingAuthorizationRequest request) async {
    startCalls++;
    requestedValidUntil = request.validUntil;
    return BankingAuthorization(providerId: 'alternative', uri: Uri.parse('https://bank.example/authorize'), authorizationId: 'authorization-id');
  }

  BankingConnection connection(String id) => BankingConnection(
    reference: BankingConnectionReference(providerId: 'alternative', remoteId: id),
    institution: bank(),
    validUntil: validUntil,
    status: sessionStatus,
    accounts: [],
  );

  @override
  Future<BankingConnectionResult> createConnection(String code) async {
    createCalls++;
    if (createFailure case final failure?) throw failure;
    return BankingConnectionResult(connection: connection('session-new'), accounts: []);
  }

  @override
  Future<BankingConnection> getConnection(BankingConnectionReference reference) async {
    expect(reference.providerId, 'alternative');
    if (getSessionFailure case final failure?) throw failure;
    return connection(reference.remoteId);
  }

  @override
  Future<void> revokeConnection(BankingConnectionReference reference) async {
    expect(reference.providerId, 'alternative');
    deleteCalls++;
    if (deleteFailure case final failure?) throw failure;
  }
}

BankInstitution bank({String name = 'Test Bank', String country = 'IT', Set<BankingCustomerType> customerTypes = const {BankingCustomerType.personal}, Duration? maximumConsentDuration}) => BankInstitution(providerId: 'alternative', id: '$country:$name', name: name, country: country, customerTypes: customerTypes, maximumConsentDuration: maximumConsentDuration);

void main() {
  late Database db;
  late BankConnectionRepository repository;
  BankAuthorizationContext context = const BankAuthorizationContext(providerId: 'alternative', applicationId: 'app-id', redirectUri: 'sossoldi://eb-callback');
  late _MemoryPendingStore pending;
  late _FakeApi api;
  final now = DateTime.utc(2026, 9, 1, 12);

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    context = const BankAuthorizationContext(providerId: 'alternative', applicationId: 'app-id', redirectUri: 'sossoldi://eb-callback');
    final manager = MigrationManager();
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(version: manager.latestVersion, onCreate: (database, version) => manager.migrate(database, 0, version)),
    );
    repository = BankConnectionRepository.withDatabase(db);
    pending = _MemoryPendingStore();
    api = _FakeApi();
    api.aspsps = [
      bank(name: 'Test Bank', country: 'IT', customerTypes: {BankingCustomerType.personal}, maximumConsentDuration: const Duration(seconds: 86400)),
    ];
  });

  tearDown(() => db.close());

  BankConsentLifecycleService service() => BankConsentLifecycleService(consent: api, institutions: api, readContext: () async => context, pendingStore: pending, connections: repository, clock: () => now, callbackSupported: () => true);

  test('reconnect reloads metadata and clamps requested validity', () async {
    final connection = await repository.insert(BankConnection(providerId: 'alternative', institutionName: 'Test Bank', institutionCountry: 'IT', applicationId: 'app-id', remoteConnectionId: 'old-session', validUntil: now.add(const Duration(days: 1)), status: BankConnectionStatus.active));

    final attempt = await service().startAuthorization(
      bank(name: 'Test Bank', country: 'IT', customerTypes: {BankingCustomerType.personal}, maximumConsentDuration: const Duration(seconds: 7776000)),
      reconnectConnectionId: connection.id,
    );

    expect(api.requestedValidUntil, now.add(const Duration(days: 1)));

    expect(attempt.url.scheme, 'https');
    expect(pending.value?.reconnectConnectionId, connection.id);
  });

  test('cold-start callback stages session and duplicate is idempotent', () async {
    await service().startAuthorization(api.aspsps.single);
    final state = pending.value!.state;

    final restarted = service();
    final first = await restarted.completeCallback(BankAuthorizationCallback(code: 'code', state: state));
    final duplicate = await restarted.completeCallback(BankAuthorizationCallback(code: 'code', state: state));

    expect(first.connection.status, BankConnectionStatus.awaitingImport);
    expect(first.connection.remoteConnectionId, isNull);
    expect(first.connection.pendingRemoteConnectionId, 'session-new');
    expect(duplicate.connection.id, first.connection.id);
    expect(api.createCalls, 1);
    expect(pending.value?.phase, PendingAuthorizationPhase.connectionStaged);
    expect((await restarted.resumeAwaitingImports()).single.connection.id, first.connection.id);
  });

  test('failed staged reconnect keeps the previous session active', () async {
    final connection = await repository.insert(BankConnection(providerId: 'alternative', institutionName: 'Test Bank', institutionCountry: 'IT', applicationId: 'app-id', remoteConnectionId: 'session-old', validUntil: now.add(const Duration(days: 1)), status: BankConnectionStatus.active));
    await service().startAuthorization(api.aspsps.single, reconnectConnectionId: connection.id);
    await service().completeCallback(BankAuthorizationCallback(code: 'code', state: pending.value!.state));
    api.sessionStatus = BankingConnectionStatus.expired;

    expect(await service().resumeAwaitingImports(), isEmpty);

    final restored = await repository.selectById(connection.id!);
    expect(restored.status, BankConnectionStatus.active);
    expect(restored.remoteConnectionId, 'session-old');
    expect(restored.pendingRemoteConnectionId, isNull);
    expect(pending.value, isNull);
  });

  test('retryable callback failure remains pending and can be retried', () async {
    await service().startAuthorization(api.aspsps.single);
    final callback = BankAuthorizationCallback(code: 'code', state: pending.value!.state);
    api.createFailure = const BankingException(providerId: 'alternative', failure: BankingFailure.unavailable);

    expect(await service().handleCallback(callback), BankCallbackDisposition.retryable);
    expect(pending.value, isNotNull);
    api.createFailure = null;
    expect(await service().handleCallback(callback), BankCallbackDisposition.terminal);
    expect(api.createCalls, 2);
  });

  test('duplicate authorization start reuses one pending attempt', () async {
    final first = await service().startAuthorization(api.aspsps.single);
    final second = await service().startAuthorization(api.aspsps.single);

    expect(second.url, first.url);
    expect(second.consentValidUntil, first.consentValidUntil);
    expect(api.startCalls, 1);
  });

  test('authorization uses the default validity when no limit exists', () async {
    await service().startAuthorization(bank(name: 'Test Bank', country: 'IT', customerTypes: {BankingCustomerType.personal}));

    expect(api.requestedValidUntil, now.add(const Duration(days: 90)));
  });

  test('business-only banks are rejected before authorization', () async {
    await expectLater(() => service().startAuthorization(bank(name: 'Corporate Bank', country: 'IT', customerTypes: {BankingCustomerType.business})), throwsA(isA<BankingException>().having((error) => error.failure, 'kind', BankingFailure.rejected)));
    expect(api.startCalls, 0);
  });

  test('expired and mismatched callbacks never exchange the code', () async {
    await service().startAuthorization(api.aspsps.single);
    final state = pending.value!.state;

    await expectLater(() => service().completeCallback(const BankAuthorizationCallback(code: 'code', state: 'wrong')), throwsA(isA<BankingException>()));
    expect(api.createCalls, 0);
    pending.value = PendingBankAuthorization(providerId: 'alternative', state: state, authorizationId: 'authorization-id', authorizationUrl: 'https://bank.example/authorize', applicationId: 'app-id', institutionName: 'Test Bank', institutionCountry: 'IT', redirectUri: 'sossoldi://eb-callback', expiresAt: now, consentValidUntil: now.add(const Duration(days: 1)));
    await expectLater(() => service().completeCallback(BankAuthorizationCallback(code: 'code', state: state)), throwsA(isA<BankingException>().having((error) => error.failure, 'kind', BankingFailure.connectionExpired)));
    expect(pending.value, isNull);
  });

  test('failed browser launch preserves retry URL until explicit cancel', () async {
    await service().startAuthorization(api.aspsps.single);
    final url = Uri.parse(pending.value!.authorizationUrl);

    final result = await service().launchAuthorization(url, launcher: (_) async => false);

    expect(result.opened, isFalse);
    expect(result.url, url);
    expect(pending.value, isNotNull);
    await service().cancelAuthorization();
    expect(pending.value, isNull);
  });

  test('retryable revocation stays pending while not-found finalizes', () async {
    final connection = await repository.insert(BankConnection(providerId: 'alternative', institutionName: 'Test Bank', institutionCountry: 'IT', applicationId: 'app-id', remoteConnectionId: 'session', validUntil: now.add(const Duration(days: 1)), status: BankConnectionStatus.active));
    for (final kind in const [BankingFailure.unavailable, BankingFailure.rateLimited, BankingFailure.authentication, BankingFailure.forbidden]) {
      api.deleteFailure = BankingException(providerId: 'alternative', failure: kind);
      await expectLater(() => service().revoke(connection), throwsA(anything));
      expect((await repository.selectById(connection.id!)).status, BankConnectionStatus.revocationPending);
    }

    api.deleteFailure = const BankingException(providerId: 'alternative', failure: BankingFailure.notFound);
    await service().revoke(await repository.selectById(connection.id!));
    expect((await repository.selectById(connection.id!)).status, BankConnectionStatus.revoked);
  });

  test('confirmed remote revocation finalizes the connection', () async {
    final connection = await repository.insert(BankConnection(providerId: 'alternative', institutionName: 'Test Bank', institutionCountry: 'IT', applicationId: 'app-id', remoteConnectionId: 'session', validUntil: now.add(const Duration(days: 1)), status: BankConnectionStatus.active));

    await service().revoke(connection);

    expect(api.deleteCalls, 1);
    expect((await repository.selectById(connection.id!)).status, BankConnectionStatus.revoked);
  });

  test('application auth error does not masquerade as expired session', () async {
    final connection = await repository.insert(BankConnection(providerId: 'alternative', institutionName: 'Test Bank', institutionCountry: 'IT', applicationId: 'app-id', remoteConnectionId: 'session', validUntil: now.add(const Duration(days: 1)), status: BankConnectionStatus.active));
    api.getSessionFailure = const BankingException(providerId: 'alternative', failure: BankingFailure.authentication);

    final status = await service().refreshConnectionState(connection);

    expect(status, BankConnectionStatus.reauthRequired);
  });

  test('unsupported platform is rejected before network or pending state', () async {
    final unsupported = BankConsentLifecycleService(consent: api, institutions: api, readContext: () async => context, pendingStore: pending, connections: repository, callbackSupported: () => false);

    await expectLater(() => unsupported.startAuthorization(api.aspsps.single), throwsA(isA<BankingException>()));
    expect(pending.value, isNull);
  });
  for (final changed in [const BankAuthorizationContext(providerId: 'other', applicationId: 'app-id', redirectUri: 'sossoldi://eb-callback'), const BankAuthorizationContext(providerId: 'alternative', applicationId: 'rotated', redirectUri: 'sossoldi://eb-callback'), const BankAuthorizationContext(providerId: 'alternative', applicationId: 'app-id', redirectUri: 'https://example.com/callback')]) {
    test('pending callback rejects changed context ${changed.providerId}/${changed.applicationId}/${changed.redirectUri}', () async {
      await service().startAuthorization(api.aspsps.single);
      final callback = BankAuthorizationCallback(code: 'code', state: pending.value!.state);
      context = changed;
      await expectLater(service().completeCallback(callback), throwsA(isA<BankingException>().having((error) => error.failure, 'failure', BankingFailure.authentication)));
      expect(api.createCalls, 0);
      expect(await repository.selectAll(), isEmpty);
    });
  }

  test('foreign institution is rejected before starting authorization', () async {
    final foreign = BankInstitution(providerId: 'other', id: 'bank', name: 'Test Bank', country: 'IT', customerTypes: {BankingCustomerType.personal});
    await expectLater(service().startAuthorization(foreign), throwsA(isA<BankingException>()));
    expect(api.startCalls, 0);
    expect(pending.value, isNull);
  });

  test('active staged consent with elapsed validity is rejected on resume', () async {
    await service().startAuthorization(api.aspsps.single);
    final staged = await service().completeCallback(BankAuthorizationCallback(code: 'code', state: pending.value!.state));
    api.validUntil = now;
    expect(await service().resumeAwaitingImports(), isEmpty);
    expect((await repository.selectById(staged.connection.id!)).status, BankConnectionStatus.expired);
  });

  test('credential mismatch cannot revoke a connection through another application', () async {
    final connection = await repository.insert(const BankConnection(providerId: 'alternative', institutionName: 'Test Bank', institutionCountry: 'IT', applicationId: 'old-app', remoteConnectionId: 'session', status: BankConnectionStatus.active));
    await expectLater(service().revoke(connection), throwsA(isA<BankingException>()));
    expect(api.deleteCalls, 0);
    expect((await repository.selectById(connection.id!)).remoteConnectionId, 'session');
  });
}
