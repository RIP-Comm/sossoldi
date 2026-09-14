// dart format width=400

import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/model/bank_account.dart';
import 'package:sossoldi/model/bank_account_link.dart';
import 'package:sossoldi/model/bank_connection.dart';
import 'package:sossoldi/services/database/migration_manager.dart';
import 'package:sossoldi/services/database/repositories/bank_connection_repository.dart';
import 'package:sossoldi/services/database/repositories/bank_reconciliation_exception.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database db;
  late BankConnectionRepository repository;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    final manager = MigrationManager();
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(version: manager.latestVersion, onCreate: (database, version) => manager.migrate(database, 0, version)),
    );
    repository = BankConnectionRepository.withDatabase(db);
  });

  tearDown(() => db.close());

  test('same authorization ID remains distinct across providers and credential rotation', () async {
    Future<BankConnection> stage(String provider) => repository.stageConnection(providerId: provider, authorizationId: 'same-auth', applicationId: 'same-app', institutionName: 'Bank', institutionCountry: 'IT', remoteConnectionId: 'same-session', validUntil: DateTime.utc(2027), psuType: 'personal');
    final eb = await stage('enable_banking');
    final alternative = await stage('alternative');
    expect(eb.id, isNot(alternative.id));
    expect((await stage('alternative')).id, alternative.id);
    expect((await repository.findByPendingAuthorizationId('same-auth', providerId: 'alternative'))?.id, alternative.id);
    await repository.markAllReauthRequired(providerId: 'enable_banking');
    expect((await repository.selectById(eb.id!)).status, BankConnectionStatus.reauthRequired);
    expect((await repository.selectById(alternative.id!)).status, BankConnectionStatus.awaitingImport);
    await repository.markOtherApplicationsReauthRequired('rotated', providerId: 'enable_banking');
    expect((await repository.selectById(alternative.id!)).status, BankConnectionStatus.awaitingImport);
    await repository.markOtherApplicationsReauthRequired('rotated', providerId: 'alternative');
    expect((await repository.selectById(alternative.id!)).status, BankConnectionStatus.reauthRequired);
  });

  test('reconnect changes UID without duplicating account history', () async {
    final staged = await _stage(repository, authorizationId: 'auth-1');
    final first = await repository.activateStagedConnection(staged.id!, [
      BankAccountLink(uid: 'uid-old', identificationHashes: const {'hash-main', 'hash-alias'}, iban: 'IT00TEST', newAccount: _draft('Checking', startingValue: 42)),
      BankAccountLink(uid: 'uid-removed', identificationHashes: const {'hash-removed'}, newAccount: _draft('Removed')),
    ]);
    final originalRows = await db.query(bankAccountTable, where: '${BankAccountFields.ebConnectionId} = ?', whereArgs: [first.id], orderBy: BankAccountFields.id);
    final originalId = originalRows.first[BankAccountFields.id] as int;
    final removedId = originalRows.last[BankAccountFields.id] as int;

    await repository.stageConnection(providerId: 'enable_banking', authorizationId: 'auth-2', applicationId: 'app-id', institutionName: 'Test Bank', institutionCountry: 'IT', remoteConnectionId: 'session-new', validUntil: DateTime.utc(2026, 12, 1), psuType: 'personal', reconnectConnectionId: first.id);
    final beforeCommit = await repository.selectById(first.id!);
    expect(beforeCommit.remoteConnectionId, 'session-old');
    expect(beforeCommit.pendingRemoteConnectionId, 'session-new');
    expect(beforeCommit.status, BankConnectionStatus.active);
    expect((await repository.selectActive(applicationId: 'app-id')).single.id, first.id);

    final reconnected = await repository.activateStagedConnection(first.id!, [
      const BankAccountLink(uid: 'uid-new', identificationHashes: {'hash-alias', 'hash-new'}, iban: 'IT00UPDATED'),
      BankAccountLink(uid: 'uid-added', identificationHashes: const {'hash-added'}, newAccount: _draft('Added')),
    ]);

    expect(reconnected.remoteConnectionId, 'session-new');
    expect(reconnected.pendingRemoteConnectionId, isNull);
    expect(reconnected.status, BankConnectionStatus.active);
    final retained = (await db.query(bankAccountTable, where: '${BankAccountFields.id} = ?', whereArgs: [originalId])).single;
    expect(retained[BankAccountFields.ebAccountUid], 'uid-new');
    expect(retained[BankAccountFields.startingValue], 42);
    expect(retained[BankAccountFields.name], 'Checking');
    final removed = (await db.query(bankAccountTable, where: '${BankAccountFields.id} = ?', whereArgs: [removedId])).single;
    expect(removed[BankAccountFields.ebConnectionId], isNull);
    expect(removed[BankAccountFields.ebAccountUid], isNull);
    expect(await db.query(bankAccountTable), hasLength(3));
  });

  test('identity collision rolls back every reconnect change', () async {
    final staged = await _stage(repository, authorizationId: 'auth-1');
    final active = await repository.activateStagedConnection(staged.id!, [
      BankAccountLink(uid: 'uid-a', identificationHashes: const {'hash-a'}, newAccount: _draft('A')),
      BankAccountLink(uid: 'uid-b', identificationHashes: const {'hash-b'}, newAccount: _draft('B')),
    ]);
    await repository.stageConnection(providerId: 'enable_banking', authorizationId: 'auth-2', applicationId: 'app-id', institutionName: 'Test Bank', institutionCountry: 'IT', remoteConnectionId: 'session-new', validUntil: DateTime.utc(2026, 12, 1), psuType: 'personal', reconnectConnectionId: active.id);

    await expectLater(
      () => repository.activateStagedConnection(active.id!, const [
        BankAccountLink(uid: 'uid-collision', identificationHashes: {'hash-a', 'hash-b'}),
      ]),
      throwsA(isA<BankReconciliationException>().having((error) => error.failure, 'failure', BankReconciliationFailure.identityCollision)),
    );

    final accounts = await db.query(bankAccountTable, orderBy: BankAccountFields.id);
    expect(accounts.map((row) => row[BankAccountFields.ebAccountUid]), ['uid-a', 'uid-b']);
    final connection = await repository.selectById(active.id!);
    expect(connection.remoteConnectionId, 'session-old');
    expect(connection.pendingRemoteConnectionId, 'session-new');
  });

  test('missing stable identity does not partially insert an account', () async {
    final staged = await _stage(repository, authorizationId: 'auth-1');
    await expectLater(() => repository.activateStagedConnection(staged.id!, [BankAccountLink(uid: 'uid', identificationHashes: const {}, newAccount: _draft('Unsafe'))]), throwsA(isA<BankReconciliationException>()));
    expect(await db.query(bankAccountTable), isEmpty);
    expect((await repository.selectById(staged.id!)).status, BankConnectionStatus.awaitingImport);
  });

  test('empty selection cannot activate an invisible connection', () async {
    final staged = await _stage(repository, authorizationId: 'auth-1');

    await expectLater(() => repository.activateStagedConnection(staged.id!, const []), throwsA(isA<BankReconciliationException>()));
    expect((await repository.selectById(staged.id!)).status, BankConnectionStatus.awaitingImport);
  });

  test('selectActive expires the exact UTC boundary atomically', () async {
    final boundary = DateTime.utc(2026, 9, 1, 12);
    final expired = await repository.insert(_activeConnection('expired', boundary));
    final future = await repository.insert(_activeConnection('future', boundary.add(const Duration(seconds: 1))));

    final active = await repository.selectActive(applicationId: 'app-id', clock: boundary);

    expect(active.map((item) => item.id), [future.id]);
    expect((await repository.selectById(expired.id!)).status, BankConnectionStatus.expired);
  });

  test('active selection and credential rotation are application-scoped', () async {
    final current = await repository.insert(_activeConnection('current', DateTime.utc(2027)));
    final old = await repository.insert(BankConnection(providerId: 'enable_banking', institutionName: 'Old Bank', institutionCountry: 'IT', applicationId: 'old-app', remoteConnectionId: 'old', validUntil: DateTime.utc(2027), status: BankConnectionStatus.active));

    final selected = await repository.selectActive(applicationId: 'app-id');
    expect(selected.map((item) => item.id), [current.id]);

    await repository.markOtherApplicationsReauthRequired('app-id', providerId: 'enable_banking');
    expect((await repository.selectById(old.id!)).status, BankConnectionStatus.reauthRequired);
    expect((await repository.selectById(current.id!)).status, BankConnectionStatus.active);
  });

  test('local disconnect is distinct from confirmed remote revocation', () async {
    final local = await repository.insert(_activeConnection('local', DateTime.utc(2027)));
    final remote = await repository.insert(_activeConnection('remote', DateTime.utc(2027)));

    await repository.disconnectLocally(local.id!);
    await repository.finalizeRemoteRevocation(remote.id!);

    expect((await repository.selectById(local.id!)).status, BankConnectionStatus.disconnected);
    expect((await repository.selectById(remote.id!)).status, BankConnectionStatus.revoked);
  });
}

Future<BankConnection> _stage(BankConnectionRepository repository, {required String authorizationId}) => repository.stageConnection(providerId: 'enable_banking', authorizationId: authorizationId, applicationId: 'app-id', institutionName: 'Test Bank', institutionCountry: 'IT', remoteConnectionId: 'session-old', validUntil: DateTime.utc(2026, 10, 1), psuType: 'personal');

BankConnection _activeConnection(String remoteConnectionId, DateTime validUntil) => BankConnection(providerId: 'enable_banking', institutionName: 'Test Bank', institutionCountry: 'IT', applicationId: 'app-id', remoteConnectionId: remoteConnectionId, validUntil: validUntil, status: BankConnectionStatus.active);

BankAccount _draft(String name, {num startingValue = 0}) => BankAccount(name: name, symbol: 'wallet', color: 1, startingValue: startingValue, active: true, countNetWorth: true, mainAccount: false, order: 0);
