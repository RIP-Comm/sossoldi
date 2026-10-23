import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'settings_provider.dart';

part 'locale_provider.g.dart';

/// Languages offered to users, with their name in that language.
/// English comes first so it is the fallback for unsupported languages.
final Map<Locale, String> supportedAppLocales = {
  const Locale('en'): 'English',
  const Locale('it'): 'Italiano',
  const Locale('pt'): 'Português',
};

/// [MaterialApp.builder] that keeps [Intl.defaultLocale], used by DateFormat
/// for month and weekday names, in sync with the language shown by the app.
Widget syncIntlLocale(BuildContext context, Widget? child) {
  Intl.defaultLocale = Localizations.localeOf(context).languageCode;
  return child!;
}

/// The language chosen in the settings, or null to follow the device.
@Riverpod(keepAlive: true)
class AppLocale extends _$AppLocale {
  static const String _localeKey = 'app_locale';

  @override
  Locale? build() {
    final prefs = ref.read(sharedPrefProvider);
    final code = prefs.getString(_localeKey);
    if (code == null) return null;
    final locale = Locale(code);
    return supportedAppLocales.containsKey(locale) ? locale : null;
  }

  Future<void> setLocale(Locale? locale) async {
    final prefs = ref.read(sharedPrefProvider);
    if (locale == null) {
      await prefs.remove(_localeKey);
    } else {
      await prefs.setString(_localeKey, locale.languageCode);
    }
    state = locale;
  }
}
