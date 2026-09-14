// dart format width=400

import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../model/bank_account.dart';
import '../../../model/bank_account_link.dart';
import '../../../model/bank_connection.dart';
import '../sossoldi_database.dart';
import 'bank_reconciliation_exception.dart';

part 'bank_connection_repository.g.dart';

@Riverpod(keepAlive: true)
BankConnectionRepository bankConnectionRepository(Ref ref) => BankConnectionRepository(database: ref.watch(databaseProvider));

class BankConnectionRepository {
  BankConnectionRepository({required SossoldiDatabase database}) : _database = database.database;

  BankConnectionRepository.withDatabase(Database database) : _database = Future.value(database);

  final Future<Database> _database;

  Future<BankConnection> insert(BankConnection item) async {
    final db = await _database;
    final values = item.toJson()..remove(BankConnectionFields.id);
    final id = await db.insert(bankConnectionTable, values);
    return selectById(id);
  }

  Future<BankConnection?> findById(int id) async {
    final db = await _database;
    final rows = await db.query(bankConnectionTable, columns: BankConnectionFields.allFields, where: '${BankConnectionFields.id} = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : BankConnection.fromJson(rows.single);
  }

  Future<BankConnection> selectById(int id) async {
    final item = await findById(id);
    if (item == null) throw StateError('Bank connection $id not found');
    return item;
  }

  Future<BankConnection?> findByPendingAuthorizationId(String id, {required String providerId}) async {
    final db = await _database;
    final rows = await db.query(bankConnectionTable, columns: BankConnectionFields.allFields, where: '${BankConnectionFields.pendingAuthorizationId} = ? AND ${BankConnectionFields.providerId} = ?', whereArgs: [id, providerId], limit: 1);
    return rows.isEmpty ? null : BankConnection.fromJson(rows.single);
  }

  Future<List<BankConnection>> selectAll() async {
    final db = await _database;
    final rows = await db.query(bankConnectionTable, columns: BankConnectionFields.allFields, orderBy: '${BankConnectionFields.createdAt} ASC');
    return rows.map(BankConnection.fromJson).toList(growable: false);
  }

  Future<List<BankConnection>> selectAwaitingImport() async {
    final db = await _database;
    final rows = await db.query(bankConnectionTable, columns: BankConnectionFields.allFields, where: '${BankConnectionFields.pendingRemoteConnectionId} IS NOT NULL');
    return rows.map(BankConnection.fromJson).toList(growable: false);
  }

  Future<List<BankConnection>> selectActive({required String applicationId, DateTime? clock}) async {
    final db = await _database;
    final now = (clock ?? DateTime.now()).toUtc().toIso8601String();
    return db.transaction((txn) async {
      await txn.update(
        bankConnectionTable,
        {BankConnectionFields.status: BankConnectionStatus.expired.code, BankConnectionFields.updatedAt: now},
        where:
            '${BankConnectionFields.status} = ? AND '
            '${BankConnectionFields.validUntil} <= ?',
        whereArgs: [BankConnectionStatus.active.code, now],
      );
      final rows = await txn.query(
        bankConnectionTable,
        columns: BankConnectionFields.allFields,
        where:
            '${BankConnectionFields.applicationId} = ? AND '
            '${BankConnectionFields.status} = ? AND '
            '${BankConnectionFields.validUntil} > ?',
        whereArgs: [applicationId, BankConnectionStatus.active.code, now],
      );
      return rows.map(BankConnection.fromJson).toList(growable: false);
    });
  }

  Future<BankConnection> stageConnection({required String providerId, required String authorizationId, required String applicationId, required String institutionName, required String institutionCountry, required String remoteConnectionId, required DateTime validUntil, required String psuType, int? reconnectConnectionId}) async {
    if (psuType != 'personal') {
      throw const BankReconciliationException(BankReconciliationFailure.invalidConnectionState, 'Only personal bank connections are supported');
    }
    final db = await _database;
    return db.transaction((txn) async {
      final duplicate = await txn.query(bankConnectionTable, columns: BankConnectionFields.allFields, where: '${BankConnectionFields.pendingAuthorizationId} = ? AND ${BankConnectionFields.providerId} = ?', whereArgs: [authorizationId, providerId], limit: 1);
      if (duplicate.isNotEmpty) {
        return BankConnection.fromJson(duplicate.single);
      }

      final now = DateTime.now().toUtc();
      if (reconnectConnectionId == null) {
        final connection = BankConnection(providerId: providerId, institutionName: institutionName, institutionCountry: institutionCountry, applicationId: applicationId, pendingRemoteConnectionId: remoteConnectionId, pendingAuthorizationId: authorizationId, pendingValidUntil: validUntil, status: BankConnectionStatus.awaitingImport, psuType: psuType);
        final values = connection.toJson(clock: now)..remove(BankConnectionFields.id);
        final id = await txn.insert(bankConnectionTable, values);
        return connection.copy(id: id, createdAt: now, updatedAt: now);
      }

      final rows = await txn.query(bankConnectionTable, columns: BankConnectionFields.allFields, where: '${BankConnectionFields.id} = ?', whereArgs: [reconnectConnectionId], limit: 1);
      if (rows.isEmpty) {
        throw const BankReconciliationException(BankReconciliationFailure.invalidConnectionState, 'Reconnect target does not exist');
      }
      final existing = BankConnection.fromJson(rows.single);
      if (existing.providerId != providerId || existing.applicationId != applicationId || existing.institutionName != institutionName || existing.institutionCountry != institutionCountry || !{BankConnectionStatus.active, BankConnectionStatus.expired, BankConnectionStatus.reauthRequired}.contains(existing.status)) {
        throw const BankReconciliationException(BankReconciliationFailure.invalidConnectionState, 'Reconnect authorization does not match the existing connection');
      }
      final staged = existing.copy(pendingRemoteConnectionId: remoteConnectionId, pendingAuthorizationId: authorizationId, pendingValidUntil: validUntil, psuType: psuType);
      await txn.update(
        bankConnectionTable,
        staged.toJson(update: true, clock: now),
        where: '${BankConnectionFields.id} = ?',
        whereArgs: [existing.id],
      );
      return staged.copy(updatedAt: now);
    });
  }

  Future<BankConnection> activateStagedConnection(int connectionId, List<BankAccountLink> links) async {
    final db = await _database;
    return db.transaction((txn) async {
      final connectionRows = await txn.query(bankConnectionTable, columns: BankConnectionFields.allFields, where: '${BankConnectionFields.id} = ?', whereArgs: [connectionId], limit: 1);
      if (connectionRows.isEmpty) {
        throw const BankReconciliationException(BankReconciliationFailure.invalidConnectionState, 'Connection does not exist');
      }
      final connection = BankConnection.fromJson(connectionRows.single);
      if (connection.pendingRemoteConnectionId == null || connection.pendingValidUntil == null) {
        throw const BankReconciliationException(BankReconciliationFailure.invalidConnectionState, 'Connection has no staged remote connection');
      }
      if (links.isEmpty) {
        throw const BankReconciliationException(BankReconciliationFailure.missingLocalAccount, 'At least one account must be selected before activation');
      }

      final normalized = <BankAccountLink>[];
      final remoteHashes = <String>{};
      for (final link in links) {
        final hashes = link.identificationHashes.map((hash) => hash.trim()).where((hash) => hash.isNotEmpty).toSet();
        if (link.uid.trim().isEmpty || hashes.isEmpty) {
          throw const BankReconciliationException(BankReconciliationFailure.missingStableIdentity, 'A selected account has no stable identification hash');
        }
        if (hashes.any(remoteHashes.contains)) {
          throw const BankReconciliationException(BankReconciliationFailure.identityCollision, 'Two remote accounts expose the same identification hash');
        }
        remoteHashes.addAll(hashes);
        normalized.add(BankAccountLink(uid: link.uid.trim(), identificationHashes: hashes, iban: link.iban, newAccount: link.newAccount));
      }

      final identityRows = await txn.query(bankAccountIdentityTable, where: '${BankAccountIdentityFields.connectionId} = ?', whereArgs: [connectionId]);
      final identityOwners = <String, int>{for (final row in identityRows) row[BankAccountIdentityFields.identificationHash] as String: row[BankAccountIdentityFields.bankAccountId] as int};
      final selectedAccountIds = <int>{};

      for (final link in normalized) {
        final matchingIds = link.identificationHashes.map((hash) => identityOwners[hash]).whereType<int>().toSet();
        if (matchingIds.length > 1) {
          throw const BankReconciliationException(BankReconciliationFailure.identityCollision, 'Stable hashes resolve to different local accounts');
        }

        int accountId;
        if (matchingIds.length == 1) {
          accountId = matchingIds.single;
        } else if (link.newAccount?.id case final int existingId) {
          final selectedRows = await txn.query(bankAccountTable, columns: [BankAccountFields.ebConnectionId], where: '${BankAccountFields.id} = ?', whereArgs: [existingId], limit: 1);
          if (selectedRows.isEmpty || (selectedRows.single[BankAccountFields.ebConnectionId] != null && selectedRows.single[BankAccountFields.ebConnectionId] != connectionId)) {
            throw const BankReconciliationException(BankReconciliationFailure.missingLocalAccount, 'Selected local account belongs to another connection');
          }
          accountId = existingId;
        } else if (link.newAccount case final draft?) {
          final count = Sqflite.firstIntValue(await txn.rawQuery('SELECT COUNT(*) FROM `$bankAccountTable`')) ?? 0;
          final values = draft.copy(order: count).toJson()..remove(BankAccountFields.id);
          accountId = await txn.insert(bankAccountTable, values);
        } else {
          throw const BankReconciliationException(BankReconciliationFailure.missingLocalAccount, 'A new remote account needs a local account definition');
        }
        if (!selectedAccountIds.add(accountId)) {
          throw const BankReconciliationException(BankReconciliationFailure.identityCollision, 'One local account was selected more than once');
        }

        final sortedHashes = link.identificationHashes.toList()..sort();
        final changed = await txn.update(
          bankAccountTable,
          {BankAccountFields.ebAccountUid: link.uid, BankAccountFields.ebConnectionId: connectionId, BankAccountFields.identificationHash: sortedHashes.first, BankAccountFields.identificationHashes: jsonEncode(sortedHashes), BankAccountFields.iban: link.iban, BankAccountFields.active: 1, BankAccountFields.updatedAt: DateTime.now().toUtc().toIso8601String()},
          where: '${BankAccountFields.id} = ?',
          whereArgs: [accountId],
        );
        if (changed != 1) {
          throw const BankReconciliationException(BankReconciliationFailure.missingLocalAccount, 'Selected local account does not exist');
        }
        await txn.delete(
          bankAccountIdentityTable,
          where:
              '${BankAccountIdentityFields.connectionId} = ? AND '
              '${BankAccountIdentityFields.bankAccountId} = ?',
          whereArgs: [connectionId, accountId],
        );
        for (final hash in sortedHashes) {
          await txn.insert(bankAccountIdentityTable, {BankAccountIdentityFields.connectionId: connectionId, BankAccountIdentityFields.bankAccountId: accountId, BankAccountIdentityFields.identificationHash: hash});
        }
      }

      final linkedRows = await txn.query(bankAccountTable, columns: [BankAccountFields.id], where: '${BankAccountFields.ebConnectionId} = ?', whereArgs: [connectionId]);
      for (final row in linkedRows) {
        final accountId = row[BankAccountFields.id] as int;
        if (selectedAccountIds.contains(accountId)) continue;
        await _unlinkAccount(txn, connectionId, accountId);
      }

      final activated = connection.copy(remoteConnectionId: connection.pendingRemoteConnectionId, pendingRemoteConnectionId: null, pendingAuthorizationId: null, validUntil: connection.pendingValidUntil, pendingValidUntil: null, status: BankConnectionStatus.active);
      await txn.update(bankConnectionTable, activated.toJson(update: true), where: '${BankConnectionFields.id} = ?', whereArgs: [connectionId]);
      return activated;
    });
  }

  Future<void> markStatus(int id, BankConnectionStatus status) async {
    final db = await _database;
    final changed = await db.update(bankConnectionTable, {BankConnectionFields.status: status.code, BankConnectionFields.updatedAt: DateTime.now().toUtc().toIso8601String()}, where: '${BankConnectionFields.id} = ?', whereArgs: [id]);
    if (changed != 1) throw StateError('Bank connection $id not found');
  }

  Future<void> discardStagedConnection(int id) async {
    final db = await _database;
    final changed = await db.update(
      bankConnectionTable,
      {BankConnectionFields.pendingRemoteConnectionId: null, BankConnectionFields.pendingAuthorizationId: null, BankConnectionFields.pendingValidUntil: null, BankConnectionFields.updatedAt: DateTime.now().toUtc().toIso8601String()},
      where:
          '${BankConnectionFields.id} = ? AND '
          '${BankConnectionFields.remoteConnectionId} IS NOT NULL',
      whereArgs: [id],
    );
    if (changed != 1) {
      throw StateError('Bank connection $id has no previous remote connection');
    }
  }

  Future<void> failStagedConnection(int id, BankConnectionStatus status) async {
    final db = await _database;
    final changed = await db.update(bankConnectionTable, {BankConnectionFields.pendingRemoteConnectionId: null, BankConnectionFields.pendingAuthorizationId: null, BankConnectionFields.pendingValidUntil: null, BankConnectionFields.status: status.code, BankConnectionFields.updatedAt: DateTime.now().toUtc().toIso8601String()}, where: '${BankConnectionFields.id} = ?', whereArgs: [id]);
    if (changed != 1) throw StateError('Bank connection $id not found');
  }

  Future<void> markOtherApplicationsReauthRequired(String applicationId, {required String providerId}) async {
    final db = await _database;
    await db.update(
      bankConnectionTable,
      {BankConnectionFields.status: BankConnectionStatus.reauthRequired.code, BankConnectionFields.updatedAt: DateTime.now().toUtc().toIso8601String()},
      where:
          '${BankConnectionFields.providerId} = ? AND ${BankConnectionFields.applicationId} != ? AND '
          '${BankConnectionFields.status} NOT IN (?, ?, ?)',
      whereArgs: [providerId, applicationId, BankConnectionStatus.revoked.code, BankConnectionStatus.disconnected.code, BankConnectionStatus.revocationPending.code],
    );
  }

  Future<void> markAllReauthRequired({required String providerId}) async {
    final db = await _database;
    await db.update(
      bankConnectionTable,
      {BankConnectionFields.status: BankConnectionStatus.reauthRequired.code, BankConnectionFields.updatedAt: DateTime.now().toUtc().toIso8601String()},
      where: '${BankConnectionFields.providerId} = ? AND ${BankConnectionFields.status} NOT IN (?, ?, ?)',
      whereArgs: [providerId, BankConnectionStatus.revoked.code, BankConnectionStatus.disconnected.code, BankConnectionStatus.revocationPending.code],
    );
  }

  Future<void> finalizeRemoteRevocation(int id) async => _finalizeDisconnect(id, BankConnectionStatus.revoked);

  Future<void> disconnectLocally(int id) async => _finalizeDisconnect(id, BankConnectionStatus.disconnected);

  Future<void> _finalizeDisconnect(int id, BankConnectionStatus status) async {
    final db = await _database;
    await db.transaction((txn) async {
      final accounts = await txn.query(bankAccountTable, columns: [BankAccountFields.id], where: '${BankAccountFields.ebConnectionId} = ?', whereArgs: [id]);
      for (final row in accounts) {
        await _unlinkAccount(txn, id, row[BankAccountFields.id] as int);
      }
      final changed = await txn.update(
        bankConnectionTable,
        {BankConnectionFields.status: status.code, BankConnectionFields.remoteConnectionId: null, BankConnectionFields.pendingRemoteConnectionId: null, BankConnectionFields.pendingAuthorizationId: null, BankConnectionFields.pendingValidUntil: null, BankConnectionFields.updatedAt: DateTime.now().toUtc().toIso8601String()},
        where: '${BankConnectionFields.id} = ?',
        whereArgs: [id],
      );
      if (changed != 1) throw StateError('Bank connection $id not found');
    });
  }

  Future<void> _unlinkAccount(DatabaseExecutor txn, int connectionId, int accountId) async {
    await txn.delete(
      bankAccountIdentityTable,
      where:
          '${BankAccountIdentityFields.connectionId} = ? AND '
          '${BankAccountIdentityFields.bankAccountId} = ?',
      whereArgs: [connectionId, accountId],
    );
    await txn.update(bankAccountTable, {BankAccountFields.ebAccountUid: null, BankAccountFields.ebConnectionId: null, BankAccountFields.identificationHash: null, BankAccountFields.identificationHashes: null, BankAccountFields.lastSyncAt: null}, where: '${BankAccountFields.id} = ?', whereArgs: [accountId]);
  }
}
