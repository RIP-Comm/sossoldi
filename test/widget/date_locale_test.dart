import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sossoldi/l10n/app_localizations.dart';
import 'package:sossoldi/providers/locale_provider.dart';
import 'package:sossoldi/providers/settings_provider.dart';

void main() {
  tearDown(() => Intl.defaultLocale = null);

  testWidgets('dates follow the device again after going back to system', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const [Locale('it', 'IT')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPrefProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, _) => MaterialApp(
            locale: ref.watch(appLocaleProvider),
            supportedLocales: supportedAppLocales.keys,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            builder: syncIntlLocale,
            home: Builder(
              builder: (context) => Text(
                '${AppLocalizations.of(context)!.language} '
                '${DateFormat.MMMM().format(DateTime(2026, 10))}',
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.text('Lingua ottobre'), findsOneWidget);

    await container
        .read(appLocaleProvider.notifier)
        .setLocale(const Locale('pt'));
    await tester.pumpAndSettle();
    expect(find.text('Idioma outubro'), findsOneWidget);

    await container.read(appLocaleProvider.notifier).setLocale(null);
    await tester.pumpAndSettle();
    expect(find.text('Lingua ottobre'), findsOneWidget);
  });
}
