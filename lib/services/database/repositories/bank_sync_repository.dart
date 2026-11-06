import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../model/bank_account.dart';
import '../../../model/bank_connection.dart';
import '../../banking/sync/bank_balance_selector.dart';
import '../../banking/sync/bank_money.dart';
import '../../banking/sync/bank_remote_transaction.dart';
import '../../banking/sync/bank_sync_result.dart';
import '../sossoldi_database.dart';

class BankSyncContext {
  final BankAccount account;
  final BankConnection connection;
  final String currency;
  final DateTime? checkpoint;
  final DateTime? completedAt;
  final int revision;
  final bool initialized;

  const BankSyncContext({
    required this.account,
    required this.connection,
    required this.currency,
    required this.checkpoint,
    required this.completedAt,
    required this.revision,
    required this.initialized,
  });
}

class BankSyncRepository {
  final Future<Database> _database;

  BankSyncRepository({required SossoldiDatabase database})
    : _database = database.database;
  BankSyncRepository.withDatabase(Database database)
    : _database = Future.value(database);

  Future<List<int>> accountIds({
    required String providerId,
    int? connectionId,
  }) async {
    final db = await _database;
    final rows = await db.rawQuery(
      'SELECT a.id FROM bankAccount a JOIN bankConnection c ON c.id = a.ebConnectionId WHERE c.providerId = ? AND a.active = 1 AND a.deletedAt IS NULL${connectionId == null ? '' : ' AND a.ebConnectionId = ?'}',
      [providerId, ?connectionId],
    );
    return rows.map((row) => row['id'] as int).toList();
  }

  Future<BankSyncContext> readContext(int accountId) async {
    final db = await _database;
    return db.transaction((txn) => _context(txn, accountId));
  }

  Future<BankSyncContext> _context(DatabaseExecutor db, int accountId) async {
    final accounts = await db.query(
      'bankAccount',
      where:
          'id = ? AND active = 1 AND deletedAt IS NULL AND ebConnectionId IS NOT NULL',
      whereArgs: [accountId],
    );
    if (accounts.length != 1) {
      throw const FormatException('Account is not linked');
    }
    final account = BankAccount.fromJson(accounts.single);
    final connections = await db.query(
      'bankConnection',
      where: 'id = ?',
      whereArgs: [account.ebConnectionId],
    );
    if (connections.length != 1) {
      throw const FormatException('Connection is missing');
    }
    final currencies = await db.query('currency', where: 'mainCurrency = 1');
    if (currencies.length != 1) {
      throw const FormatException('Select one global currency before sync');
    }
    final currency = currencies.single['code'] as String;
    final states = await db.query(
      'bankSyncState',
      where: 'accountId = ?',
      whereArgs: [accountId],
    );
    final state = states.isEmpty ? null : states.single;
    if (state != null && state['currency'] != currency ||
        account.currencyCode != null && account.currencyCode != currency) {
      throw const FormatException(
        'Global currency differs from imported currency',
      );
    }
    return BankSyncContext(
      account: account,
      connection: BankConnection.fromJson(connections.single),
      currency: currency,
      checkpoint: DateTime.tryParse(state?['checkpoint'] as String? ?? ''),
      completedAt: DateTime.tryParse(state?['completedAt'] as String? ?? ''),
      revision: state?['revision'] as int? ?? 0,
      initialized: state != null,
    );
  }

  Future<void> markConsentFailure(
    BankSyncContext expected,
    BankConnectionStatus status,
  ) async {
    final db = await _database;
    await db.update(
      'bankConnection',
      {'status': status.code},
      where:
          'id = ? AND providerId = ? AND sessionId = ? AND applicationId = ? AND status = ?',
      whereArgs: [
        expected.connection.id,
        expected.connection.providerId,
        expected.connection.remoteConnectionId,
        expected.connection.applicationId,
        BankConnectionStatus.active.code,
      ],
    );
  }

  Future<BankSyncSummary> latestResults(int connectionId) async {
    final db = await _database;
    final rows = await db.rawQuery(
      'SELECT audit.* FROM bankSyncAudit audit JOIN bankAccount a ON a.id = audit.accountId WHERE a.ebConnectionId = ? AND a.deletedAt IS NULL AND a.active = 1',
      [connectionId],
    );
    return BankSyncSummary(
      rows.map(
        (row) => BankSyncResult(
          accountId: row['accountId'] as int,
          status: BankSyncStatus.values.firstWhere(
            (status) => status.name == row['status'],
            orElse: () => BankSyncStatus.terminalFailure,
          ),
          warnings: (jsonDecode(row['warnings'] as String) as List)
              .cast<String>(),
        ),
      ),
    );
  }

  Future<void> recordFailure(BankSyncResult result) async {
    final db = await _database;
    await _audit(db, result);
  }

  Future<void> _audit(DatabaseExecutor db, BankSyncResult result) async {
    await db.insert('bankSyncAudit', {
      'accountId': result.accountId,
      'status': result.status.name,
      'rejected': result.rejected,
      'warnings': jsonEncode(result.warnings),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Network I/O is complete before this transaction begins.
  Future<BankSyncResult> commit(
    BankSyncContext expected,
    List<BankRemoteTransaction> items, {
    required DateTime? serverTime,
    required String strategy,
    required List<String> requiredPsuHeaders,
    DateTime? requestedFrom,
    BankBalanceSnapshot? balance,
    List<String> warnings = const [],
  }) async {
    final db = await _database;
    final accountId = expected.account.id!;
    return db.transaction((txn) async {
      final actual = await _context(txn, accountId);
      if (actual.connection.providerId != expected.connection.providerId ||
          actual.connection.id != expected.connection.id ||
          actual.revision != expected.revision ||
          actual.currency != expected.currency ||
          actual.account.ebAccountUid != expected.account.ebAccountUid ||
          actual.connection.remoteConnectionId !=
              expected.connection.remoteConnectionId ||
          actual.connection.applicationId !=
              expected.connection.applicationId ||
          actual.connection.status != BankConnectionStatus.active) {
        throw const FormatException('Sync context changed before commit');
      }
      if (serverTime != null &&
          (actual.connection.validUntil == null ||
              !actual.connection.validUntil!.isAfter(serverTime))) {
        throw const FormatException('Consent expired before commit');
      }
      if (actual.completedAt != null &&
          (serverTime == null || serverTime.isBefore(actual.completedAt!))) {
        throw const BankSyncIntegrityException('server_clock_regressed');
      }
      final keys = <String>{};
      for (final item in items) {
        if (!keys.add(item.key)) {
          throw const FormatException('Ambiguous remote transaction identity');
        }
      }
      final oldRows = await txn.query(
        'bankRemoteTransaction',
        where: 'accountId = ?',
        whereArgs: [accountId],
      );
      final old = {for (final row in oldRows) row['remoteKey'] as String: row};
      if (oldRows.any(
        (row) =>
            row['entryReference'] == null &&
            (requestedFrom == null ||
                !DateTime.parse(
                  row['bankDate'] as String,
                ).isBefore(requestedFrom)) &&
            !keys.contains(row['remoteKey']),
      )) {
        throw const FormatException(
          'Ambiguous correction without a stable reference',
        );
      }
      var inserted = 0;
      var updated = 0;
      var cancelled = 0;
      final now = (serverTime ?? DateTime.now().toUtc()).toIso8601String();
      for (final item in items) {
        final previous = old[item.key];
        final values = <String, Object?>{
          'accountId': accountId,
          'remoteKey': item.key,
          'entryReference': item.entryReference,
          'remoteTransactionId': item.transactionId,
          'remoteStatus': item.status,
          'currency': item.money.currency,
          'amountMinor': item.money.minorUnits.toString(),
          'projectedAmount': item.money.projection.abs(),
          'bankDate': item.date.toIso8601String(),
          'bankNote': item.note,
        };
        if (previous == null) {
          await txn.insert('bankRemoteTransaction', values);
        } else {
          await txn.update(
            'bankRemoteTransaction',
            values,
            where: 'accountId = ? AND remoteKey = ?',
            whereArgs: [accountId, item.key],
          );
        }
        final localId = previous?['localTransactionId'] as int?;
        if (item.status != 'BOOK') {
          if (localId != null) {
            await txn.delete(
              'transaction',
              where: 'id = ?',
              whereArgs: [localId],
            );
            cancelled++;
          }
          continue;
        }
        if (previous?['localDeleted'] == 1) continue;
        final note = previous?['noteOverridden'] == 1
            ? (previous?['localNote'])
            : item.note;
        final projection = <String, Object?>{
          'amount': item.money.projection.abs(),
          'date': item.date.toIso8601String(),
          'type': item.money.minorUnits.isNegative ? 'OUT' : 'IN',
          'note': note,
          'updatedAt': now,
        };
        if (localId == null) {
          final id = await txn.insert('transaction', {
            ...projection,
            'idBankAccount': accountId,
            'idCategory': previous?['localCategory'],
            'recurring': 0,
            'createdAt': now,
          });
          await txn.update(
            'bankRemoteTransaction',
            {'localTransactionId': id},
            where: 'accountId = ? AND remoteKey = ?',
            whereArgs: [accountId, item.key],
          );
          inserted++;
        } else {
          final changed =
              previous!['amountMinor'] != values['amountMinor'] ||
              previous['bankDate'] != values['bankDate'] ||
              previous['bankNote'] != values['bankNote'] ||
              previous['remoteStatus'] != values['remoteStatus'];
          if (changed) {
            await txn.update(
              'transaction',
              projection,
              where: 'id = ?',
              whereArgs: [localId],
            );
            updated++;
          }
        }
      }
      var checkpoint = actual.checkpoint;
      if (checkpoint != null &&
          serverTime != null &&
          checkpoint.isAfter(serverTime)) {
        checkpoint = null;
      }
      DateTime? historyFrom;
      DateTime? historyThrough;
      for (final item in items) {
        if (item.status != 'BOOK') continue;
        if (historyFrom == null || item.date.isBefore(historyFrom)) {
          historyFrom = item.date;
        }
        if (historyThrough == null || item.date.isAfter(historyThrough)) {
          historyThrough = item.date;
        }
        if (checkpoint == null || item.date.isAfter(checkpoint)) {
          checkpoint = item.date;
        }
      }
      final oldState = await txn.query(
        'bankSyncState',
        where: 'accountId = ?',
        whereArgs: [accountId],
      );
      final state = <String, Object?>{
        if (oldState.isNotEmpty) ...oldState.single,
        'accountId': accountId,
        'currency': actual.currency,
        'revision': actual.revision + 1,
        'checkpoint': checkpoint?.toIso8601String(),
        'completedAt': serverTime?.toIso8601String(),
        'historyFrom': oldState.isNotEmpty
            ? oldState.single['historyFrom'] ?? historyFrom?.toIso8601String()
            : historyFrom?.toIso8601String(),
        'historyThrough':
            historyThrough?.toIso8601String() ??
            (oldState.isEmpty ? null : oldState.single['historyThrough']),
        'strategy': strategy,
        'requiredPsuHeaders': jsonEncode(requiredPsuHeaders),
      };
      if (balance != null) {
        final previousBalanceAt = oldState.isEmpty
            ? null
            : DateTime.tryParse(oldState.single['balanceAt'] as String? ?? '');
        if (previousBalanceAt != null &&
            balance.at.isBefore(previousBalanceAt)) {
          throw const FormatException('Balance snapshot moved backwards');
        }
        var total = BankMoney.fromMinor('0', actual.currency);
        final ledger = await txn.query(
          'bankRemoteTransaction',
          where: 'accountId = ? AND remoteStatus = ?',
          whereArgs: [accountId, 'BOOK'],
        );
        for (final row in ledger) {
          if (DateTime.parse(row['bankDate'] as String).isAfter(balance.at)) {
            throw const FormatException(
              'Balance precedes imported transactions',
            );
          }
          total =
              total +
              BankMoney.fromMinor(
                row['amountMinor'] as String,
                actual.currency,
              );
        }
        final opening = balance.money - total;
        if (oldState.isNotEmpty &&
            oldState.single['openingMinor'] != opening.minorUnits.toString()) {
          throw const BankSyncIntegrityException('balance_mismatch');
        }
        state.addAll({
          'balanceMinor': balance.money.minorUnits.toString(),
          'balanceAt': balance.at.toIso8601String(),
          'openingMinor': opening.minorUnits.toString(),
          'projectedOpening': opening.projection,
        });
      }
      await txn.insert(
        'bankSyncState',
        state,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.update(
        'bankAccount',
        {
          'currencyCode': actual.currency,
          'lastSyncAt': serverTime?.toIso8601String(),
          if (balance != null) 'startingValue': state['projectedOpening'],
        },
        where: 'id = ?',
        whereArgs: [accountId],
      );
      final balanceChanged =
          balance != null &&
          (oldState.isEmpty ||
              oldState.single['balanceMinor'] != state['balanceMinor']);
      final result = BankSyncResult(
        accountId: accountId,
        status: inserted + updated + cancelled == 0 && !balanceChanged
            ? BankSyncStatus.noChange
            : BankSyncStatus.success,
        inserted: inserted,
        updated: updated,
        cancelled: cancelled,
        warnings: warnings,
      );
      await _audit(txn, result);
      return result;
    });
  }
}
