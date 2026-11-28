import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/services/database/migration_manager.dart';
import 'package:sossoldi/services/database/repositories/bank_connection_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  final manager = MigrationManager();
  late Directory directory;
  late String path;

  setUpAll(sqfliteFfiInit);
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('bank-sync-upgrade-');
    path = '${directory.path}/test.db';
  });
  tearDown(() async => directory.delete(recursive: true));

  Future<Database> createV8({bool legacy = false}) async {
    return databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 8,
        onCreate: (db, version) async {
          await manager.migrate(db, 0, 8);
          if (legacy) {
            // Frozen SQL from the original PR3 commit 65fdd05, before the provider identity migration.
            final statements =
                jsonDecode(
                      File(
                        'test/fixtures/bank_sync_v9_schema.json',
                      ).readAsStringSync(),
                    )
                    as List;
            for (final sql in statements.cast<String>()) {
              await db.execute(sql);
            }
          }
          await db.insert('bankAccount', {
            'id': 1,
            'name': 'Preserved account',
            'symbol': 'wallet',
            'color': 1,
            'startingValue': 305.89,
            'active': 1,
            'countNetWorth': 1,
            'mainAccount': 0,
            'position': 0,
            'ebConnectionId': 1,
            'ebAccountUid': 'uid',
            'createdAt': '2026-09-07',
            'updatedAt': '2026-09-07',
          });
          await db.insert('bankConnection', {
            'id': 1,
            'aspspName': 'Bank',
            'aspspCountry': 'IT',
            'applicationId': 'app',
            'sessionId': 'session',
            'status': 'ACTIVE',
            'createdAt': '2026-09-07',
            'updatedAt': '2026-09-07',
            'providerId': legacy ? 'enable_banking' : 'alternative',
          });
          await db.insert('transaction', {
            'id': 1,
            'idBankAccount': 1,
            'amount': 73.14,
            'type': 'OUT',
            'date': '2026-09-06',
            'note': 'My note',
            'idCategory': 42,
            'recurring': 0,
            'createdAt': '2026-09-07',
            'updatedAt': '2026-09-07',
          });
          if (legacy) {
            await db.insert('bankRemoteTransaction', {
              'accountId': 1,
              'remoteKey': 'ref:one',
              'entryReference': 'one',
              'remoteStatus': 'BOOK',
              'currency': 'EUR',
              'amountMinor': '-7314',
              'projectedAmount': 73.14,
              'bankDate': '2026-09-06',
              'bankNote': 'Bank note',
              'localTransactionId': 1,
              'noteOverridden': 1,
              'localNote': 'My note',
              'localCategory': 42,
            });
            await db.insert('bankSyncState', {
              'accountId': 1,
              'currency': 'EUR',
              'strategy': 'longest',
              'revision': 3,
              'checkpoint': '2026-09-06',
              'completedAt': '2026-09-07T12:00:00Z',
              'balanceMinor': '23275',
              'openingMinor': '30589',
              'projectedOpening': 305.89,
            });
          }
        },
      ),
    );
  }

  for (final legacy in [false, true]) {
    test(
      '${legacy ? 'legacy PR3' : 'PR2 provider'} v8 upgrades without losing identities, money or local edits',
      () async {
        final before = await createV8(legacy: legacy);
        final transactions = await before.query('transaction');
        final ledger = legacy
            ? await before.query('bankRemoteTransaction')
            : null;
        final state = legacy ? await before.query('bankSyncState') : null;
        await before.close();
        final db = await databaseFactoryFfi.openDatabase(
          path,
          options: OpenDatabaseOptions(version: 9, onUpgrade: manager.migrate),
        );
        try {
          expect(await db.getVersion(), 9);
          expect(await db.query('transaction'), transactions);
          expect(
            (await db.query('bankAccount')).single['startingValue'],
            305.89,
          );
          expect(
            (await db.query('bankConnection')).single['providerId'],
            legacy ? 'enable_banking' : 'alternative',
          );
          expect(
            (await db.query('bankConnection')).single['sessionId'],
            'session',
          );
          expect(await db.query('bankRemoteTransaction'), ledger ?? isEmpty);
          expect(await db.query('bankSyncState'), state ?? isEmpty);
          if (legacy) {
            await expectLater(
              db.update('transaction', {'amount': 100}, where: 'id = 1'),
              throwsA(isA<DatabaseException>()),
            );
            await expectLater(
              db.update('bankAccount', {'startingValue': 0}, where: 'id = 1'),
              throwsA(isA<DatabaseException>()),
            );
            await BankConnectionRepository.withDatabase(
              db,
            ).disconnectLocally(1);
            expect(await db.query('bankSyncState'), isEmpty);
            expect(await db.query('transaction'), transactions);
            await db.update('transaction', {'amount': 100}, where: 'id = 1');
          }
        } finally {
          await db.close();
        }
      },
    );
  }

  test(
    'partial legacy schemas fail without advancing the version or adding provider identity',
    () async {
      final before = await createV8(legacy: true);
      await before.execute('DROP TABLE bankSyncAudit');
      await before.close();
      await expectLater(
        databaseFactoryFfi.openDatabase(
          path,
          options: OpenDatabaseOptions(version: 9, onUpgrade: manager.migrate),
        ),
        throwsA(isA<StateError>()),
      );
      final unchanged = await databaseFactoryFfi.openDatabase(path);
      try {
        expect(await unchanged.getVersion(), 8);
        expect(
          (await unchanged.rawQuery(
            'PRAGMA table_info(bankConnection)',
          )).any((row) => row['name'] == 'providerId'),
          isTrue,
        );
        expect(
          (await unchanged.query('bankSyncState')).single['openingMinor'],
          '30589',
        );
      } finally {
        await unchanged.close();
      }
    },
  );
}
