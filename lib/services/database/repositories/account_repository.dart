import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../model/bank_account.dart';
import '../../../model/category_transaction.dart';
import '../../../model/transaction.dart';
import '../sossoldi_database.dart';

part 'account_repository.g.dart';

@Riverpod(keepAlive: true)
AccountRepository accountRepository(Ref ref) {
  return AccountRepository(database: ref.watch(databaseProvider));
}

class AccountRepository {
  AccountRepository({required SossoldiDatabase database})
    : _sossoldiDB = database;

  final SossoldiDatabase _sossoldiDB;

  Future<BankAccount> insert(BankAccount item) async {
    final db = await _sossoldiDB.database;

    await changeMainAccount(db, item);

    final id = await db.insert(bankAccountTable, item.toJson());
    return item.copy(id: id);
  }

  Future<BankAccount> selectById(int id) async {
    final db = await _sossoldiDB.database;

    final maps = await db.query(
      bankAccountTable,
      columns: BankAccountFields.allFields,
      where: '${BankAccountFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return BankAccount.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<BankAccount?> selectMain() async {
    final db = await _sossoldiDB.database;

    final maps = await db.query(
      bankAccountTable,
      columns: BankAccountFields.allFields,
      where: '${BankAccountFields.mainAccount} = ?',
      whereArgs: [1],
    );

    if (maps.isNotEmpty) {
      return BankAccount.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<List<BankAccount>> selectAll() async {
    final db = await _sossoldiDB.database;

    final orderByASC = '${BankAccountFields.createdAt} ASC';
    final where = '${BankAccountFields.active} = 1 ';
    final recurringFilter =
        '(t.${TransactionFields.recurring} = 0 OR t.${TransactionFields.recurring} IS NULL)';

    final result = await db.rawQuery('''
      SELECT b.*, (b.${BankAccountFields.startingValue} +
      SUM(CASE WHEN t.${TransactionFields.type} = 'IN' OR t.${TransactionFields.type} = 'TRSF' AND t.${TransactionFields.idBankAccountTransfer} = b.${BankAccountFields.id} THEN t.${TransactionFields.amount}
               ELSE 0 END) -
      SUM(CASE WHEN t.${TransactionFields.type} = 'OUT' OR t.${TransactionFields.type} = 'TRSF' AND t.${TransactionFields.idBankAccount} = b.${BankAccountFields.id} THEN t.${TransactionFields.amount}
               ELSE 0 END)
    ) as ${BankAccountFields.total}
      FROM $bankAccountTable as b
      LEFT JOIN "$transactionTable" as t
             ON (t.${TransactionFields.idBankAccount} = b.${BankAccountFields.id} OR
                 t.${TransactionFields.idBankAccountTransfer} = b.${BankAccountFields.id})
             AND $recurringFilter
      WHERE $where
      GROUP BY b.${BankAccountFields.id}
      ORDER BY $orderByASC
    ''');

    return result.map((json) => BankAccount.fromJson(json)).toList();
  }

  Future<int> updateItem(BankAccount item) async {
    final db = await _sossoldiDB.database;

    await changeMainAccount(db, item);

    // You can use `rawUpdate` to write the query in SQL
    return db.update(
      bankAccountTable,
      item.toJson(update: true),
      where: '${BankAccountFields.id} = ?',
      whereArgs: [item.id],
    );
  }

  // Check if the new item has mainAccount true, than find the previous main account and set it to false
  Future<void> changeMainAccount(Database db, BankAccount item) async {
    if (item.mainAccount) {
      BankAccount? mainAccount = await selectMain();
      if (mainAccount != null && mainAccount.id != item.id) {
        mainAccount = mainAccount.copy(mainAccount: false);
        await db.update(
          bankAccountTable,
          mainAccount.toJson(update: true),
          where: '${BankAccountFields.id} = ?',
          whereArgs: [mainAccount.id],
        );
      }
    }
  }

  Future<int> deleteById(int id) async {
    final db = await _sossoldiDB.database;

    return await db.delete(
      bankAccountTable,
      where: '${BankAccountFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deactivateById(int id) async {
    final db = await _sossoldiDB.database;

    return await db.update(
      bankAccountTable,
      {BankAccountFields.active: 0, BankAccountFields.mainAccount: 0},
      where: '${BankAccountFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<num?> getAccountSum(int? id) async {
    final db = await _sossoldiDB.database;

    //get account infos first
    final result = await db.query(
      bankAccountTable,
      where: '${BankAccountFields.id}  = $id',
      limit: 1,
    );
    final singleObject = result.isNotEmpty ? result[0] : null;

    if (singleObject != null) {
      num balance = singleObject[BankAccountFields.startingValue] as num;

      // get all transactions of that account
      final transactionsResult = await db.query(
        transactionTable,
        where:
            '${TransactionFields.idBankAccount}  = $id OR ${TransactionFields.idBankAccountTransfer} = $id',
      );

      for (var transaction in transactionsResult) {
        num amount = transaction[TransactionFields.amount] as num;

        switch (transaction[TransactionFields.type]) {
          case ('IN'):
            balance += amount;
            break;
          case ('OUT'):
            balance -= amount;
            break;
          case ('TRSF'):
            if (transaction[TransactionFields.idBankAccount] == id) {
              balance -= amount;
            } else {
              balance += amount;
            }
            break;
        }
      }

      return balance;
    } else {
      return 0;
    }
  }

  Future<List> getTransactions(int accountId, int numTransactions) async {
    final db = await _sossoldiDB.database;

    final accountFilter = "${TransactionFields.idBankAccount} = $accountId";

    final resultQuery = await db.rawQuery('''
      SELECT t.*,
        c.${CategoryTransactionFields.name} as ${TransactionFields.categoryName},
        c.${CategoryTransactionFields.color} as ${TransactionFields.categoryColor},
        c.${CategoryTransactionFields.symbol} as ${TransactionFields.categorySymbol}
      FROM
        "$transactionTable" as t
      LEFT JOIN
        $categoryTransactionTable as c ON t.${TransactionFields.idCategory} = c.${CategoryTransactionFields.id}
      WHERE
        $accountFilter
      ORDER BY
        ${TransactionFields.date} DESC
        LIMIT
          $numTransactions
    ''');

    return resultQuery;
  }

  Future<List> accountDailyBalance(
    int accountId, {
    DateTime? dateRangeStart,
    DateTime? dateRangeEnd,
  }) async {
    final db = await _sossoldiDB.database;

    final accountFilter =
        "(${TransactionFields.idBankAccount} = $accountId OR ${TransactionFields.idBankAccountTransfer} = $accountId)";
    final recurrentFilter = "(${TransactionFields.recurring} = 0)";
    final periodFilterEnd = dateRangeEnd != null
        ? "strftime('%Y-%m-%d', ${TransactionFields.date}) < '${dateRangeEnd.toString().substring(0, 10)}'"
        : "";
    final filters = [periodFilterEnd, accountFilter, recurrentFilter];
    final sqlFilters = filters.where((filter) => filter != "").join(" AND ");

    final resultQuery = await db.rawQuery('''
      SELECT
        strftime('%Y-%m-%d', ${TransactionFields.date}) as day,
        SUM(CASE WHEN (${TransactionFields.type} = 'IN' OR (${TransactionFields.type} = 'TRSF' AND ${TransactionFields.idBankAccountTransfer} = $accountId)) THEN ${TransactionFields.amount} ELSE 0 END) as income,
        SUM(CASE WHEN ${TransactionFields.type} = 'OUT' OR (${TransactionFields.type} = 'TRSF' AND ${TransactionFields.idBankAccount} = $accountId) THEN ${TransactionFields.amount} ELSE 0 END) as expense
      FROM "$transactionTable"
      WHERE $sqlFilters
      GROUP BY day
    ''');

    final statritngValue = await db.rawQuery('''
      SELECT ${BankAccountFields.startingValue} as Value
      FROM $bankAccountTable
      WHERE ${BankAccountFields.id} = $accountId
    ''');

    double runningTotal = statritngValue[0]['Value'] as double;

    var result = resultQuery.map((e) {
      runningTotal +=
          double.parse(e['income'].toString()) -
          double.parse(e['expense'].toString());
      return {"day": e["day"], "balance": runningTotal};
    }).toList();

    if (dateRangeStart != null) {
      return result
          .where(
            (element) => dateRangeStart.isBefore(
              DateTime.parse(
                element["day"].toString(),
              ).add(const Duration(days: 1)),
            ),
          )
          .toList();
    }

    return result;
  }

  Future<List> accountMonthlyBalance(
    int accountId, {
    DateTime? dateRangeStart,
    DateTime? dateRangeEnd,
  }) async {
    final db = await _sossoldiDB.database;

    final accountFilter =
        "(${TransactionFields.idBankAccount} = $accountId OR ${TransactionFields.idBankAccountTransfer} = $accountId)";
    final recurrentFilter = "(${TransactionFields.recurring} = 0)";
    final periodFilterEnd = dateRangeEnd != null
        ? "strftime('%Y-%m-%d', ${TransactionFields.date}) < '${dateRangeEnd.toString().substring(0, 10)}'"
        : "";
    final filters = [periodFilterEnd, accountFilter, recurrentFilter];
    final sqlFilters = filters.where((filter) => filter != "").join(" AND ");

    final resultQuery = await db.rawQuery('''
      SELECT
        strftime('%Y-%m', ${TransactionFields.date}) as month,
        SUM(CASE WHEN (${TransactionFields.type} = 'IN' OR (${TransactionFields.type} = 'TRSF' AND ${TransactionFields.idBankAccountTransfer} = $accountId)) THEN ${TransactionFields.amount} ELSE 0 END) as income,
        SUM(CASE WHEN ${TransactionFields.type} = 'OUT' OR (${TransactionFields.type} = 'TRSF' AND ${TransactionFields.idBankAccount} = $accountId) THEN ${TransactionFields.amount} ELSE 0 END) as expense
      FROM "$transactionTable"
      WHERE $sqlFilters
      GROUP BY month
    ''');

    final statritngValue = await db.rawQuery('''
      SELECT ${BankAccountFields.startingValue} as Value
      FROM $bankAccountTable
      WHERE ${BankAccountFields.id} = $accountId
    ''');

    double runningTotal = statritngValue[0]['Value'] as double;

    var result = resultQuery.map((e) {
      runningTotal +=
          double.parse(e['income'].toString()) -
          double.parse(e['expense'].toString());
      return {"month": e["month"], "balance": runningTotal};
    }).toList();

    if (dateRangeStart != null) {
      return result
          .where(
            (element) => dateRangeStart.isBefore(
              DateTime.parse(
                ("${element["month"]}-01").toString(),
              ).add(const Duration(days: 1)),
            ),
          )
          .toList();
    }

    return result;
  }
}
