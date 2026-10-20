import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/model/category_transaction.dart';
import 'package:sossoldi/model/transaction.dart';
import 'package:sossoldi/pages/transactions/create_transaction/create_transaction_page.dart';
import 'package:sossoldi/providers/categories_provider.dart';
import 'package:sossoldi/providers/settings_provider.dart';
import 'package:sossoldi/services/database/repositories/transactions_repository.dart';
import 'package:sossoldi/services/database/sossoldi_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    show databaseFactory, databaseFactoryFfiNoIsolate, sqfliteFfiInit;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SossoldiDatabase sossoldiDatabase;
  late SharedPreferences sharedPreferences;
  late int leisureId;
  late int salaryId;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
    sossoldiDatabase = SossoldiDatabase(dbName: 'create_transaction_test.db');
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
  });

  setUp(() async {
    await sossoldiDatabase.clearDatabase();
    final db = await sossoldiDatabase.database;
    final repository = TransactionsRepository(database: sossoldiDatabase);

    Future<int> insertCategory(String name, CategoryTransactionType type) =>
        db.insert(
          categoryTransactionTable,
          CategoryTransaction(
            name: name,
            type: type,
            symbol: 'question_mark',
            color: 0,
            order: 0,
            createdAt: DateTime(2026),
          ).toJson(),
        );

    Future<void> insertTransaction(
      String note,
      int idCategory,
      TransactionType type,
    ) => repository.insert(
      Transaction(
        date: DateTime(2026, 1, 1),
        amount: 10,
        type: type,
        note: note,
        idBankAccount: 1,
        idCategory: idCategory,
        recurring: false,
        createdAt: DateTime(2026),
      ),
    );

    leisureId = await insertCategory(
      'Leisure',
      CategoryTransactionType.expense,
    );
    salaryId = await insertCategory('Salary', CategoryTransactionType.income);
    await insertTransaction('cinema', leisureId, TransactionType.expense);
    await insertTransaction('bonus', leisureId, TransactionType.expense);
    await insertTransaction('bonus', salaryId, TransactionType.income);
  });

  tearDownAll(() => sossoldiDatabase.close());

  Future<ProviderContainer> pumpPage(WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(sossoldiDatabase),
        sharedPrefProvider.overrideWithValue(sharedPreferences),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: CreateTransactionPage()),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> typeLabel(WidgetTester tester, String label) async {
    await tester.enterText(find.byType(TextField).last, label);
    await tester.pumpAndSettle();
  }

  Future<void> selectType(WidgetTester tester, String type) async {
    await tester.tap(find.text(type));
    await tester.pumpAndSettle();
  }

  testWidgets('GIVEN a suggested expense category '
      'WHEN the type is switched to income '
      'THEN the category is cleared', (WidgetTester tester) async {
    final container = await pumpPage(tester);

    await typeLabel(tester, 'cinema');
    expect(container.read(selectedCategoryProvider)?.id, leisureId);

    await selectType(tester, 'Income');
    expect(container.read(selectedCategoryProvider), isNull);
  });

  testWidgets('GIVEN a label used for both types '
      'WHEN the type is switched '
      'THEN the category of the new type is suggested', (
    WidgetTester tester,
  ) async {
    final container = await pumpPage(tester);

    await typeLabel(tester, 'bonus');
    expect(container.read(selectedCategoryProvider)?.id, leisureId);

    await selectType(tester, 'Income');
    expect(container.read(selectedCategoryProvider)?.id, salaryId);

    await selectType(tester, 'Expense');
    expect(container.read(selectedCategoryProvider)?.id, leisureId);
  });
}
