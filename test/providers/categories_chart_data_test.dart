import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/model/transaction.dart';
import 'package:sossoldi/providers/categories_provider.dart';
import 'package:sossoldi/providers/transactions_provider.dart';
import 'package:sossoldi/services/database/sossoldi_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;

import '../test_utils/sql_utils.dart';

void main() {
  group("Categories chart data", () {
    late SossoldiDatabase sossoldiDatabase;
    late ProviderContainer container;

    setUpAll(() async {
      sqflite_ffi.sqfliteFfiInit();
      sqflite_ffi.databaseFactory = sqflite_ffi.databaseFactoryFfi;
      sossoldiDatabase = SossoldiDatabase(dbName: 'categories_chart_test.db');
      await sossoldiDatabase.database;
    });

    setUp(() async {
      await sossoldiDatabase.clearDatabase();
      await sossoldiDatabase.fillDemoData(countOfGeneratedTransaction: 2000);

      final db = await sossoldiDatabase.database;
      await db.delete(transactionTable);

      // This month: Out 50, Home 300 + Furniture (its subcategory) 100,
      // Leisure 200. Shopping and Transports have no transactions.
      final now = DateTime.now();
      final date = DateTime(now.year, now.month, 1, 12);
      final values = [
        createInsertSqlTransaction(date: date, amount: 50, idCategory: 10),
        createInsertSqlTransaction(date: date, amount: 300, idCategory: 11),
        createInsertSqlTransaction(date: date, amount: 100, idCategory: 12),
        createInsertSqlTransaction(date: date, amount: 200, idCategory: 14),
      ];
      await db.execute(
        '''INSERT INTO `transaction` (date, amount, type, note, idCategory, idBankAccount, idBankAccountTransfer, recurring, idRecurringTransaction, createdAt, updatedAt) VALUES ${values.join(', ')};''',
      );

      container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(sossoldiDatabase)],
      );
    });

    tearDown(() async {
      container.dispose();
      await sossoldiDatabase.clearDatabase();
    });

    tearDownAll(() {
      sossoldiDatabase.close();
    });

    test(
      "graphs page donut leaves out categories without transactions",
      () async {
        final categoryMap = await container.read(categoryMapProvider.future);

        expect(
          {
            for (final entry in categoryMap.entries)
              entry.key.name: entry.value,
          },
          {'Out': -50, 'Home': -400, 'Leisure': -200},
        );
      },
    );

    test("transactions page donut lists the biggest category first", () async {
      await container.read(categoriesProvider.future);
      await container.read(allParentCategoriesProvider.future);
      await container.read(transactionsProvider.future);

      final data = await container.read(
        categoryWithSubcategoriesDataProvider.future,
      );

      expect(data.map((e) => e.parentCategory.name), [
        'Home',
        'Leisure',
        'Out',
      ]);
      expect(data.map((e) => e.total), [-400, -200, -50]);
    });
  });
}
