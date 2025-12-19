import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constants.dart';

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
    _loadTheme();
    return ThemeState(false);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    state = ThemeState(isDark);
    updateColorsBasedOnTheme(isDark);
  }

  // Save theme preference
  Future<void> _saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  void setLightTheme() {
    state = ThemeState(false);
    updateColorsBasedOnTheme(false);
    _saveTheme(false);
  }

  void setDarkTheme() {
    state = ThemeState(true);
    updateColorsBasedOnTheme(true);
    _saveTheme(true);
  }
}
