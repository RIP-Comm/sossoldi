import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/model/category_transaction.dart';
import 'package:sossoldi/model/currency.dart';
import 'package:sossoldi/pages/transactions/widgets/categories_pie_chart.dart';
import 'package:sossoldi/providers/currency_provider.dart';

class _EuroCurrencyState extends CurrencyState {
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
  testWidgets('a long total stays inside the hole of the donut', (
    tester,
  ) async {
    final category = CategoryTransaction(
      id: 1,
      name: 'Home',
      type: CategoryTransactionType.expense,
      symbol: 'home',
      color: 1,
      order: 0,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [currencyStateProvider.overrideWith(_EuroCurrencyState.new)],
        child: MaterialApp(
          home: Material(
            child: CategoriesPieChart(
              categories: [category],
              amounts: const {1: -1234567.89},
              total: -1234567.89,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The hole has a radius of 70
    final label = tester.getRect(find.text('-1234567.89 €'));
    expect(label.width, lessThanOrEqualTo(140));
  });
}
