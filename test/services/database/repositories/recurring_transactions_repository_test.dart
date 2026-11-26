import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sossoldi/model/recurring_transaction.dart';
import 'package:sossoldi/model/transaction.dart';
import 'package:sossoldi/services/database/repositories/recurring_transactions_repository.dart';
import 'package:sossoldi/services/database/sossoldi_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;

void main() {
  late SossoldiDatabase sossoldiDatabase;
  late RecurringTransactionRepository repository;

  setUpAll(() async {
    sqflite_ffi.sqfliteFfiInit();
    sqflite_ffi.databaseFactory = sqflite_ffi.databaseFactoryFfi;
    sossoldiDatabase = SossoldiDatabase(dbName: 'recurring_check_test.db');
    await sossoldiDatabase.database;
    repository = RecurringTransactionRepository(database: sossoldiDatabase);
  });

  setUp(() => sossoldiDatabase.clearDatabase());

  tearDownAll(() => sossoldiDatabase.close());

  Future<RecurringTransaction> insertRent() async {
    final now = DateTime.now();
    final recurring = await repository.insert(
      RecurringTransaction(
        fromDate: DateTime(now.year, now.month - 3, 1),
        amount: 800,
        note: 'Rent',
        recurrency: Recurrence.monthly,
        idCategory: 1,
        type: TransactionType.expense,
        idBankAccount: 1,
        createdAt: now,
        updatedAt: now,
      ),
    );
    return recurring!;
  }

  Future<int> countGenerated(RecurringTransaction recurring) async {
    final db = await sossoldiDatabase.database;
    final rows = await db.query(
      transactionTable,
      where: '${TransactionFields.idRecurringTransaction} = ?',
      whereArgs: [recurring.id],
    );
    return rows.length;
  }

  test('dailyCheck completes after the due transactions are saved', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final recurring = await insertRent();

    await repository.dailyCheck(prefs);

    // Anything read right after startup, like the dashboard, must see them.
    expect(await countGenerated(recurring), 3);
    expect(
      (await repository.selectById(recurring.id!)).lastInsertion,
      isNotNull,
    );
  });

  test('dailyCheck runs at most once a day', () async {
    SharedPreferences.setMockInitialValues({
      'last_recurring_transactions_check': DateTime.now()
          .subtract(const Duration(hours: 1))
          .toIso8601String(),
    });
    final prefs = await SharedPreferences.getInstance();
    final recurring = await insertRent();

    await repository.dailyCheck(prefs);

    expect(await countGenerated(recurring), 0);
  });

  test(
    'dailyCheck preserves lastInsertion when no transaction is due',
    () async {
      final now = DateTime.now();
      final tenDaysAgo = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(const Duration(days: 10));

      final recurring = (await repository.insert(
        RecurringTransaction(
          fromDate: tenDaysAgo,
          toDate: now.add(const Duration(days: 60)),
          lastInsertion: tenDaysAgo,
          amount: 50,
          note: 'Subscription',
          recurrency: Recurrence.monthly,
          idCategory: 1,
          type: TransactionType.expense,
          idBankAccount: 1,
          createdAt: tenDaysAgo,
          updatedAt: tenDaysAgo,
        ),
      ))!;

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await repository.dailyCheck(prefs);

      expect(await countGenerated(recurring), 0);
      expect(
        (await repository.selectById(recurring.id!)).lastInsertion,
        tenDaysAgo,
      );

      // Simulate a subsequent day check when still no occurrence is due
      await prefs.setString(
        'last_recurring_transactions_check',
        now.subtract(const Duration(days: 2)).toIso8601String(),
      );
      await repository.dailyCheck(prefs);

      expect(await countGenerated(recurring), 0);
      expect(
        (await repository.selectById(recurring.id!)).lastInsertion,
        tenDaysAgo,
      );
    },
  );

  test(
    'dailyCheck sets lastInsertion to the last generated transaction date',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final recurring = await insertRent();

      await repository.dailyCheck(prefs);

      expect(await countGenerated(recurring), 3);
      expect(
        (await repository.selectById(recurring.id!)).lastInsertion,
        DateTime(now.year, now.month, 1),
      );
    },
  );
}
