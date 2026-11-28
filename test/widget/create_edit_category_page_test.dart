import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/l10n/app_localizations.dart';
import 'package:sossoldi/model/category_transaction.dart';
import 'package:sossoldi/pages/categories/create_edit_category_page.dart';

void main() {
  Future<void> openTypeSelector(
    WidgetTester tester, {
    bool hideIncome = false,
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CreateEditCategoryPage(hideIncome: hideIncome),
        ),
      ),
    );
    await tester.tap(find.byType(DropdownButton<CategoryTransactionType>));
    await tester.pumpAndSettle();
  }

  testWidgets('offers an income and expense category type', (tester) async {
    await openTypeSelector(tester);

    expect(find.text('Income'), findsOneWidget);
    expect(find.text('Expense'), findsNWidgets(2));
    expect(find.text('Income & Expense'), findsOneWidget);
  });

  testWidgets('shows the category types in the app language', (tester) async {
    await openTypeSelector(tester, locale: const Locale('it'));

    expect(find.text('Entrata'), findsOneWidget);
    expect(find.text('Spesa'), findsNWidgets(2));
    expect(find.text('Entrata e spesa'), findsOneWidget);
    expect(find.text('Income & Expense'), findsNothing);
  });

  testWidgets('keeps dual categories available for budgets', (tester) async {
    await openTypeSelector(tester, hideIncome: true);

    expect(find.text('Income'), findsNothing);
    expect(find.text('Expense'), findsNWidgets(2));
    expect(find.text('Income & Expense'), findsOneWidget);
  });
}
