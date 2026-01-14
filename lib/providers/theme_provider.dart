import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants/constants.dart';
import 'settings_provider.dart';

part 'theme_provider.g.dart';

class ThemeState {
  final bool isDarkModeEnabled;

  ThemeState(this.isDarkModeEnabled);
}

@Riverpod(keepAlive: true)
class AppThemeState extends _$AppThemeState {
  static const String _themeKey = 'isDarkMode';

  @override
  ThemeState build() {
    final prefs = ref.read(sharedPrefProvider);
    final isDark = prefs.getBool(_themeKey) ?? false;
    return ThemeState(isDark);
  }

  Future<void> updateTheme() async {
    final prefs = ref.read(sharedPrefProvider);
    final isDarkMode = state.isDarkModeEnabled;
    updateColorsBasedOnTheme(!isDarkMode);
    await prefs.setBool(_themeKey, !isDarkMode);
    state = ThemeState(!isDarkMode);
  }
}
