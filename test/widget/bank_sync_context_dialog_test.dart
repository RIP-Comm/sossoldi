import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/pages/banking/widgets/bank_sync_context_dialog.dart';

void main() {
  testWidgets(
    'interactive context validates all required values and returns them once',
    (tester) async {
      Map<String, String>? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await showDialog<Map<String, String>>(
                    context: context,
                    builder: (_) => const BankSyncContextDialog(
                      headers: ['Psu-Ip-Address', 'Psu-User-Agent'],
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a value for this request'), findsNWidgets(2));
      await tester.enterText(find.byType(TextFormField).first, 'invalid');
      await tester.enterText(
        find.byType(TextFormField).last,
        'Synthetic client',
      );
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid IP address'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).first, '192.0.2.1');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(result, {
        'Psu-Ip-Address': '192.0.2.1',
        'Psu-User-Agent': 'Synthetic client',
      });
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).first)
            .controller!
            .text,
        isEmpty,
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(result, isNull);
    },
  );
}
