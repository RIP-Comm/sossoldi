import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/model/category_transaction.dart';
import 'package:sossoldi/model/transaction.dart';
import 'package:sossoldi/services/database/repositories/transactions_repository.dart';
import 'package:sossoldi/services/database/sossoldi_database.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;

void main() {
  late SossoldiDatabase sossoldiDatabase;
  late sqflite.Database db;
  late TransactionsRepository repository;

  setUpAll(() async {
    sqflite_ffi.sqfliteFfiInit();
    sqflite_ffi.databaseFactory = sqflite_ffi.databaseFactoryFfi;
    sossoldiDatabase = SossoldiDatabase(dbName: 'transactions_repo_test.db');
    db = await sossoldiDatabase.database;
    repository = TransactionsRepository(database: sossoldiDatabase);
  });

  setUp(() async => await sossoldiDatabase.clearDatabase());

  tearDownAll(() => sossoldiDatabase.close());

  Future<int> insertCategory(String name, {bool deleted = false}) => db.insert(
    categoryTransactionTable,
    CategoryTransaction(
      name: name,
      type: CategoryTransactionType.expense,
      symbol: 'question_mark',
      color: 0,
      order: 0,
      createdAt: DateTime(2026),
    ).toJson(delete: deleted),
  );

  Future<void> insertTransaction(
    String note,
    int idCategory,
    DateTime date, {
    TransactionType type = TransactionType.expense,
  }) => repository.insert(
    Transaction(
      date: date,
      amount: 10,
      type: type,
      note: note,
      idBankAccount: 1,
      idCategory: idCategory,
      recurring: false,
    ),
  );

  group('getLastCategoryByLabel', () {
    test('returns the category of the most recent matching label', () async {
      final food = await insertCategory('Food');
      final leisure = await insertCategory('Leisure');
      await insertTransaction('Coffee', food, DateTime(2026, 1, 1));
      await insertTransaction('Coffee', leisure, DateTime(2026, 2, 1));
      await insertTransaction('Pizza', food, DateTime(2026, 3, 1));

      final category = await repository.getLastCategoryByLabel(
        'Coffee',
        TransactionType.expense,
      );

      expect(category?.id, leisure);
      expect(category?.name, 'Leisure');
    });

    test('ignores case and surrounding whitespace', () async {
      final food = await insertCategory('Food');
      await insertTransaction('Coffee', food, DateTime(2026, 1, 1));

      final category = await repository.getLastCategoryByLabel(
        '  coFFee ',
        TransactionType.expense,
      );

      expect(category?.id, food);
    });

    test('only matches transactions of the same type', () async {
      final food = await insertCategory('Food');
      await insertTransaction(
        'Coffee',
        food,
        DateTime(2026, 1, 1),
        type: TransactionType.income,
      );

      expect(
        await repository.getLastCategoryByLabel(
          'Coffee',
          TransactionType.expense,
        ),
        isNull,
      );
    });

    test('skips deleted categories and unknown labels', () async {
      final food = await insertCategory('Food');
      final deleted = await insertCategory('Old', deleted: true);
      await insertTransaction('Coffee', food, DateTime(2026, 1, 1));
      await insertTransaction('Coffee', deleted, DateTime(2026, 2, 1));

      expect(
        (await repository.getLastCategoryByLabel(
          'Coffee',
          TransactionType.expense,
        ))?.id,
        food,
      );
      expect(
        await repository.getLastCategoryByLabel('Tea', TransactionType.expense),
        isNull,
      );
    });
  });
}
