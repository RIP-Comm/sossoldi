import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../model/bank_account.dart';
import '../../model/bank_connection.dart';
import '../../model/budget.dart';
import '../../model/category_transaction.dart';
import '../../model/recurring_transaction.dart';
import '../../model/transaction.dart';
import '../banking/lifecycle/banking_backup_policy.dart';
import '../database/migration_manager.dart';
import '../database/sossoldi_database.dart';
import 'money_manager_converter.dart';

/// Thrown when a file cannot be imported; the user's data is left untouched.
class BackupFormatException implements Exception {
  const BackupFormatException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Full backup and restore of the Sossoldi database, and import from
/// Money Manager. Every import replaces the data inside a single database
/// transaction: if anything fails nothing is changed.
class BackupService {
  BackupService({
    SossoldiDatabase? database,
    Future<Directory> Function()? temporaryDirectory,
  }) : _sossoldiDB = database ?? SossoldiDatabase.instance,
       _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory;

  final SossoldiDatabase _sossoldiDB;

  /// Parent of the scratch folders used while exporting and importing.
  final Future<Directory> Function() _temporaryDirectory;
  final MigrationManager _migrationManager = MigrationManager();

  /// Tables a Money Manager import replaces (currencies are kept).
  static final List<String> _moneyManagerReplacedTables = [
    transactionTable,
    recurringTransactionTable,
    budgetTable,
    categoryTransactionTable,
    bankAccountIdentityTable,
    bankAccountTable,
    bankConnectionTable,
  ];

  /// Imports a Money Manager export (.xlsx, or .csv saved from it),
  /// replacing accounts, categories, transactions, budgets and recurring
  /// transactions. Returns the number of rows that could not be imported.
  Future<int> importMoneyManager(File file) async {
    final rows = extension(file.path).toLowerCase() == '.csv'
        ? MoneyManagerReader.readCsv(await file.readAsString())
        : MoneyManagerReader.readXlsx(await file.readAsBytes());
    final data = MoneyManagerConverter.convert(rows);
    if (data.transactions.isEmpty) {
      throw const MoneyManagerFormatException(
        'No transactions found in the file',
      );
    }

    final db = await _sossoldiDB.database;
    await db.transaction((txn) async {
      for (final table in _moneyManagerReplacedTables) {
        await txn.delete(table);
      }
      final batch = txn.batch();
      for (final row in data.accounts) {
        batch.insert(bankAccountTable, row);
      }
      for (final row in data.categories) {
        batch.insert(categoryTransactionTable, row);
      }
      for (final row in data.transactions) {
        batch.insert(transactionTable, row);
      }
      await batch.commit(noResult: true);
    });
    return data.skippedRows;
  }

  /// Returns a copy of the database to save as a backup. Bank connection
  /// identifiers are removed, as in the CSV export.
  Future<Uint8List> exportDatabase() async {
    final source = await _sossoldiDB.database;
    final tempDir = await (await _temporaryDirectory()).createTemp(
      'sossoldi_backup',
    );
    try {
      final path = join(tempDir.path, 'backup.db');
      final target = await openDatabase(
        path,
        version: _migrationManager.latestVersion,
        onCreate: (db, version) => _migrationManager.migrate(db, 0, version),
        singleInstance: false,
      );
      try {
        final tables = await _tableNames(target);
        final data = <String, List<Map<String, Object?>>>{};
        await source.transaction((txn) async {
          for (final table in await _tableNames(txn)) {
            if (tables.contains(table)) data[table] = await txn.query(table);
          }
        });
        await _replaceTables(
          target,
          data.map(
            (table, rows) => MapEntry(table, [
              for (final row in rows)
                BankingBackupPolicy.sanitizeForExport(table, row),
            ]),
          ),
          clear: tables,
        );
      } finally {
        await target.close();
      }
      return await File(path).readAsBytes();
    } finally {
      await tempDir.delete(recursive: true);
    }
  }

  /// Replaces all the data with the content of a database exported by
  /// [exportDatabase]. Backups made by older versions are migrated first.
  Future<void> importDatabase(File file) async {
    final tempDir = await (await _temporaryDirectory()).createTemp(
      'sossoldi_restore',
    );
    try {
      // Work on a copy: migrations must not modify the user's file.
      final path = join(tempDir.path, 'restore.db');
      await file.copy(path);
      await _checkBackup(path);

      final backup = await openDatabase(
        path,
        version: _migrationManager.latestVersion,
        onUpgrade: (db, oldVersion, newVersion) =>
            _migrationManager.migrate(db, oldVersion, newVersion),
        singleInstance: false,
      );
      final db = await _sossoldiDB.database;
      final liveTables = await _tableNames(db);
      final data = <String, List<Map<String, Object?>>>{};
      try {
        for (final table in await _tableNames(backup)) {
          if (!liveTables.contains(table)) continue;
          data[table] = [
            for (final row in await backup.query(table))
              BankingBackupPolicy.sanitizeForRestore(table, row),
          ];
        }
      } finally {
        await backup.close();
      }
      await _replaceTables(db, data, clear: liveTables);
    } finally {
      await tempDir.delete(recursive: true);
    }
  }

  Future<void> _checkBackup(String path) async {
    final int version;
    final Set<String> tables;
    try {
      final db = await openDatabase(
        path,
        readOnly: true,
        singleInstance: false,
      );
      try {
        version = await db.getVersion();
        tables = await _tableNames(db);
      } finally {
        await db.close();
      }
    } catch (_) {
      throw const BackupFormatException('The file is not a Sossoldi database');
    }
    if (version < 1 ||
        !tables.containsAll([
          bankAccountTable,
          transactionTable,
          categoryTransactionTable,
        ])) {
      throw const BackupFormatException('The file is not a Sossoldi database');
    }
    if (version > _migrationManager.latestVersion) {
      throw const BackupFormatException(
        'The backup was made with a newer version of Sossoldi: update the app first',
      );
    }
  }

  static Future<Set<String>> _tableNames(DatabaseExecutor db) async {
    final rows = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' "
      "AND name NOT LIKE 'sqlite_%' AND name != 'android_metadata'",
    );
    return {for (final row in rows) row['name'] as String};
  }

  static Future<void> _replaceTables(
    Database db,
    Map<String, List<Map<String, Object?>>> data, {
    required Iterable<String> clear,
  }) async {
    await db.transaction((txn) async {
      for (final table in clear) {
        await txn.delete(table);
      }
      final batch = txn.batch();
      for (final MapEntry(key: table, value: rows) in data.entries) {
        for (final row in rows) {
          batch.insert(table, row);
        }
      }
      await batch.commit(noResult: true);
    });
  }
}
