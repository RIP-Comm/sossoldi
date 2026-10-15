import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/model/recurring_transaction.dart';
import 'package:sossoldi/model/transaction.dart';
import 'package:sossoldi/providers/accounts_provider.dart';
import 'package:sossoldi/providers/categories_provider.dart';
import 'package:sossoldi/providers/recurring_transactions_provider.dart';
import 'package:sossoldi/providers/transactions_provider.dart';
import 'package:sossoldi/services/database/repositories/recurring_transactions_repository.dart';
import 'package:sossoldi/services/database/sossoldi_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;

void main() {
  group("Edit recurring transaction", () {
    late SossoldiDatabase sossoldiDatabase;
    late ProviderContainer container;
    late RecurringTransactionRepository repository;

    setUpAll(() async {
      sqflite_ffi.sqfliteFfiInit();
      sqflite_ffi.databaseFactory = sqflite_ffi.databaseFactoryFfi;
      sossoldiDatabase = SossoldiDatabase(dbName: 'test.db');
      await sossoldiDatabase.database;
      repository = RecurringTransactionRepository(database: sossoldiDatabase);
    });

    setUp(() async {
      await sossoldiDatabase.clearDatabase();
      await sossoldiDatabase.fillDemoData(countOfGeneratedTransaction: 100);
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

    Future<RecurringTransaction> insertAndSelect({DateTime? toDate}) async {
      final inserted = await repository.insert(
        RecurringTransaction(
          fromDate: DateTime(2024, 1, 1),
          toDate: toDate,
          amount: 800,
          note: 'Rent',
          recurrency: Recurrence.monthly,
          idCategory: 11, // Home
          type: TransactionType.expense,
          idBankAccount: 70, // Revolut
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
      );

      final notifier = container.read(recurringTransactionsProvider.notifier);
      await notifier.transactionSelect(inserted!);
      // Simulate a stale date left over from the add transaction page
      container
          .read(selectedDateProvider.notifier)
          .setDate(DateTime(2025, 5, 20));

      return inserted;
    }

    test("keeps the start date when updating", () async {
      await container.read(categoriesProvider.future);
      await container.read(accountsProvider.future);
      final inserted = await insertAndSelect();

      await container
          .read(recurringTransactionsProvider.notifier)
          .updateTransaction(850, 'Rent');

      final updated = await repository.selectById(inserted.id!);
      expect(updated.amount, 850);
      expect(updated.fromDate, DateTime(2024, 1, 1));
    });

    test("clears the end date when \"Never\" is selected", () async {
      await container.read(categoriesProvider.future);
      await container.read(accountsProvider.future);
      final inserted = await insertAndSelect(toDate: DateTime(2027, 1, 1));
      expect(container.read(endDateProvider), DateTime(2027, 1, 1));

      container.read(endDateProvider.notifier).setDate(null);
      await container
          .read(recurringTransactionsProvider.notifier)
          .updateTransaction(800, 'Rent');

      final updated = await repository.selectById(inserted.id!);
      expect(updated.toDate, isNull);
    });
  });
}
