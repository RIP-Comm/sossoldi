import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/l10n/app_localizations.dart';
import 'package:sossoldi/model/bank_account.dart';
import 'package:sossoldi/pages/accounts/widgets/confirm_account_deletion_dialog.dart';
import 'package:sossoldi/pages/settings/general/widgets/language_selector_dialog.dart';
import 'package:sossoldi/providers/locale_provider.dart';
import 'package:sossoldi/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final account = BankAccount(
    id: 1,
    name: 'Revolut',
    symbol: 'symbol',
    color: 0,
    startingValue: 0,
    active: true,
    countNetWorth: true,
    mainAccount: false,
    order: 0,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  Widget buildApp(Locale locale) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: ConfirmAccountDeletionDialog(account: account, onPressed: () {}),
    );
  }

  testWidgets('account deletion dialog is shown in English', (tester) async {
    await tester.pumpWidget(buildApp(const Locale('en')));

    expect(find.text('Delete account'), findsOneWidget);
    expect(
      find.text('Are you sure you want to delete the account named "Revolut"?'),
      findsOneWidget,
    );
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('account deletion dialog is shown in Italian', (tester) async {
    await tester.pumpWidget(buildApp(const Locale('it')));

    expect(find.text('Elimina conto'), findsOneWidget);
    expect(
      find.text('Vuoi davvero eliminare il conto "Revolut"?'),
      findsOneWidget,
    );
    expect(find.text('Annulla'), findsOneWidget);
  });

  testWidgets('choosing a language in the selector switches the app', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPrefProvider.overrideWithValue(prefs)],
        child: Consumer(
          builder: (context, ref, _) => MaterialApp(
            locale: ref.watch(appLocaleProvider) ?? const Locale('en'),
            supportedLocales: supportedAppLocales.keys,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () =>
                    LanguageSelectorDialog.selectLanguageDialog(context),
                child: Text(AppLocalizations.of(context)!.language),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    expect(find.text('System language'), findsOneWidget);

    await tester.tap(find.text('Italiano'));
    await tester.pumpAndSettle();

    expect(find.text('Lingua'), findsOneWidget);
    expect(prefs.getString('app_locale'), 'it');
  });
}
