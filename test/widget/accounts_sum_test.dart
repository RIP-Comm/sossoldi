import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sossoldi/model/bank_account.dart';
import 'package:sossoldi/model/currency.dart';
import 'package:sossoldi/pages/dashboard/widgets/accounts_sum.dart';
import 'package:sossoldi/providers/currency_provider.dart';
import 'package:sossoldi/providers/settings_provider.dart';

class _TestCurrencyState extends CurrencyState {
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
  testWidgets(
    'Account summary renders its supplied total and selected currency',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'visibility_amount': true});
      final preferences = await SharedPreferences.getInstance();
      const account = BankAccount(
        id: 99,
        name: 'Synthetic account',
        symbol: 'account_balance',
        color: 0,
        startingValue: 305.89,
        total: 232.75,
        active: true,
        countNetWorth: true,
        mainAccount: false,
        order: 2,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: ProviderScope(
              overrides: [
                sharedPrefProvider.overrideWithValue(preferences),
                currencyStateProvider.overrideWith(_TestCurrencyState.new),
              ],
              child: const AccountsSum(account: account),
            ),
          ),
        ),
      );

      expect(find.text('Synthetic account'), findsOneWidget);
      expect(find.text('232.75€', findRichText: true), findsOneWidget);
      expect(find.text('305.89€', findRichText: true), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
