import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/constants/style.dart';
import 'package:sossoldi/pages/general_options/widgets/selector/selector_tile.dart';
import 'package:sossoldi/utils/app_theme.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../test_utils/tester_extension.dart';

void main() {
  databaseFactory = databaseFactoryFfiNoIsolate;

  const selectorTileKey = Key('selectorTileKey');
  const selectorTileTitle = 'Title';

  Widget selectorTileWidget({
    bool isSelected = false,
    String? trailing,
    Widget? trailingWidget,
    VoidCallback? onTap,
  }) {
    return SelectorTile(
      key: selectorTileKey,
      title: selectorTileTitle,
      trailing: trailing,
      trailingWidget: trailingWidget,
      onTap: onTap,
      isSelected: isSelected,
    );
  }

  testWidgets(
    'GIVEN an SelectorTile widget '
    'THEN it can be found by its key',
    (WidgetTester tester) async {
      await tester.pumpWidgetWithMaterialApp(selectorTileWidget());

      final findSelectorTileKey = find.byKey(selectorTileKey);
      expect(findSelectorTileKey, findsOneWidget);
    },
  );

  testWidgets(
    'GIVEN an SelectorTile widget '
    'WHEN title is not null '
    'THEN the title can be found',
    (WidgetTester tester) async {
      await tester.pumpWidgetWithMaterialApp(
        selectorTileWidget(),
      );

      final findSelectorTileTitle = find.text(selectorTileTitle);
      expect(findSelectorTileTitle, findsOneWidget);
    },
  );

  testWidgets(
    'GIVEN an SelectorTile widget '
    'WHEN onTap is not null '
    'THEN completer is completed',
    (WidgetTester tester) async {
      final completer = Completer<void>();

      await tester.pumpWidgetWithMaterialApp(
        selectorTileWidget(
          onTap: completer.complete,
        ),
      );

      final findSelectorTileKey = find.byKey(selectorTileKey);

      expect(completer.isCompleted, isFalse);
      await tester.tap(findSelectorTileKey);
      expect(completer.isCompleted, isTrue);
    },
  );

  testWidgets(
    'GIVEN an SelectorTile widget '
    'WHEN trailing is not null '
    'THEN trailing is found',
    (WidgetTester tester) async {
      const trailingString = 'Trailing';

      await tester.pumpWidgetWithMaterialApp(
        selectorTileWidget(
          trailing: trailingString,
        ),
      );

      final findTrailingString = find.text(trailingString);
      expect(findTrailingString, findsOneWidget);
    },
  );

  testWidgets(
    'GIVEN an SelectorTile widget '
    'WHEN trailingWidget is not null '
    'THEN trailingWidget is found',
    (WidgetTester tester) async {
      const trailingKey = Key('trailingKey');
      const trailingString = SizedBox(key: trailingKey);

      await tester.pumpWidgetWithMaterialApp(
        selectorTileWidget(
          trailingWidget: trailingString,
        ),
      );

      final findTrailingWidget = find.byKey(trailingKey);
      expect(findTrailingWidget, findsOneWidget);
    },
  );

  testWidgets(
    'GIVEN an SelectorTile widget '
    'WHEN isSelected is false '
    'THEN border width is 0.5',
    (WidgetTester tester) async {
      const unselectedBorderWidth = .5;

      await tester.pumpWidgetWithMaterialApp(
        selectorTileWidget(),
      );

      final findSelectorTile = find.byKey(selectorTileKey);
      final findSelectorTileDescendants = find.descendant(
          of: findSelectorTile, matching: find.byType(Container));

      final selectorTileContainer =
          findSelectorTileDescendants.evaluate().first.widget as Container;
      final selectorTileBoxDecoration =
          selectorTileContainer.foregroundDecoration as BoxDecoration;
      final selectorBorder = selectorTileBoxDecoration.border as Border;

      expect(
        selectorBorder.top.width,
        equals(unselectedBorderWidth),
      );
      expect(
        selectorBorder.bottom.width,
        equals(unselectedBorderWidth),
      );
      expect(
        selectorBorder.left.width,
        equals(unselectedBorderWidth),
      );
      expect(
        selectorBorder.right.width,
        equals(unselectedBorderWidth),
      );
    },
  );

  testWidgets(
    'GIVEN an SelectorTile widget '
    'WHEN isSelected is true '
    'THEN border width is 1',
    (WidgetTester tester) async {
      const selectedBorderWidth = 1.0;

      await tester.pumpWidgetWithMaterialApp(
        selectorTileWidget(
          isSelected: true,
        ),
      );

      final findSelectorTile = find.byKey(selectorTileKey);
      final findSelectorTileDescendants = find.descendant(
          of: findSelectorTile, matching: find.byType(Container));

      final selectorTileContainer =
          findSelectorTileDescendants.evaluate().first.widget as Container;
      final selectorTileBoxDecoration =
          selectorTileContainer.foregroundDecoration as BoxDecoration;
      final selectorBorder = selectorTileBoxDecoration.border as Border;

      expect(
        selectorBorder.top.width,
        equals(selectedBorderWidth),
      );
      expect(
        selectorBorder.bottom.width,
        equals(selectedBorderWidth),
      );
      expect(
        selectorBorder.left.width,
        equals(selectedBorderWidth),
      );
      expect(
        selectorBorder.right.width,
        equals(selectedBorderWidth),
      );
    },
  );

  testWidgets(
    'GIVEN an SelectorTile widget '
    'WHEN isSelected is true '
    'THEN border color is blue5 in light mode',
    (WidgetTester tester) async {
      const selectedBorderColorLight = blue5;

      await tester.pumpWidgetWithMaterialApp(
        Builder(
          builder: (context) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: customColorScheme,
              ),
              child: selectorTileWidget(
                isSelected: true,
              ),
            );
          },
        ),
      );

      final findSelectorTile = find.byKey(selectorTileKey);
      final findSelectorTileDescendants = find.descendant(
        of: findSelectorTile,
        matching: find.byType(Container),
      );

      final selectorTileContainer =
          findSelectorTileDescendants.evaluate().first.widget as Container;
      final selectorTileBoxDecoration =
          selectorTileContainer.foregroundDecoration as BoxDecoration;
      final selectorBorder = selectorTileBoxDecoration.border as Border;

      expect(
        selectorBorder.top.color,
        equals(selectedBorderColorLight),
      );
      expect(
        selectorBorder.bottom.color,
        equals(selectedBorderColorLight),
      );
      expect(
        selectorBorder.right.color,
        equals(selectedBorderColorLight),
      );
      expect(
        selectorBorder.left.color,
        equals(selectedBorderColorLight),
      );
    },
  );

  testWidgets(
    'GIVEN an SelectorTile widget '
    'WHEN isSelected is true '
    'THEN border color is darkBlue6 in dark mode',
    (WidgetTester tester) async {
      const selectedBorderColorDark = darkBlue6;

      await tester.pumpWidgetWithMaterialApp(
        Builder(
          builder: (context) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: darkCustomColorScheme,
              ),
              child: selectorTileWidget(
                isSelected: true,
              ),
            );
          },
        ),
      );

      final findSelectorTile = find.byKey(selectorTileKey);
      final findSelectorTileDescendants = find.descendant(
        of: findSelectorTile,
        matching: find.byType(Container),
      );

      final selectorTileContainer =
          findSelectorTileDescendants.evaluate().first.widget as Container;
      final selectorTileBoxDecoration =
          selectorTileContainer.foregroundDecoration as BoxDecoration;
      final selectorBorder = selectorTileBoxDecoration.border as Border;

      expect(
        selectorBorder.top.color,
        equals(selectedBorderColorDark),
      );
      expect(
        selectorBorder.bottom.color,
        equals(selectedBorderColorDark),
      );
      expect(
        selectorBorder.right.color,
        equals(selectedBorderColorDark),
      );
      expect(
        selectorBorder.left.color,
        equals(selectedBorderColorDark),
      );
    },
  );

  testWidgets(
    'GIVEN an SelectorTile widget '
    'WHEN isSelected is false '
    'THEN border color is grey2 in light mode',
    (WidgetTester tester) async {
      const unselectedBorderColorLight = grey2;

      await tester.pumpWidgetWithMaterialApp(
        Builder(
          builder: (context) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: customColorScheme,
              ),
              child: selectorTileWidget(),
            );
          },
        ),
      );

      final findSelectorTile = find.byKey(selectorTileKey);
      final findSelectorTileDescendants = find.descendant(
        of: findSelectorTile,
        matching: find.byType(Container),
      );

      final selectorTileContainer =
          findSelectorTileDescendants.evaluate().first.widget as Container;
      final selectorTileBoxDecoration =
          selectorTileContainer.foregroundDecoration as BoxDecoration;
      final selectorBorder = selectorTileBoxDecoration.border as Border;

      expect(
        selectorBorder.top.color,
        equals(unselectedBorderColorLight),
      );
      expect(
        selectorBorder.bottom.color,
        equals(unselectedBorderColorLight),
      );
      expect(
        selectorBorder.right.color,
        equals(unselectedBorderColorLight),
      );
      expect(
        selectorBorder.left.color,
        equals(unselectedBorderColorLight),
      );
    },
  );

    testWidgets(
    'GIVEN an SelectorTile widget '
    'WHEN isSelected is false '
    'THEN border color is grey2 in dark mode',
    (WidgetTester tester) async {
      const unselectedBorderColorLight = grey2;

      await tester.pumpWidgetWithMaterialApp(
        Builder(
          builder: (context) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: darkCustomColorScheme,
              ),
              child: selectorTileWidget(),
            );
          },
        ),
      );

      final findSelectorTile = find.byKey(selectorTileKey);
      final findSelectorTileDescendants = find.descendant(
        of: findSelectorTile,
        matching: find.byType(Container),
      );

      final selectorTileContainer =
          findSelectorTileDescendants.evaluate().first.widget as Container;
      final selectorTileBoxDecoration =
          selectorTileContainer.foregroundDecoration as BoxDecoration;
      final selectorBorder = selectorTileBoxDecoration.border as Border;

      expect(
        selectorBorder.top.color,
        equals(unselectedBorderColorLight),
      );
      expect(
        selectorBorder.bottom.color,
        equals(unselectedBorderColorLight),
      );
      expect(
        selectorBorder.right.color,
        equals(unselectedBorderColorLight),
      );
      expect(
        selectorBorder.left.color,
        equals(unselectedBorderColorLight),
      );
    },
  );
}
