import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:sossoldi/database/sossoldi_database.dart';

import 'package:sossoldi/shared/models/bank_account.dart';
import 'package:sossoldi/shared/models/base_entity.dart';
import 'package:sossoldi/shared/models/transaction.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;

import '../test_utils/sql_utils.dart';

void main() {
  test('Test Copy BankAccount', () {
    BankAccount b = BankAccount(
        id: 2,
        name: "name",
        symbol: 'symbol',
        color: 0,
        startingValue: 100,
        active: true,
        countNetWorth: true,
        mainAccount: true,
        createdAt: DateTime.utc(2022),
        updatedAt: DateTime.utc(2022));

    BankAccount bCopy = b.copy(id: 10);

    assert(bCopy.id == 10);
    assert(bCopy.name == b.name);
    assert(bCopy.symbol == b.symbol);
    assert(bCopy.color == b.color);
    assert(bCopy.startingValue == bCopy.startingValue);
    assert(bCopy.active == bCopy.active);
    assert(bCopy.countNetWorth == bCopy.countNetWorth);
    assert(bCopy.mainAccount == bCopy.mainAccount);
    assert(bCopy.createdAt == b.createdAt);
    assert(bCopy.updatedAt == b.updatedAt);
  });

  test("Test fromJson BankAccount", () {
    Map<String, Object?> json = {
      BaseEntityFields.id: 0,
      BankAccountFields.name: "name",
      BankAccountFields.symbol: "symbol",
      BankAccountFields.color: 0,
      BankAccountFields.startingValue: 100,
      BaseEntityFields.createdAt: DateTime.utc(2022).toIso8601String(),
      BaseEntityFields.updatedAt: DateTime.utc(2022).toIso8601String(),
    };

    BankAccount b = BankAccount.fromJson(json);

    assert(b.id == json[BaseEntityFields.id]);
    assert(b.name == json[BankAccountFields.name]);
    assert(b.symbol == json[BankAccountFields.symbol]);
    assert(b.color == json[BankAccountFields.color]);
    assert(b.startingValue == json[BankAccountFields.startingValue]);
    assert(b.createdAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.createdAt]);
    assert(b.updatedAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.updatedAt]);
  });

  test("Test toJson BankAccount", () {
    BankAccount b = const BankAccount(
      id: 2,
      name: "name",
      symbol: "symbol",
      color: 0,
      startingValue: 100,
      active: true,
      countNetWorth: true,
      mainAccount: false,
    );

    Map<String, Object?> json = b.toJson();

    assert(b.id == json[BaseEntityFields.id]);
    assert(b.name == json[BankAccountFields.name]);
    assert(b.symbol == json[BankAccountFields.symbol]);
    assert(b.color == json[BankAccountFields.color]);
    assert(b.startingValue == json[BankAccountFields.startingValue]);
    assert((b.active ? 1 : 0) == json[BankAccountFields.active]);
    assert((b.countNetWorth ? 1 : 0) == json[BankAccountFields.countNetWorth]);
    assert((b.mainAccount ? 1 : 0) == json[BankAccountFields.mainAccount]);
  });

  group("Bank Account Methods", () {
    late SossoldiDatabase sossoldiDatabase;
    late sqflite.Database db;

    setUpAll(() async {
      sqflite_ffi.sqfliteFfiInit();
      sqflite_ffi.databaseFactory = sqflite_ffi.databaseFactoryFfi;

      sossoldiDatabase = SossoldiDatabase(dbName: 'test.db');
      db = await sossoldiDatabase.database;
      await sossoldiDatabase.resetDatabase();
    });

    tearDown(() async => {await sossoldiDatabase.clearDatabase()});

    tearDownAll(() {
      sossoldiDatabase.close();
    });

    test("selectAll", () async {
      await sossoldiDatabase.fillDemoData(countOfGeneratedTransaction: 2000);

      try {
        await db.transaction((txn) async {
          var batch = txn.batch();
          batch.delete(transactionTable);
          await batch.commit();
        });
      } catch (error) {
        throw Exception('DbBase.cleanDatabase: $error');
      }

      var transactions = await db.rawQuery("SELECT * FROM `transaction`");
      expect(0, transactions.length);

      const insertDemoTransactionsQuery =
          '''INSERT INTO `transaction` (date, amount, type, note, idCategory, idBankAccount, idBankAccountTransfer, recurring, idRecurringTransaction, createdAt, updatedAt) VALUES ''';
      final List<String> demoTransactions = [];

      final today = DateTime.now();
      final fistOfCurrentMonth = DateTime(today.year, today.month, 1);

      // Add a transaction of last month
      demoTransactions.add(
        createInsertSqlTransaction(
          date: fistOfCurrentMonth.subtract(const Duration(days: 10)),
        ),
      );
      demoTransactions.add(
        createInsertSqlTransaction(
          date: fistOfCurrentMonth.subtract(const Duration(days: 10)),
          idBankAccount: 71,
        ),
      );
      demoTransactions.add(
        createInsertSqlTransaction(
          date: fistOfCurrentMonth.subtract(const Duration(days: 10)),
          idBankAccount: 71,
          type: 'TRSF',
          idBankTransfert: 70,
        ),
      );

      // Add transactions of current month
      // 1
      demoTransactions
          .add(createInsertSqlTransaction(date: fistOfCurrentMonth));
      demoTransactions
          .add(createInsertSqlTransaction(date: fistOfCurrentMonth));
      demoTransactions.add(
        createInsertSqlTransaction(date: fistOfCurrentMonth, idBankAccount: 71),
      );
      // 2
      demoTransactions.add(
        createInsertSqlTransaction(
          date: fistOfCurrentMonth.add(const Duration(days: 1)),
        ),
      );
      demoTransactions.add(createInsertSqlTransaction(
        date: fistOfCurrentMonth.add(const Duration(days: 1)),
        amount: 200,
        type: 'IN',
      ));
      demoTransactions.add(createInsertSqlTransaction(
        date: fistOfCurrentMonth.add(const Duration(days: 1)),
        idBankAccount: 71,
      ));
      demoTransactions.add(createInsertSqlTransaction(
        date: fistOfCurrentMonth.add(const Duration(days: 1)),
        amount: 50.5,
        idBankAccount: 70,
        type: 'TRSF',
        idBankTransfert: 71,
      ));
      // 3
      demoTransactions.add(createInsertSqlTransaction(
        date: fistOfCurrentMonth.add(const Duration(days: 2)),
        type: 'IN',
      ));
      demoTransactions.add(createInsertSqlTransaction(
        date: fistOfCurrentMonth.add(const Duration(days: 2)),
        type: 'IN',
      ));
      demoTransactions.add(createInsertSqlTransaction(
        date: fistOfCurrentMonth.add(const Duration(days: 2)),
        idBankAccount: 71,
      ));

      // Add recurring transactions. These must be count as number of time they occout * amount

      await db.execute(
          "$insertDemoTransactionsQuery ${demoTransactions.join(",")};");

      transactions = await db.rawQuery("SELECT * FROM `transaction`");
      expect(13, transactions.length);

      var result = await BankAccountMethods().selectAll();
      expect(result.length, 3);

      var initialAccountAmount = 1235.10; // taken from fillDemoData
      expect(result[0].id, 70);
      expect(result[0].total! - initialAccountAmount, 49.5);

      initialAccountAmount = 3823.56; // taken from fillDemoData
      expect(result[1].id, 71);
      expect(result[1].total! - initialAccountAmount, -449.5);

      initialAccountAmount = 0; // taken from fillDemoData
      expect(result[2].id, 72);
      expect(result[2].total! - initialAccountAmount, 0);
    });

    test("accountDailyBalance", () async {
      await sossoldiDatabase.fillDemoData(countOfGeneratedTransaction: 2000);

      try {
        await db.transaction((txn) async {
          var batch = txn.batch();
          batch.delete(transactionTable);
          await batch.commit();
        });
      } catch (error) {
        throw Exception('DbBase.cleanDatabase: $error');
      }

      var transactions = await db.rawQuery("SELECT * FROM `transaction`");
      expect(0, transactions.length);

      const insertDemoTransactionsQuery =
          '''INSERT INTO `transaction` (date, amount, type, note, idCategory, idBankAccount, idBankAccountTransfer, recurring, idRecurringTransaction, createdAt, updatedAt) VALUES ''';
      final List<String> demoTransactions = [];

      final today = DateTime.now();
      final fistOfCurrentMonth = DateTime(today.year, today.month, 1);

      // Add a transaction of last month
      demoTransactions.add(createInsertSqlTransaction(
        date: fistOfCurrentMonth.subtract(const Duration(days: 10)),
      ));
      demoTransactions.add(createInsertSqlTransaction(
        date: fistOfCurrentMonth.subtract(const Duration(days: 10)),
        idBankAccount: 71,
      ));
      demoTransactions.add(createInsertSqlTransaction(
        date: fistOfCurrentMonth.subtract(const Duration(days: 10)),
        idBankAccount: 71,
        type: 'TRSF',
        idBankTransfert: 70,
      ));

      // Add transactions of current month
      demoTransactions
          .add(createInsertSqlTransaction(date: fistOfCurrentMonth));
      demoTransactions
          .add(createInsertSqlTransaction(date: fistOfCurrentMonth));
      demoTransactions.add(createInsertSqlTransaction(
        date: fistOfCurrentMonth,
        idBankAccount: 71,
      ));
      demoTransactions.add(createInsertSqlTransaction(
        date: fistOfCurrentMonth.add(const Duration(days: 1)),
      ));
      demoTransactions.add(createInsertSqlTransaction(
        date: fistOfCurrentMonth.add(const Duration(days: 1)),
        amount: 200,
        type: 'IN',
      ));
      demoTransactions.add(createInsertSqlTransaction(
        date: fistOfCurrentMonth.add(const Duration(days: 1)),
        idBankAccount: 71,
      ));
      demoTransactions.add(createInsertSqlTransaction(
        date: fistOfCurrentMonth.add(const Duration(days: 1)),
        amount: 50.5,
        idBankAccount: 70,
        type: 'TRSF',
        idBankTransfert: 71,
      ));
      demoTransactions.add(createInsertSqlTransaction(
        date: fistOfCurrentMonth.add(const Duration(days: 2)),
        type: 'IN',
      ));
      demoTransactions.add(createInsertSqlTransaction(
        date: fistOfCurrentMonth.add(const Duration(days: 2)),
        type: 'IN',
      ));
      demoTransactions.add(createInsertSqlTransaction(
        date: fistOfCurrentMonth.add(const Duration(days: 2)),
        idBankAccount: 71,
      ));

      // Add a transaction of next month
      demoTransactions.add(createInsertSqlTransaction(
        date: fistOfCurrentMonth.add(const Duration(days: 32)),
      ));
      demoTransactions.add(createInsertSqlTransaction(
        date: fistOfCurrentMonth.add(const Duration(days: 32)),
        idBankAccount: 71,
      ));

      await db.execute(
          "$insertDemoTransactionsQuery ${demoTransactions.join(",")};");

      transactions = await db.rawQuery("SELECT * FROM `transaction`");
      expect(15, transactions.length);

      var result = await BankAccountMethods().accountDailyBalance(
        70,
        dateRangeStart: DateTime(DateTime.now().year, DateTime.now().month,
            1), // beginnig of current month
        dateRangeEnd:
            DateTime(DateTime.now().year, DateTime.now().month + 1, 1),
      ); // beginnig of next month
      expect(result.length, 3);

      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      var initialAccountAmount = 1235.10; // taken from fillDemoData

      expect(result[0]['day'], formatter.format(fistOfCurrentMonth));
      expect(result[0]['balance'] - initialAccountAmount, -200);
      expect(result[1]['day'],
          formatter.format(fistOfCurrentMonth.add(const Duration(days: 1))));
      expect(result[1]['balance'] - initialAccountAmount, -150.5);
      expect(result[2]['day'],
          formatter.format(fistOfCurrentMonth.add(const Duration(days: 2))));
      expect(result[2]['balance'] - initialAccountAmount, 49.5);

      result = await BankAccountMethods().accountDailyBalance(
        71,
        dateRangeStart: DateTime(DateTime.now().year, DateTime.now().month, 1),
        dateRangeEnd:
            DateTime(DateTime.now().year, DateTime.now().month + 1, 1),
      ); // beginnig of next month;
      expect(result.length, 3);

      initialAccountAmount = 3823.56; // taken from fillDemoData

      expect(result[0]['day'], formatter.format(fistOfCurrentMonth));
      expect(result[0]['balance'] - initialAccountAmount, -300);
      expect(result[1]['day'],
          formatter.format(fistOfCurrentMonth.add(const Duration(days: 1))));
      expect(result[1]['balance'] - initialAccountAmount, -349.5);
      expect(result[2]['day'],
          formatter.format(fistOfCurrentMonth.add(const Duration(days: 2))));
      expect(result[2]['balance'] - initialAccountAmount, -449.5);
    });
  });
}
