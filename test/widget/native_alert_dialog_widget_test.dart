import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/shared/widgets/native_alert_dialog.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  databaseFactory = databaseFactoryFfi;

  const adaptiveDialogKey = Key('adaptiveDialogKey');
  const buttonLabel = 'Label';
  const firstAction = 'First';
  const secondAction = 'Second';

  var completer = Completer<void>();

  setUp(() {
    completer = Completer<void>();
  });

  Widget buildDialog() {
    return Builder(
      builder: (context) {
        return TextButton(
          child: Text(buttonLabel),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AdaptiveDialog(
                  key: adaptiveDialogKey,
                  actions: [
                    AdaptiveDialogAction(
                      child: Text(firstAction),
                      onPressed: completer.complete,
                    ),
                    AdaptiveDialogAction(
                      child: Text(secondAction),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  testWidgets(
    'GIVEN an AdaptiveDialog widget '
    'WHEN the dialog is shown '
    'THEN it can be found through its key',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: ProviderScope(
              child: buildDialog(),
            ),
          ),
        ),
      );

      final findButton = find.text(buttonLabel);
      expect(findButton, findsOneWidget);

      await tester.tap(findButton);
      await tester.pumpAndSettle();

      final findDialogByKey = find.byKey(adaptiveDialogKey);
      expect(findDialogByKey, findsOneWidget);
    },
  );

  testWidgets(
    'GIVEN an AdaptiveDialog widget '
    'WHEN the dialog is shown '
    'AND a button is tapped '
    'THEN the completer completes',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: ProviderScope(
              child: buildDialog(),
            ),
          ),
        ),
      );

      final findButton = find.text(buttonLabel);
      expect(findButton, findsOneWidget);

      await tester.tap(findButton);
      await tester.pumpAndSettle();

      final findFirstAction = find.text(firstAction);
      expect(findFirstAction, findsOneWidget);

      expect(completer.isCompleted, isFalse);
      await tester.tap(findFirstAction);
      expect(completer.isCompleted, isTrue);
    },
  );

  testWidgets(
    'GIVEN an AdaptiveDialog widget '
    'WHEN the dialog is shown '
    'AND a pop is invoked '
    'THEN the dialog route is popped',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: ProviderScope(
              child: buildDialog(),
            ),
          ),
        ),
      );

      final findButton = find.text(buttonLabel);
      expect(findButton, findsOneWidget);

      await tester.tap(findButton);
      await tester.pumpAndSettle();

      final findSecondAction = find.text(secondAction);
      expect(findSecondAction, findsOneWidget);

      await tester.tap(findSecondAction);
      await tester.pumpAndSettle();

      final findDialog = find.byKey(adaptiveDialogKey);
      expect(findDialog, findsNothing);
    },
  );
}
