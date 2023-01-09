import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import "dart:math";
import 'package:sossoldi/custom_widgets/accounts_sum.dart';

void main() {
    testWidgets('Properly Render Accounts Widget', (WidgetTester tester) async {
      var accountsList = ['N26','Fineco','Crypto.com','Mediolanum'];
      var amountsList = [3823.56,0.07,574.22,14549.01];

      final random = Random();

      var randomAccount = accountsList[random.nextInt(accountsList.length)];
      var randomValue = amountsList[random.nextInt(amountsList.length)];

      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: AccountsSum(accountName: randomAccount, amount: randomValue),
        ),
      ));

      expect(find.text(randomAccount), findsOneWidget);
      expect(find.text("$randomValue€", findRichText: true), findsOneWidget);
    });
}