import 'dart:developer' as dev;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../model/recurring_transaction.dart';
import '../../../model/transaction.dart';
import '../sossoldi_database.dart';
import 'transactions_repository.dart';

part 'recurring_transactions_repository.g.dart';

@riverpod
RecurringTransactionRepository recurringTransactionRepository(Ref ref) {
  return RecurringTransactionRepository(database: ref.watch(databaseProvider));
}

class RecurringTransactionRepository {
  RecurringTransactionRepository({required SossoldiDatabase database})
    : _sossoldiDB = database;

  final SossoldiDatabase _sossoldiDB;

  Future<RecurringTransaction?> insert(RecurringTransaction item) async {
    try {
      final db = await _sossoldiDB.database;
      final id = await db.insert(recurringTransactionTable, item.toJson());
      return item.copy(id: id);
    } catch (e) {
      dev.log('$e');
    }
    return null;
  }

  Future<RecurringTransaction> selectById(int id) async {
    final db = await _sossoldiDB.database;

    final maps = await db.query(
      recurringTransactionTable,
      columns: RecurringTransactionFields.allFields,
      where: '${RecurringTransactionFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return RecurringTransaction.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<RecurringTransaction>> selectAll() async {
    final db = await _sossoldiDB.database;

    final orderBy = '${RecurringTransactionFields.createdAt} ASC';

    final result = await db.query(recurringTransactionTable, orderBy: orderBy);

    return result.map((json) => RecurringTransaction.fromJson(json)).toList();
  }

  Future<List<RecurringTransaction>> selectAllActive() async {
    final db = await _sossoldiDB.database;

    final orderBy = '${RecurringTransactionFields.createdAt} ASC';

    final result = await db.query(
      recurringTransactionTable,
      orderBy: orderBy,
      where:
          '${RecurringTransactionFields.toDate} IS NULL OR ${RecurringTransactionFields.toDate} > ?',
      whereArgs: [DateTime.now().toIso8601String()],
    );

    return result.map((json) => RecurringTransaction.fromJson(json)).toList();
  }

  Future<int> updateItem(RecurringTransaction item) async {
    final db = await _sossoldiDB.database;

    // You can use `rawUpdate` to write the query in SQL
    return db.update(
      recurringTransactionTable,
      item.toJson(),
      where: '${RecurringTransactionFields.id} = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteById(int id) async {
    final db = await _sossoldiDB.database;

    return await db.delete(
      recurringTransactionTable,
      where: '${RecurringTransactionFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<void> checkRecurringTransactions() async {
    // get all recurring transactions active
    final transactions = await selectAllActive();

    if (transactions.isEmpty) {
      return;
    }

    for (var transaction in transactions) {
      DateTime lastTransactionDate;

      try {
        lastTransactionDate = await _getLastRecurringTransactionInsertion(
          transaction.id ?? 0,
        );
      } catch (e) {
        lastTransactionDate = transaction.fromDate;
      }

      String entity = transaction.recurrency.entity;
      int entityAmt = transaction.recurrency.amount;

      try {
        if (entityAmt == 0) {
          throw Exception('No amount provided for entity "$entity"');
        }

        populateRecurringTransaction(
          entity,
          lastTransactionDate,
          transaction,
          entityAmt,
        );
      } catch (e) {
        dev.log('$e');
      }
    }
  }

  Future<DateTime> _getLastRecurringTransactionInsertion(int tid) async {
    if (tid == 0) {
      throw Exception('No transaction ID provided');
    }

    final db = await _sossoldiDB.database;

    final result = await db.query(
      transactionTable,
      orderBy: '${TransactionFields.date} DESC',
      where: '${TransactionFields.idRecurringTransaction} = ?',
      whereArgs: [tid],
      limit: 1,
    );

    if (result.isEmpty) {
      throw Exception('No transaction found for ID $tid');
    }

    return Transaction.fromJson(result.first).date;
  }

  void populateRecurringTransaction(
    String scope,
    DateTime lastTransactionDate,
    RecurringTransaction transaction,
    int amount,
  ) {
    if (amount == 0) {
      throw Exception('No amount provided for entity "$scope"');
    }

    DateTime now = DateTime.now();

    // create a list to store the months
    List<DateTime> transactions2Add = [];

    // calculate the number of periods between the current date and the last transaction insertion
    int periods;

    switch (scope) {
      case 'days':
        periods = (now.difference(lastTransactionDate).inDays / amount).floor();
        break;
      case 'months':
        periods =
            (((now.year - lastTransactionDate.year) * 12 +
                        now.month -
                        lastTransactionDate.month) /
                    amount)
                .floor();
        break;
      default:
        throw Exception('No scope provided');
    }

    // for each period passed, insert a new transaction
    for (int i = 0; i < periods; i++) {
      switch (scope) {
        case 'days':
          lastTransactionDate = DateTime(
            lastTransactionDate.year,
            lastTransactionDate.month,
            lastTransactionDate.day + amount,
          );
          break;
        case 'months':
          // get the last day of the next period
          final int lastDayOfNextPeriod = DateTime(
            lastTransactionDate.year,
            (lastTransactionDate.month + amount + 1),
            0,
          ).day;
          int dayOfInsertion = transaction.fromDate.day;

          // if the next period's month has fewer days than the day of the last transaction insertion, adjust the day
          if (transaction.fromDate.day > lastDayOfNextPeriod) {
            dayOfInsertion = lastDayOfNextPeriod;
          }

          lastTransactionDate = DateTime(
            lastTransactionDate.year,
            lastTransactionDate.month + amount,
            dayOfInsertion,
          );

          break;
        default:
          //nothing to do
          return;
      }

      if ((transaction.toDate?.isAfter(lastTransactionDate) ?? true) &&
          lastTransactionDate.isBefore(DateTime.now())) {
        transactions2Add.add(lastTransactionDate);
      }
    }

    for (var tr in transactions2Add) {
      // insert a new transaction
      Transaction addTr = Transaction(
        date: tr,
        amount: transaction.amount,
        type: transaction.type,
        note: transaction.note,
        idCategory: transaction.idCategory,
        idBankAccount: transaction.idBankAccount,
        recurring: true,
        idRecurringTransaction: transaction.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      TransactionsRepository(database: _sossoldiDB).insert(addTr);
    }

    // update the last insertion date
    updateItem(transaction.copy(lastInsertion: now));
  }
}
