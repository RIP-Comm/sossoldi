import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:sossoldi/database/sossoldi_database.dart';

import 'package:sossoldi/model/transaction.dart';
import 'package:sossoldi/model/base_entity.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;

import '../test_utils/sql_utils.dart';

void main() {
  test('Test Copy Transaction', () {
    Transaction t = Transaction(
        id: 2,
        date: DateTime.utc(2022),
        amount: 100,
        type: TransactionType.income,
        note: "Note",
        idBankAccount: 0,
        idBankAccountTransfer: null,
        recurring: false,
        idRecurringTransaction: null,
        idCategory: 1,
        createdAt: DateTime.utc(2022),
        updatedAt: DateTime.utc(2022)
    );

    Transaction tCopy = t.copy(id: 10);

    assert(tCopy.id == 10);
    assert(tCopy.date == t.date);
    assert(tCopy.amount == t.amount);
    assert(tCopy.date == t.date);
    assert(tCopy.type == t.type);
    assert(tCopy.note == t.note);
    assert(tCopy.idBankAccount == t.idBankAccount);
    assert(tCopy.idCategory == t.idCategory);
    assert(tCopy.idBankAccountTransfer == t.idBankAccountTransfer);
    assert(tCopy.recurring == t.recurring);
    assert(tCopy.idRecurringTransaction == t.idRecurringTransaction);
    assert(tCopy.createdAt == t.createdAt);
    assert(tCopy.updatedAt == t.updatedAt);
  });

  test("Test fromJson Transaction", () {
    Map<String, Object?> json = {
      BaseEntityFields.id: 0,
      TransactionFields.date: DateTime.utc(2022).toIso8601String(),
      TransactionFields.amount: 100,
      TransactionFields.type: "IN",
      TransactionFields.note: "Note",
      TransactionFields.idBankAccount: 0,
      TransactionFields.idCategory: 0,
      TransactionFields.idBankAccountTransfer: null,
      TransactionFields.recurring: false,
      TransactionFields.idRecurringTransaction: null,
      BaseEntityFields.createdAt: DateTime.utc(2022).toIso8601String(),
      BaseEntityFields.updatedAt: DateTime.utc(2022).toIso8601String(),
    };

    Transaction t = Transaction.fromJson(json);

    assert(t.id == json[BaseEntityFields.id]);
    assert(t.date.toUtc().toIso8601String() == json[TransactionFields.date]);
    assert(t.amount == json[TransactionFields.amount]);
    assert(t.type == typeMap[json[TransactionFields.type]]);
    assert(t.note == json[TransactionFields.note]);
    assert(t.idBankAccount == json[TransactionFields.idBankAccount]);
    assert(t.idBankAccountTransfer == json[TransactionFields.idBankAccountTransfer]);
    assert(t.recurring == json[TransactionFields.recurring]);
    assert(t.idRecurringTransaction == json[TransactionFields.idRecurringTransaction]);
    assert(t.idCategory == json[TransactionFields.idCategory]);
    assert(t.createdAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.createdAt]);
    assert(t.updatedAt?.toUtc().toIso8601String() ==
        json[BaseEntityFields.updatedAt]);
  });

  test("Test toJson Transaction", () {
    Transaction t = Transaction(
        id: 2,
        date: DateTime.utc(2022),
        amount: 100,
        type: TransactionType.income,
        note: "Note",
        idCategory: 0,
        idBankAccount: 0,
        idBankAccountTransfer: null,
        recurring: false,
        idRecurringTransaction: null
    );

    Map<String, Object?> json = t.toJson();

    assert(t.id == json[BaseEntityFields.id]);
    assert(t.date.toUtc().toIso8601String() == json[TransactionFields.date]);
    assert(t.amount == json[TransactionFields.amount]);
    assert(t.type == typeMap[json[TransactionFields.type]]);
    assert(t.note == json[TransactionFields.note]);
    assert(t.idCategory == json[TransactionFields.idCategory]);
    assert(t.idBankAccount == json[TransactionFields.idBankAccount]);
    assert(t.idBankAccountTransfer == json[TransactionFields.idBankAccountTransfer]);
    assert((t.recurring ? 1 : 0) == json[TransactionFields.recurring]);
    assert(t.idRecurringTransaction == json[TransactionFields.idRecurringTransaction]);
  });

  group("Transaction Methods", () { 

    late SossoldiDatabase sossoldiDatabase;
    late sqflite.Database db;

    setUpAll(() async {
      sqflite_ffi.sqfliteFfiInit();
      sqflite_ffi.databaseFactory = sqflite_ffi.databaseFactoryFfi;
      sossoldiDatabase = SossoldiDatabase(dbName: 'test.db');
      db = await sossoldiDatabase.database;
      await sossoldiDatabase.clearDatabase();
    });

    tearDown(() async => {
      await sossoldiDatabase.clearDatabase()
    });

    tearDownAll(() {
      sossoldiDatabase.close();
    });    

    test("lastMonthDailyTransactions", () async {
      await sossoldiDatabase.fillDemoData(countOfGeneratedTransaction: 2000);

      try{
        await db.transaction((txn) async {
          var batch = txn.batch();
          batch.delete(transactionTable);
          await batch.commit();
        });
      } catch(error){
        throw Exception('DbBase.cleanDatabase: $error');
      }

      const insertDemoTransactionsQuery = '''INSERT INTO `transaction` (date, amount, type, note, idCategory, idBankAccount, idBankAccountTransfer, recurring, idRecurringTransaction, createdAt, updatedAt) VALUES ''';
      final List<String> demoTransactions = [];

      final today = DateTime.now();
      final fistOfLastMonth = DateTime(today.year, today.month - 1, 1);

      // Add a transaction of two month ago      
      demoTransactions.add(createInsertSqlTransaction(date: fistOfLastMonth.subtract(const Duration(days: 10))));

      // Add transactions of last month
      demoTransactions.add(createInsertSqlTransaction(date: fistOfLastMonth));
      demoTransactions.add(createInsertSqlTransaction(date: fistOfLastMonth));      
      demoTransactions.add(createInsertSqlTransaction(date: fistOfLastMonth.add(const Duration(days: 1))));
      demoTransactions.add(createInsertSqlTransaction(date: fistOfLastMonth.add(const Duration(days: 1)), amount: 200, type: 'IN'));
      demoTransactions.add(createInsertSqlTransaction(date: fistOfLastMonth.add(const Duration(days: 2)), type: 'IN'));
      demoTransactions.add(createInsertSqlTransaction(date: fistOfLastMonth.add(const Duration(days: 2)), type: 'IN'));

      // Add a transaction of current month      
      demoTransactions.add(createInsertSqlTransaction(date: fistOfLastMonth.add(const Duration(days: 32))));

      await db.execute("$insertDemoTransactionsQuery ${demoTransactions.join(",")};");

      var result = await TransactionMethods().lastMonthDailyTransactions();
      expect(result.length, 3);

      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      
      expect(result[0]['day'], formatter.format(fistOfLastMonth));
      expect(result[0]['income'], 0);      
      expect(result[0]['expense'], 200);

      expect(result[1]['day'], formatter.format(fistOfLastMonth.add(const Duration(days: 1))));
      expect(result[1]['income'], 200);      
      expect(result[1]['expense'], 100);

      expect(result[2]['day'], formatter.format(fistOfLastMonth.add(const Duration(days: 2))));
      expect(result[2]['income'], 200);      
      expect(result[2]['expense'], 0);
    });

    test("currentMonthDailyTransactions", () async {
      await sossoldiDatabase.fillDemoData(countOfGeneratedTransaction: 2000);

      try{
        await db.transaction((txn) async {
          var batch = txn.batch();
          batch.delete(transactionTable);
          await batch.commit();
        });
      } catch(error){
        throw Exception('DbBase.cleanDatabase: $error');
      }

      const insertDemoTransactionsQuery = '''INSERT INTO `transaction` (date, amount, type, note, idCategory, idBankAccount, idBankAccountTransfer, recurring, idRecurringTransaction, createdAt, updatedAt) VALUES ''';
      final List<String> demoTransactions = [];

      final today = DateTime.now();
      final fistOfCurrentMonth = DateTime(today.year, today.month, 1);

      // Add a transaction of last month      
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentMonth.subtract(const Duration(days: 10))));

      // Add transactions of current month
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentMonth));
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentMonth));      
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentMonth.add(const Duration(days: 1))));
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentMonth.add(const Duration(days: 1)), amount: 200, type: 'IN'));
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentMonth.add(const Duration(days: 2)), type: 'IN'));
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentMonth.add(const Duration(days: 2)), type: 'IN'));

      // Add a transaction of next month      
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentMonth.add(const Duration(days: 32))));
      
      await db.execute("$insertDemoTransactionsQuery ${demoTransactions.join(",")};");

      var result = await TransactionMethods().currentMonthDailyTransactions();
      expect(result.length, 3);

      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      
      expect(result[0]['day'], formatter.format(fistOfCurrentMonth));
      expect(result[0]['income'], 0);      
      expect(result[0]['expense'], 200);

      expect(result[1]['day'], formatter.format(fistOfCurrentMonth.add(const Duration(days: 1))));
      expect(result[1]['income'], 200);      
      expect(result[1]['expense'], 100);

      expect(result[2]['day'], formatter.format(fistOfCurrentMonth.add(const Duration(days: 2))));
      expect(result[2]['income'], 200);      
      expect(result[2]['expense'], 0);
    });

    test("currentMonthDailyTransactions single account", () async {
      await sossoldiDatabase.fillDemoData(countOfGeneratedTransaction: 2000);

      try{
        await db.transaction((txn) async {
          var batch = txn.batch();
          batch.delete(transactionTable);
          await batch.commit();
        });
      } catch(error){
        throw Exception('DbBase.cleanDatabase: $error');
      }

      const insertDemoTransactionsQuery = '''INSERT INTO `transaction` (date, amount, type, note, idCategory, idBankAccount, idBankAccountTransfer, recurring, idRecurringTransaction, createdAt, updatedAt) VALUES ''';
      final List<String> demoTransactions = [];

      final today = DateTime.now();
      final fistOfCurrentMonth = DateTime(today.year, today.month, 1);

      // Add a transaction of last month      
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentMonth.subtract(const Duration(days: 10))));
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentMonth, idBankAccount: 71));

      // Add transactions of current month
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentMonth));
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentMonth));
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentMonth, idBankAccount: 71));    
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentMonth.add(const Duration(days: 1))));
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentMonth.add(const Duration(days: 1)), amount: 200, type: 'IN'));
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentMonth, idBankAccount: 71));
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentMonth.add(const Duration(days: 2)), type: 'IN'));
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentMonth.add(const Duration(days: 2)), type: 'IN'));
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentMonth, idBankAccount: 71));

      // Add a transaction of next month      
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentMonth.add(const Duration(days: 32))));
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentMonth, idBankAccount: 71));
      
      await db.execute("$insertDemoTransactionsQuery ${demoTransactions.join(",")};");

      var result = await TransactionMethods().currentMonthDailyTransactions(accountId: 70);
      expect(result.length, 3);

      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      
      expect(result[0]['day'], formatter.format(fistOfCurrentMonth));
      expect(result[0]['income'], 0);      
      expect(result[0]['expense'], 200);

      expect(result[1]['day'], formatter.format(fistOfCurrentMonth.add(const Duration(days: 1))));
      expect(result[1]['income'], 200);      
      expect(result[1]['expense'], 100);

      expect(result[2]['day'], formatter.format(fistOfCurrentMonth.add(const Duration(days: 2))));
      expect(result[2]['income'], 200);      
      expect(result[2]['expense'], 0);
    });

    test("currentYearMontlyTransactions", () async {
      await sossoldiDatabase.fillDemoData(countOfGeneratedTransaction: 2000);

      try{
        await db.transaction((txn) async {
          var batch = txn.batch();
          batch.delete(transactionTable);
          await batch.commit();
        });
      } catch(error){
        throw Exception('DbBase.cleanDatabase: $error');
      }

      const insertDemoTransactionsQuery = '''INSERT INTO `transaction` (date, amount, type, note, idCategory, idBankAccount, idBankAccountTransfer, recurring, idRecurringTransaction, createdAt, updatedAt) VALUES ''';
      final List<String> demoTransactions = [];

      final today = DateTime.now();
      final fistOfCurrentYear = DateTime(today.year, 1, 1);

      // Add a transaction of last year      
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentYear.subtract(const Duration(days: 10))));

      // Add transactions of current year jan
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentYear));
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentYear));      
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentYear.add(const Duration(days: 1))));
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentYear.add(const Duration(days: 1)), amount: 200, type: 'IN'));
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentYear.add(const Duration(days: 2)), type: 'IN'));
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentYear.add(const Duration(days: 2)), type: 'IN'));

      // Add transactions of current year dec
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentYear.add(const Duration(days: 300))));
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentYear.add(const Duration(days: 300))));      
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentYear.add(const Duration(days: 301))));
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentYear.add(const Duration(days: 301)), amount: 500, type: 'IN'));
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentYear.add(const Duration(days: 302)), type: 'IN'));
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentYear.add(const Duration(days: 302)), type: 'IN'));

      // Add a transaction of next year      
      demoTransactions.add(createInsertSqlTransaction(date: fistOfCurrentYear.add(const Duration(days: 400))));
      
      await db.execute("$insertDemoTransactionsQuery ${demoTransactions.join(",")};");

      var result = await TransactionMethods().currentYearMontlyTransactions();
      expect(result.length, 2);

      final DateFormat formatter = DateFormat('yyyy-MM');
      
      expect(result[0]['month'], formatter.format(fistOfCurrentYear));
      expect(result[0]['income'], 400);      
      expect(result[0]['expense'], 300);

      expect(result[1]['month'], formatter.format(fistOfCurrentYear.add(const Duration(days: 300))));
      expect(result[1]['income'], 700);      
      expect(result[1]['expense'], 300);
    });

    

  });
  
}
