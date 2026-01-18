import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../model/bank_account.dart';
import '../../../model/recurring_transaction.dart';
import '../../../model/transaction.dart';
import '../../../model/category_transaction.dart';
import '../sossoldi_database.dart';

part 'transactions_repository.g.dart';

@riverpod
TransactionsRepository transactionsRepository(Ref ref) {
  return TransactionsRepository(database: ref.watch(databaseProvider));
}

class TransactionsRepository {
  TransactionsRepository({required SossoldiDatabase database})
    : _sossoldiDB = database;

  final SossoldiDatabase _sossoldiDB;

  Future<Transaction> insert(Transaction item) async {
    final db = await _sossoldiDB.database;
    final id = await db.insert(transactionTable, item.toJson());
    return item.copy(id: id);
  }

  Future<Transaction> selectById(int id) async {
    final db = await _sossoldiDB.database;

    final maps = await db.rawQuery(
      '''
      SELECT t.*,
        c.${CategoryTransactionFields.name} as ${TransactionFields.categoryName},
        c.${CategoryTransactionFields.color} as ${TransactionFields.categoryColor},
        c.${CategoryTransactionFields.symbol} as ${TransactionFields.categorySymbol},
        b1.${BankAccountFields.name} as ${TransactionFields.bankAccountName},
        b2.${BankAccountFields.name} as ${TransactionFields.bankAccountTransferName}
      FROM
        '$transactionTable' as t
      LEFT JOIN
        $categoryTransactionTable as c ON t.${TransactionFields.idCategory} = c.${CategoryTransactionFields.id}
      LEFT JOIN
        $bankAccountTable as b1 ON t.${TransactionFields.idBankAccount} = b1.${BankAccountFields.id}
      LEFT JOIN
        $bankAccountTable as b2 ON t.${TransactionFields.idBankAccountTransfer} = b2.${BankAccountFields.id}
      WHERE
        t.${TransactionFields.id} = ?
    ''',
      [id],
    );

    if (maps.isNotEmpty) {
      return Transaction.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Transaction>> selectAll({
    int? type,
    DateTime? date,
    DateTime? dateRangeStart,
    DateTime? dateRangeEnd,
    int? limit,
    List<String>? transactionType,
    String? label,
    Map<int, bool>? bankAccounts,
  }) async {
    final db = await _sossoldiDB.database;

    String? where = type != null
        ? '${TransactionFields.type} = $type'
        : null; // filter type
    if (date != null) {
      where =
          "${where != null ? '$where and ' : ''}strftime('%Y-%m-%d', ${TransactionFields.date}) >= '${date.toString().substring(0, 10)}' and ${TransactionFields.date} <= '${date.toIso8601String().substring(0, 10)}'";
    } else if (dateRangeStart != null && dateRangeEnd != null) {
      where =
          "${where != null ? '$where and ' : ''}strftime('%Y-%m-%d', ${TransactionFields.date}) BETWEEN '${dateRangeStart.toString().substring(0, 10)}' and '${dateRangeEnd.toIso8601String().substring(0, 10)}'";
    }

    if (label != null && label.isNotEmpty) {
      where = "${where != null ? '$where and ' : ''}t.note LIKE '%$label%' ";
    }

    if (transactionType != null) {
      final transactionTypeList = transactionType.map((e) => "'$e'").toList();
      where =
          "${where != null ? '$where and ' : ''}t.type IN (${transactionTypeList.join(',')}) ";
    }

    if (bankAccounts != null &&
        !bankAccounts.entries.every((element) => element.value == false)) {
      final bankAccountIds = bankAccounts.entries
          .where((bankAccount) => bankAccount.value)
          .map((e) => "'${e.key}'");
      where =
          "${where != null ? '$where and ' : ''}t.${TransactionFields.idBankAccount} IN (${bankAccountIds.join(',')}) ";
    }

    final orderByDESC = '${TransactionFields.date} DESC';

    final result = await db.rawQuery(
      'SELECT t.*, c.${CategoryTransactionFields.name} as ${TransactionFields.categoryName}, c.${CategoryTransactionFields.color} as ${TransactionFields.categoryColor}, c.${CategoryTransactionFields.symbol} as ${TransactionFields.categorySymbol}, b1.${BankAccountFields.name} as ${TransactionFields.bankAccountName}, b2.${BankAccountFields.name} as ${TransactionFields.bankAccountTransferName} FROM "$transactionTable" as t LEFT JOIN $categoryTransactionTable as c ON t.${TransactionFields.idCategory} = c.${CategoryTransactionFields.id} LEFT JOIN $bankAccountTable as b1 ON t.${TransactionFields.idBankAccount} = b1.${BankAccountFields.id} LEFT JOIN $bankAccountTable as b2 ON t.${TransactionFields.idBankAccountTransfer} = b2.${BankAccountFields.id} ${where != null ? "WHERE $where" : ""} ORDER BY $orderByDESC ${limit != null ? "LIMIT $limit" : ""}',
    );

    return result.map((json) => Transaction.fromJson(json)).toList();
  }

  Future<List<Transaction>> getRecurrenceTransactionsById({int? id}) async {
    final db = await _sossoldiDB.database;

    final result = await db.query(
      transactionTable,
      where: '${TransactionFields.idRecurringTransaction} = ?',
      whereArgs: [id],
      orderBy: '${TransactionFields.date} DESC',
    );

    return result.map((json) => Transaction.fromJson(json)).toList();
  }

  Future<List<String>> getAllLabels({String? label}) async {
    final db = await _sossoldiDB.database;

    String where = "";
    final orderByDESC = '${TransactionFields.date} DESC';

    if (label != null) {
      where = "t.note LIKE '%$label%' ";
    }

    final result = await db.rawQuery(
      'SELECT DISTINCT LOWER(t.note) as note FROM "$transactionTable" as t LEFT JOIN $bankAccountTable as b1 ON t.${TransactionFields.idBankAccount} = b1.${BankAccountFields.id} LEFT JOIN $bankAccountTable as b2 ON t.${TransactionFields.idBankAccountTransfer} = b2.${BankAccountFields.id} ${where.isNotEmpty ? "WHERE $where" : ""} ORDER BY $orderByDESC',
    );

    return (result).map((x) => x["note"] as String).toList();
  }

  Future<List> currentMonthDailyTransactions({int? accountId}) async {
    final today = DateTime.now();
    final currentMonth = today.month;
    final currentYear = today.year;

    final beginningCurrentMonth = DateTime(currentYear, currentMonth, 1);
    final beginningNextMonth = DateTime(currentYear, currentMonth + 1, 1);

    return _transactionByFrequencyAndPeriod(
      accountId: accountId,
      recurrence: Recurrence.daily,
      dateRangeStart: beginningCurrentMonth,
      dateRangeEnd: beginningNextMonth,
    );
  }

  Future<List> lastMonthDailyTransactions() async {
    final today = DateTime.now();
    final currentMonth = today.month;
    final currentYear = today.year;

    final beginningCurrentMonth = DateTime(currentYear, currentMonth, 1);
    final beginningLastMonth = DateTime(currentYear, currentMonth - 1, 1);

    return _transactionByFrequencyAndPeriod(
      recurrence: Recurrence.daily,
      dateRangeStart: beginningLastMonth,
      dateRangeEnd: beginningCurrentMonth,
    );
  }

  Future<List> currentYearMontlyTransactions() async {
    final today = DateTime.now();
    final currentYear = today.year;

    final beginningCurrentYear = DateTime(currentYear, 1, 1);
    final beginningNextMonth = DateTime(currentYear + 1, 1, 1);

    return _transactionByFrequencyAndPeriod(
      recurrence: Recurrence.monthly,
      dateRangeStart: beginningCurrentYear,
      dateRangeEnd: beginningNextMonth,
    );
  }

  Future<List> _transactionByFrequencyAndPeriod({
    int? accountId,
    Recurrence recurrence = Recurrence.daily,
    DateTime? dateRangeStart,
    DateTime? dateRangeEnd,
  }) async {
    final db = await _sossoldiDB.database;

    //TODO: validate parameters

    var freqencyString = "";
    var frequencyDateParser = "";
    switch (recurrence) {
      case Recurrence.daily:
        freqencyString = "day";
        frequencyDateParser = "%Y-%m-%d";
        break;
      case Recurrence.monthly:
        freqencyString = "month";
        frequencyDateParser = "%Y-%m";
        break;
      default:
        throw ArgumentError("Query not implemented for frequency $recurrence");
    }

    final accountFilter = accountId != null
        ? "${TransactionFields.idBankAccount} = $accountId"
        : "";
    //var periodDateFormatter = "";
    final periodFilterStart = dateRangeStart != null
        ? "strftime('%Y-%m-%d', ${TransactionFields.date}) >= '${dateRangeStart.toString().substring(0, 10)}'"
        : "";
    final periodFilterEnd = dateRangeEnd != null
        ? "strftime('%Y-%m-%d', ${TransactionFields.date}) < '${dateRangeEnd.toString().substring(0, 10)}'"
        : "";
    final filters = [periodFilterStart, periodFilterEnd, accountFilter];
    final sqlFilters = filters.where((filter) => filter != "").join(" AND ");

    final result = await db.rawQuery('''
      SELECT
        strftime('$frequencyDateParser', t.${TransactionFields.date}) as $freqencyString,
        SUM(CASE WHEN t.${TransactionFields.type} = 'IN' THEN t.${TransactionFields.amount} ELSE 0 END) as income,
        SUM(CASE WHEN t.${TransactionFields.type} = 'OUT' THEN t.${TransactionFields.amount} ELSE 0 END) as expense
      FROM "$transactionTable" t
      JOIN $bankAccountTable b ON t.${TransactionFields.idBankAccount} = b.${BankAccountFields.id}
      WHERE $sqlFilters AND b.${BankAccountFields.countNetWorth} = 1 AND b.${BankAccountFields.active} = 1
      GROUP BY $freqencyString
    ''');

    return result;
  }

  Future<int> updateItem(Transaction item) async {
    final db = await _sossoldiDB.database;

    // You can use `rawUpdate` to write the query in SQL
    return db.update(
      transactionTable,
      item.toJson(update: true),
      where: '${TransactionFields.id} = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteById(int id) async {
    final db = await _sossoldiDB.database;

    return await db.delete(
      transactionTable,
      where: '${TransactionFields.id} = ?',
      whereArgs: [id],
    );
  }
}
