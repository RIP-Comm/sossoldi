import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/model/category_transaction.dart';
import 'package:sossoldi/model/currency.dart';
import 'package:sossoldi/model/transaction.dart';
import 'package:sossoldi/pages/transactions/widgets/categories_pie_chart.dart';
import 'package:sossoldi/pages/transactions/widgets/categories_tab.dart';
import 'package:sossoldi/pages/transactions/widgets/panel_list_tile.dart';
import 'package:sossoldi/providers/categories_provider.dart';
import 'package:sossoldi/providers/currency_provider.dart';
import 'package:sossoldi/providers/transactions_provider.dart';

class _Categories extends Categories {
  @override
  Future<List<CategoryTransaction>> build() async => [
    const CategoryTransaction(
      id: 1,
      name: 'Gifts',
      type: CategoryTransactionType.incomeAndExpense,
      symbol: 'redeem',
      color: 0,
      order: 0,
    ),
    const CategoryTransaction(
      id: 2,
      name: 'Birthday',
      type: CategoryTransactionType.incomeAndExpense,
      symbol: 'redeem',
      color: 0,
      order: 0,
      parent: 1,
    ),
    const CategoryTransaction(
      id: 3,
      name: 'Income only this month',
      type: CategoryTransactionType.incomeAndExpense,
      symbol: 'redeem',
      color: 0,
      order: 1,
    ),
  ];
}

class _Transactions extends TransactionsNotifier {
  _Transactions(this.withSubcategories);

  final bool withSubcategories;

  @override
  Future<List<Transaction>> build() async => [
    for (final categoryId in [1, if (withSubcategories) 2]) ...[
      Transaction(
        id: categoryId * 10,
        date: DateTime.utc(2035, 10, 15),
        amount: 100,
        type: TransactionType.income,
        idCategory: categoryId,
        idBankAccount: 1,
        recurring: false,
      ),
      Transaction(
        id: categoryId * 10 + 1,
        date: DateTime.utc(2035, 10, 15),
        amount: 25,
        type: TransactionType.expense,
        idCategory: categoryId,
        idBankAccount: 1,
        recurring: false,
      ),
      if (withSubcategories)
        Transaction(
          id: categoryId * 10 + 2,
          date: DateTime.utc(2035, 10, 15),
          amount: 300,
          type: TransactionType.transfer,
          idCategory: categoryId,
          idBankAccount: 1,
          idBankAccountTransfer: 2,
          recurring: false,
        ),
    ],
    if (withSubcategories)
      Transaction(
        id: 30,
        date: DateTime.utc(2035, 10, 15),
        amount: 50,
        type: TransactionType.income,
        idCategory: 3,
        idBankAccount: 1,
        recurring: false,
      ),
  ];
}

class _Currency extends CurrencyState {
  @override
  Currency build() => const Currency(
    id: 1,
    symbol: '€',
    code: 'EUR',
    name: 'Euro',
    mainCurrency: true,
  );
}

void main() {
  for (final withSubcategories in [false, true]) {
    testWidgets(
      'separates category amounts, counts and chart when switching type (subcategories: $withSubcategories)',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            categoriesProvider.overrideWith(_Categories.new),
            transactionsProvider.overrideWith(
              () => _Transactions(withSubcategories),
            ),
            currencyStateProvider.overrideWith(_Currency.new),
          ],
        );
        addTearDown(container.dispose);
        await container.read(categoriesProvider.future);
        await container.read(transactionsProvider.future);
        await container.read(allParentCategoriesProvider.future);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(home: Scaffold(body: CategoriesTab())),
          ),
        );
        await tester.pumpAndSettle();

        for (final type in [
          TransactionType.expense,
          TransactionType.income,
          TransactionType.expense,
        ]) {
          container
              .read(selectedTransactionTypeProvider.notifier)
              .setType(type);
          await tester.pumpAndSettle();

          final isExpense = type == TransactionType.expense;
          final amount = isExpense ? -25.0 : 100.0;
          final multiplier = withSubcategories ? 2 : 1;
          final data = await container.read(
            categoryWithSubcategoriesDataProvider.future,
          );
          final gifts = data.first;
          expect(gifts.total, amount * multiplier);
          expect(gifts.transactions, hasLength(multiplier));
          expect(
            gifts.transactions.every((transaction) => transaction.type == type),
            isTrue,
          );
          expect(
            gifts.subcategories.values,
            withSubcategories ? [amount] : isEmpty,
          );
          expect(data, hasLength(withSubcategories && !isExpense ? 2 : 1));

          final tile = tester
              .widgetList<PanelListTile>(find.byType(PanelListTile))
              .first;
          expect(tile.amount, gifts.total);
          expect(tile.transactions, hasLength(multiplier));
          expect(find.text('$multiplier transactions'), findsWidgets);

          final chart = tester.widget<CategoriesPieChart>(
            find.byType(CategoriesPieChart),
          );
          final total =
              amount * multiplier + (withSubcategories && !isExpense ? 50 : 0);
          expect(chart.amounts[1], amount * multiplier);
          expect(chart.total, total);
          expect(
            find.descendant(
              of: find.byType(CategoriesPieChart),
              matching: find.text('${total.toStringAsFixed(2)} €'),
            ),
            findsOneWidget,
          );
          expect(
            tile.percent,
            closeTo(amount * multiplier / total * 100, 0.001),
          );
        }
      },
    );
  }
}
