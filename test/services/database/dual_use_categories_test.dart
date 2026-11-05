import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sossoldi/model/bank_account.dart';
import 'package:sossoldi/model/budget.dart';
import 'package:sossoldi/model/category_transaction.dart';
import 'package:sossoldi/model/transaction.dart';
import 'package:sossoldi/services/database/migration_manager.dart';
import 'package:sossoldi/services/database/repositories/budget_repository.dart';
import 'package:sossoldi/services/database/repositories/category_repository.dart';
import 'package:sossoldi/services/database/sossoldi_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;

class _TestDatabase extends SossoldiDatabase {
  _TestDatabase(this.testDatabase);

  final Database testDatabase;

  @override
  Future<Database> get database async => testDatabase;
}

void main() {
  late Directory temporaryDirectory;
  late String databasePath;
  final migrationManager = MigrationManager();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'sossoldi-dual-category-',
    );
    databasePath = join(temporaryDirectory.path, 'sossoldi.db');
  });

  tearDown(() async {
    await databaseFactory.deleteDatabase(databasePath);
    await temporaryDirectory.delete(recursive: true);
  });

  test(
    'keeps existing data and makes dual categories available both ways',
    () async {
      var database = await openDatabase(
        databasePath,
        version: migrationManager.latestVersion,
        onCreate: (database, version) =>
            migrationManager.migrate(database, 0, version),
      );

      final accountId = await database.insert(
        bankAccountTable,
        const BankAccount(
          name: 'Main account',
          symbol: 'account_balance',
          color: 0,
          startingValue: 0,
          active: true,
          countNetWorth: true,
          mainAccount: true,
          order: 0,
        ).toJson(),
      );
      final legacyIncomeId = await database.insert(categoryTransactionTable, {
        CategoryTransactionFields.name: 'Salary',
        CategoryTransactionFields.type: 'IN',
        CategoryTransactionFields.symbol: 'payments',
        CategoryTransactionFields.color: 0,
        CategoryTransactionFields.note: null,
        CategoryTransactionFields.parent: null,
        CategoryTransactionFields.order: 0,
        CategoryTransactionFields.createdAt: DateTime.utc(
          2026,
        ).toIso8601String(),
        CategoryTransactionFields.updatedAt: DateTime.utc(
          2026,
        ).toIso8601String(),
        CategoryTransactionFields.deletedAt: null,
      });
      final legacyExpenseId = await database.insert(categoryTransactionTable, {
        CategoryTransactionFields.name: 'Groceries',
        CategoryTransactionFields.type: 'OUT',
        CategoryTransactionFields.symbol: 'shopping_cart',
        CategoryTransactionFields.color: 1,
        CategoryTransactionFields.note: 'Existing user data',
        CategoryTransactionFields.parent: null,
        CategoryTransactionFields.order: 1,
        CategoryTransactionFields.createdAt: DateTime.utc(
          2026,
        ).toIso8601String(),
        CategoryTransactionFields.updatedAt: DateTime.utc(
          2026,
        ).toIso8601String(),
        CategoryTransactionFields.deletedAt: null,
      });
      final legacyTransactionId = await database.insert(
        transactionTable,
        Transaction(
          date: DateTime.utc(2026, 9, 30),
          amount: 42,
          type: TransactionType.expense,
          note: 'Existing transaction',
          idCategory: legacyExpenseId,
          idBankAccount: accountId,
          recurring: false,
        ).toJson(),
      );
      await database.close();

      database = await openDatabase(
        databasePath,
        version: migrationManager.latestVersion,
        onUpgrade: migrationManager.migrate,
      );
      final testDatabase = _TestDatabase(database);
      final repository = CategoryRepository(database: testDatabase);
      final budgetRepository = BudgetRepository(database: testDatabase);
      final dualCategory = await repository.insert(
        const CategoryTransaction(
          name: 'Birthday Gift',
          type: CategoryTransactionType.incomeAndExpense,
          symbol: 'redeem',
          color: 2,
          order: 0,
        ),
      );
      await database.insert(
        transactionTable,
        Transaction(
          date: DateTime.now(),
          amount: 100,
          type: TransactionType.income,
          idCategory: dualCategory.id,
          idBankAccount: accountId,
          recurring: false,
        ).toJson(),
      );
      await database.insert(
        transactionTable,
        Transaction(
          date: DateTime.now(),
          amount: 25,
          type: TransactionType.expense,
          idCategory: dualCategory.id,
          idBankAccount: accountId,
          recurring: false,
        ).toJson(),
      );
      await budgetRepository.insert(
        Budget(
          idCategory: dualCategory.id!,
          name: dualCategory.name,
          amountLimit: 200,
          active: true,
        ),
      );

      final incomeCategories = await repository.selectCategoriesByType(
        CategoryTransactionType.income,
      );
      final expenseCategories = await repository.selectCategoriesByType(
        CategoryTransactionType.expense,
      );
      final incomeFrequent = await repository.selectFrequentCategories(
        CategoryTransactionType.income,
      );
      final expenseFrequent = await repository.selectFrequentCategories(
        CategoryTransactionType.expense,
      );
      final budgetStats = await budgetRepository.selectMonthlyBudgetsStats();
      final existingTransaction = await database.query(
        transactionTable,
        where: '${TransactionFields.id} = ?',
        whereArgs: [legacyTransactionId],
        limit: 1,
      );

      expect(
        incomeCategories.map((category) => category.id),
        containsAll([legacyIncomeId, dualCategory.id]),
      );
      expect(
        incomeCategories.map((category) => category.id),
        isNot(contains(legacyExpenseId)),
      );
      expect(
        expenseCategories.map((category) => category.id),
        containsAll([legacyExpenseId, dualCategory.id]),
      );
      expect(
        expenseCategories.map((category) => category.id),
        isNot(contains(legacyIncomeId)),
      );
      expect(
        incomeFrequent.map((category) => category.id),
        contains(dualCategory.id),
      );
      expect(
        expenseFrequent.map((category) => category.id),
        contains(dualCategory.id),
      );
      expect(budgetStats.single.spent, 25);
      expect(
        existingTransaction.single[TransactionFields.idCategory],
        legacyExpenseId,
      );
      expect(
        (await repository.selectById(legacyExpenseId)).note,
        'Existing user data',
      );
      await database.close();
    },
  );
}
