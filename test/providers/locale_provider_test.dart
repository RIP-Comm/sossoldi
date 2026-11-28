import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sossoldi/providers/locale_provider.dart';
import 'package:sossoldi/providers/settings_provider.dart';

Future<ProviderContainer> buildContainer(Map<String, Object> prefs) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sharedPreferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPrefProvider.overrideWithValue(sharedPreferences)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('follows the device language when nothing is saved', () async {
    final container = await buildContainer({});

    expect(container.read(appLocaleProvider), isNull);
  });

  test('restores the saved language', () async {
    final container = await buildContainer({'app_locale': 'it'});

    expect(container.read(appLocaleProvider), const Locale('it'));
  });

  test('ignores a saved language that is no longer supported', () async {
    final container = await buildContainer({'app_locale': 'fr'});

    expect(container.read(appLocaleProvider), isNull);
  });

  test('saves the chosen language and clears it for the system one', () async {
    final container = await buildContainer({});
    final prefs = container.read(sharedPrefProvider);

    await container
        .read(appLocaleProvider.notifier)
        .setLocale(const Locale('pt'));
    expect(container.read(appLocaleProvider), const Locale('pt'));
    expect(prefs.getString('app_locale'), 'pt');

    await container.read(appLocaleProvider.notifier).setLocale(null);
    expect(container.read(appLocaleProvider), isNull);
    expect(prefs.containsKey('app_locale'), isFalse);
  });
}
