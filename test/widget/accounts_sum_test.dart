import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/material.dart';
import "dart:math";
import 'package:sossoldi/ui/widgets/accounts_sum.dart';
import 'package:sossoldi/model/bank_account.dart';

void main() {
  // Initialize the database factory with sqflite_common_ffi
  databaseFactory = databaseFactoryFfi;

  testWidgets('Properly Render Accounts Widget', (WidgetTester tester) async {
    var accountsList = ['N26', 'Fineco', 'Crypto.com', 'Mediolanum'];
    var amountsList = [3823.56, 0.07, 574.22, 14549.01];

    final random = Random();

    var randomAccount = accountsList[random.nextInt(accountsList.length)];
    var randomValue = amountsList[random.nextInt(amountsList.length)];

    BankAccount randomBankAccount = BankAccount(
      id: 99,
      name: randomAccount,
      symbol: "account_balance",
      color: 0,
      startingValue: randomValue,
      active: true,
      countNetWorth: true,
      mainAccount: false,
    );

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: ProviderScope(child: AccountsSum(account: randomBankAccount)),
      ),
    ));

    FutureBuilder<num?>(
        future: BankAccountMethods().getAccountSum(99),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // Show an error message if the future encounters an error
            return Text('Error: ${snapshot.error}');
          } else {
            final accountSum = snapshot.data ?? 0;
            // TODO need to test total amount with some transactions too
            expect(
                find.text(accountSum.toStringAsFixed(2).replaceAll('.', ','),
                    findRichText: true),
                findsOneWidget);
            return const Text('Ok!');
          }
        });

    expect(find.text(randomAccount), findsOneWidget);
  });
}
