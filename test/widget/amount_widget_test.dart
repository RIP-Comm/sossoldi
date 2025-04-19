import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/custom_widgets/amount_widget.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // I'm not 100% familiar with how this works but for some reason when adding the last two test cases
  // it would throw an error after the tests were completed successfully.
  //
  // Seems like using the NoIsolate solves the problem.
  databaseFactory = databaseFactoryFfiNoIsolate;

  const amountWidgetKey = Key('amountWidgetKey');
  var amountController = TextEditingController();

  setUp(() {
    amountController = TextEditingController();
  });

  Widget amountWidget() {
    return MaterialApp(
      home: Material(
        child: ProviderScope(
          child: AmountWidget(
            amountController,
            key: amountWidgetKey,
          ),
        ),
      ),
    );
  }

  testWidgets(
    'GIVEN an AmountWidget widget '
    'WHEN a period character is inserted '
    'THEN the period character can be found',
    (WidgetTester tester) async {
      const numberWithOnePeriod = "10.1";

      await tester.pumpWidget(amountWidget());

      final findAmountWidget = find.byKey(amountWidgetKey);
      expect(findAmountWidget, findsOneWidget);

      await tester.tap(findAmountWidget);
      await tester.pumpAndSettle();

      await tester.enterText(findAmountWidget, numberWithOnePeriod);

      final findPeriod = find.textContaining('.');
      expect(findPeriod, findsOne);
      expect(amountController.text, equals(numberWithOnePeriod));
    },
  );

  testWidgets(
    'GIVEN an AmountWidget widget '
    'WHEN more than one period characters are inserted '
    'THEN no text is found',
    (WidgetTester tester) async {
      const numberWithTwoPeriods = "10.1.2";

      await tester.pumpWidget(amountWidget());

      final findAmountWidget = find.byKey(amountWidgetKey);
      expect(findAmountWidget, findsOneWidget);

      await tester.tap(findAmountWidget);
      await tester.pumpAndSettle();

      await tester.enterText(findAmountWidget, numberWithTwoPeriods);

      final findPeriod = find.textContaining('.');
      expect(findPeriod, findsNothing);
      expect(amountController.text.isEmpty, isTrue);
    },
  );

  testWidgets(
    'GIVEN an AmountWidget widget '
    'WHEN a comma is used instead of a period '
    'THEN the comma is replaced with a period',
    (WidgetTester tester) async {
      const numberWithComma = "10,1";

      await tester.pumpWidget(amountWidget());

      final findAmountWidget = find.byKey(amountWidgetKey);
      expect(findAmountWidget, findsOneWidget);

      await tester.tap(findAmountWidget);
      await tester.pumpAndSettle();

      await tester.enterText(findAmountWidget, numberWithComma);

      final findPeriod = find.textContaining('.');
      expect(findPeriod, findsOneWidget);
      expect(
        amountController.text,
        equals(
          numberWithComma.replaceAll(',', '.'),
        ),
      );
    },
  );

  testWidgets(
    'GIVEN an AmountWidget widget '
    'WHEN a number with more than two decimal digits is used '
    'THEN the number is not allowed',
    (WidgetTester tester) async {
      const numberWithThreeDecimals = "10.123";

      await tester.pumpWidget(amountWidget());

      final findAmountWidget = find.byKey(amountWidgetKey);
      expect(findAmountWidget, findsOneWidget);

      await tester.tap(findAmountWidget);
      await tester.pumpAndSettle();

      await tester.enterText(findAmountWidget, numberWithThreeDecimals);

      final findPeriod = find.textContaining('.');
      expect(findPeriod, findsNothing);
      expect(amountController.text.isEmpty, isTrue);
    },
  );
}
