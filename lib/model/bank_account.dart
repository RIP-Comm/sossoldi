import 'package:sqflite/sqflite.dart';

import '../database/sossoldi_database.dart';
import 'base_entity.dart';
import 'transaction.dart';

const String bankAccountTable = 'bankAccount';

class BankAccountFields extends BaseEntityFields {
  static String id = BaseEntityFields.getId;
  static String name = 'name';
  static String symbol = 'symbol';
  static String color = 'color';
  static String startingValue = 'startingValue';
  static String active = 'active';
  static String mainAccount = 'mainAccount';
  static String total = 'total';
  static String createdAt = BaseEntityFields.getCreatedAt;
  static String updatedAt = BaseEntityFields.getUpdatedAt;

  static final List<String> allFields = [
    BaseEntityFields.id,
    name,
    symbol,
    color,
    startingValue,
    active,
    mainAccount,
    BaseEntityFields.createdAt,
    BaseEntityFields.updatedAt
  ];
}

class BankAccount extends BaseEntity {
  final String name;
  final String symbol;
  final int color;
  final num startingValue;
  final bool active;
  final bool mainAccount;
  final num? total;

  const BankAccount(
      {super.id,
      required this.name,
      required this.symbol,
      required this.color,
      required this.startingValue,
      required this.active,
      required this.mainAccount,
      this.total,
      super.createdAt,
      super.updatedAt});

  BankAccount copy(
          {int? id,
          String? name,
          String? symbol,
          int? color,
          num? startingValue,
          bool? active,
          bool? mainAccount,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      BankAccount(
          id: id ?? this.id,
          name: name ?? this.name,
          symbol: symbol ?? this.symbol,
          color: color ?? this.color,
          startingValue: startingValue ?? this.startingValue,
          active: active ?? this.active,
          mainAccount: mainAccount ?? this.mainAccount,
          createdAt: createdAt ?? this.createdAt,
          updatedAt: updatedAt ?? this.updatedAt);

  static BankAccount fromJson(Map<String, Object?> json) => BankAccount(
      id: json[BaseEntityFields.id] as int,
      name: json[BankAccountFields.name] as String,
      symbol: json[BankAccountFields.symbol] as String,
      color: json[BankAccountFields.color] as int,
      startingValue: json[BankAccountFields.startingValue] as num,
      active: json[BankAccountFields.active] == 1 ? true : false,
      mainAccount: json[BankAccountFields.mainAccount] == 1 ? true : false,
      total: json[BankAccountFields.total] as num?,
      createdAt: DateTime.parse(json[BaseEntityFields.createdAt] as String),
      updatedAt: DateTime.parse(json[BaseEntityFields.updatedAt] as String));

  Map<String, Object?> toJson({bool update = false}) => {
        BaseEntityFields.id: id,
        BankAccountFields.name: name,
        BankAccountFields.symbol: symbol,
        BankAccountFields.color: color,
        BankAccountFields.startingValue: startingValue,
        BankAccountFields.active: active ? 1 : 0,
        BankAccountFields.mainAccount: mainAccount ? 1 : 0,
        BaseEntityFields.createdAt:
            update ? createdAt?.toIso8601String() : DateTime.now().toIso8601String(),
        BaseEntityFields.updatedAt: DateTime.now().toIso8601String(),
      };
}

class BankAccountMethods extends SossoldiDatabase {
  Future<BankAccount> insert(BankAccount item) async {
    final db = await database;

    await changeMainAccount(db, item);

    final id = await db.insert(bankAccountTable, item.toJson());
    return item.copy(id: id);
  }

  Future<BankAccount> selectById(int id) async {
    final db = await database;

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
    final db = await database;

    final maps = await db.query(
      bankAccountTable,
      columns: BankAccountFields.allFields,
      where: '${BankAccountFields.mainAccount} = ?',
      whereArgs: [1],
    );

    if (maps.isNotEmpty) {
      return BankAccount.fromJson(maps.first);
    } else {
      throw Exception('Main Account not found');
    }
  }

  Future<List<BankAccount>> selectAll() async {
    final db = await database;

    final orderByASC = '${BankAccountFields.createdAt} ASC';
    final where = '${BankAccountFields.active} = 1 AND (${TransactionFields.recurring} = 0 OR ${TransactionFields.recurring} = NULL)';

    final result = await db.rawQuery('''
      SELECT b.*, (b.${BankAccountFields.startingValue} +
      SUM(CASE WHEN t.${TransactionFields.type} = 'IN' OR t.${TransactionFields.type} = 'TRSF' AND t.${TransactionFields.idBankAccountTransfer} = b.${BankAccountFields.id} THEN t.${TransactionFields.amount}
               ELSE 0 END) -
      SUM(CASE WHEN t.${TransactionFields.type} = 'OUT' OR t.${TransactionFields.type} = 'TRSF' AND t.${TransactionFields.idBankAccount} = b.${BankAccountFields.id} THEN t.${TransactionFields.amount}
               ELSE 0 END)
    ) as ${BankAccountFields.total}
      FROM $bankAccountTable as b
      LEFT JOIN "$transactionTable" as t ON t.${TransactionFields.idBankAccount} = b.${BankAccountFields.id} OR t.${TransactionFields.idBankAccountTransfer} = b.${BankAccountFields.id}
      WHERE $where
      GROUP BY b.${BankAccountFields.id}
      ORDER BY $orderByASC
    ''');

    return result.map((json) => BankAccount.fromJson(json)).toList();
  }

  Future<int> updateItem(BankAccount item) async {
    final db = await database;

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
  changeMainAccount(Database db, BankAccount item) async {
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
    final db = await database;

    return await db.delete(bankAccountTable, where: '${BankAccountFields.id} = ?', whereArgs: [id]);
  }

  Future<int> deactivateById(int id) async {
    final db = await database;

    return await db.update(
        bankAccountTable,
        {'active':0},
        where: '${BankAccountFields.id} = ?',
        whereArgs: [id],
    );
  }

  Future<num?> getAccountSum(int? id) async {
    final db = await database;

    //get account infos first
    final result = await db.query(bankAccountTable, where:'${BankAccountFields.id}  = $id', limit: 1);
    final singleObject = result.isNotEmpty ? result[0] : null;

    if (singleObject != null) {
      num balance = singleObject[BankAccountFields.startingValue] as num;

      // get all transactions of that account
      final transactionsResult = await db.query(transactionTable, where:'${TransactionFields.idBankAccount}  = $id OR ${TransactionFields.idBankAccountTransfer} = $id');

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

  Future<List> accountDailyBalance(int accountId, {
    DateTime? dateRangeStart,
    DateTime? dateRangeEnd,
  }) async {
    final db = await database;

    final accountFilter = "(${TransactionFields.idBankAccount} = $accountId OR ${TransactionFields.idBankAccountTransfer} = $accountId)";
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

    final statritngValue = await db.rawQuery(
      '''
      SELECT ${BankAccountFields.startingValue} as Value
      FROM $bankAccountTable
      WHERE ${BankAccountFields.id} = $accountId
    '''
    );

    double runningTotal = statritngValue[0]['Value'] as double;

    var result = resultQuery.map((e) {
        runningTotal += double.parse(e['income'].toString()) - double.parse(e['expense'].toString());
        return {
          "day": e["day"], 
          "balance": runningTotal
          };
      }).toList();

    if(dateRangeStart != null){
      return result.where((element) => dateRangeStart.isBefore(DateTime.parse(element["day"].toString()).add(const Duration(days: 1)))).toList();
    }

    return result;
  }

}
