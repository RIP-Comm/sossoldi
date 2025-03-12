import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/pages/add_page/widgets/amount_widget.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  databaseFactory = databaseFactoryFfi;
  testWidgets(
    'GIVEN an AmountWidget widget '
    'WHEN a period character is inserted '
    'THEN the period character can be found',
    (WidgetTester tester) async {
      const amountWidgetKey = Key('amountWidgetKey');
      const numberWithOnePeriod = "10.1";

      final amountController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: ProviderScope(
              child: AmountWidget(
                amountController,
                key: amountWidgetKey,
              ),
            ),
          ),
        ),
      );

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
      const amountWidgetKey = Key('amountWidgetKey');
      const numberWithTwoPeriods = "10.1.2";

      final amountController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: ProviderScope(
              child: AmountWidget(
                amountController,
                key: amountWidgetKey,
              ),
            ),
          ),
        ),
      );

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
}
