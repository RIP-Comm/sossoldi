// dart format width=400

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sossoldi/model/bank_account.dart';
import 'package:sossoldi/model/bank_connection.dart';
import 'package:sossoldi/model/base_entity.dart';
import 'package:sossoldi/services/database/migration_manager.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late String dbPath;
  final manager = MigrationManager();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    dbPath = path.join(Directory.systemTemp.path, 'sossoldi_bank_consent_migration_test.db');
  });

  tearDown(() async {
    await databaseFactory.deleteDatabase(dbPath);
  });

  test('v8 upgrade namespaces existing sessions without changing their IDs', () async {
    final v8 = await databaseFactory.openDatabase(dbPath, options: OpenDatabaseOptions(version: 8, onCreate: (db, version) => manager.migrate(db, 0, version)));
    final row = {BankConnectionFields.institutionName: 'Bank', BankConnectionFields.institutionCountry: 'IT', BankConnectionFields.applicationId: 'app', BankConnectionFields.remoteConnectionId: 'session', BankConnectionFields.status: 'ACTIVE', BankConnectionFields.createdAt: '2026-09-01T00:00:00Z', BankConnectionFields.updatedAt: '2026-09-01T00:00:00Z'};
    final original = await v8.insert(bankConnectionTable, row);
    await v8.close();
    final upgraded = await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(version: manager.latestVersion, onUpgrade: manager.migrate),
    );
    try {
      final restored = BankConnection.fromJson((await upgraded.query(bankConnectionTable)).single);
      expect(restored.id, original);
      expect(restored.providerId, 'enable_banking');
      expect(restored.remoteConnectionId, 'session');
      await upgraded.insert(bankConnectionTable, {...row, BankConnectionFields.providerId: 'alternative'});
      await expectLater(upgraded.insert(bankConnectionTable, row), throwsA(isA<DatabaseException>()));
      expect(await upgraded.query(bankConnectionTable), hasLength(2));
    } finally {
      await upgraded.close();
    }
  });

  test('v7 upgrade preserves manual accounts and adds lifecycle schema', () async {
    final v7 = await databaseFactory.openDatabase(dbPath, options: OpenDatabaseOptions(version: 7, onCreate: (db, version) => manager.migrate(db, 0, version)));
    await v7.insert(bankAccountTable, {
      BankAccountFields.name: 'Cash',
      BankAccountFields.symbol: 'wallet',
      BankAccountFields.color: 1,
      BankAccountFields.startingValue: 25,
      BankAccountFields.active: 1,
      BankAccountFields.countNetWorth: 1,
      BankAccountFields.mainAccount: 0,
      BankAccountFields.order: 0,
      BaseEntityFields.createdAt: '2026-01-01T00:00:00.000Z',
      BaseEntityFields.updatedAt: '2026-01-01T00:00:00.000Z',
    });
    await v7.close();

    final v8 = await databaseFactory.openDatabase(dbPath, options: OpenDatabaseOptions(version: 8, onUpgrade: manager.migrate));
    final accountColumns = (await v8.rawQuery('PRAGMA table_info(`$bankAccountTable`)')).map((row) => row['name']);
    expect(accountColumns, containsAll([BankAccountFields.ebAccountUid, BankAccountFields.ebConnectionId, BankAccountFields.identificationHash, BankAccountFields.identificationHashes, BankAccountFields.iban, BankAccountFields.lastSyncAt]));
    expect(await v8.query(bankAccountTable), hasLength(1));
    expect((await v8.query(bankAccountTable)).single[BankAccountFields.ebAccountUid], isNull);
    expect((await v8.rawQuery("SELECT name FROM sqlite_master WHERE type = 'table'")).map((row) => row['name']), containsAll([bankConnectionTable, bankAccountIdentityTable]));
    await v8.close();
  });

  test('fresh schema enforces stable hash uniqueness per connection', () async {
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(version: manager.latestVersion, onCreate: (database, version) => manager.migrate(database, 0, version)),
    );
    final now = '2026-01-01T00:00:00.000Z';
    final connectionId = await db.insert(bankConnectionTable, {BankConnectionFields.institutionName: 'Bank', BankConnectionFields.institutionCountry: 'IT', BankConnectionFields.applicationId: 'app', BankConnectionFields.status: BankConnectionStatus.awaitingImport.code, BankConnectionFields.psuType: 'personal', BankConnectionFields.createdAt: now, BankConnectionFields.updatedAt: now});
    final first = await db.insert(bankAccountTable, _accountRow('First'));
    final second = await db.insert(bankAccountTable, _accountRow('Second'));
    await db.insert(bankAccountIdentityTable, {BankAccountIdentityFields.connectionId: connectionId, BankAccountIdentityFields.bankAccountId: first, BankAccountIdentityFields.identificationHash: 'stable-hash'});

    await expectLater(() => db.insert(bankAccountIdentityTable, {BankAccountIdentityFields.connectionId: connectionId, BankAccountIdentityFields.bankAccountId: second, BankAccountIdentityFields.identificationHash: 'stable-hash'}), throwsA(isA<DatabaseException>()));
    await db.close();
  });

  test('failed v8 upgrade rolls back every partial schema change', () async {
    final v7 = await databaseFactory.openDatabase(dbPath, options: OpenDatabaseOptions(version: 7, onCreate: (db, version) => manager.migrate(db, 0, version)));
    await v7.execute('CREATE TABLE sabotage (sessionId TEXT)');
    await v7.execute('CREATE INDEX idx_bank_connection_session ON sabotage (sessionId)');
    await v7.close();

    await expectLater(() => databaseFactory.openDatabase(dbPath, options: OpenDatabaseOptions(version: 8, onUpgrade: manager.migrate)), throwsA(isA<DatabaseException>()));
    final unchanged = await databaseFactory.openDatabase(dbPath, options: OpenDatabaseOptions(version: 7));
    final tables = await unchanged.rawQuery("SELECT name FROM sqlite_master WHERE type = 'table'");
    expect(tables.map((row) => row['name']), isNot(contains(bankConnectionTable)));
    final columns = await unchanged.rawQuery('PRAGMA table_info(`$bankAccountTable`)');
    expect(columns.map((row) => row['name']), isNot(contains(BankAccountFields.ebAccountUid)));
    await unchanged.close();
  });
}

Map<String, Object?> _accountRow(String name) => {
  BankAccountFields.name: name,
  BankAccountFields.symbol: 'wallet',
  BankAccountFields.color: 1,
  BankAccountFields.startingValue: 0,
  BankAccountFields.active: 1,
  BankAccountFields.countNetWorth: 1,
  BankAccountFields.mainAccount: 0,
  BankAccountFields.order: 0,
  BaseEntityFields.createdAt: '2026-01-01T00:00:00.000Z',
  BaseEntityFields.updatedAt: '2026-01-01T00:00:00.000Z',
};
