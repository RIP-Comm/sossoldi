import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constants.dart';

// Define enum for theme modes
enum AppThemeMode {
  light,
  dark,
  system
}

final appThemeStateNotifier = ChangeNotifierProvider(
      (ref) => AppThemeState(),
);

class AppThemeState extends ChangeNotifier {
  static const String _themeKey = 'themeMode';
  late SharedPreferences _prefs;

  AppThemeMode _themeMode = AppThemeMode.system;
  bool isDarkModeEnabled = false;

  AppThemeMode get themeMode => _themeMode;

  AppThemeState() {
    _loadTheme();
  }

  // Initialize and load saved theme
  Future<void> _loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    final storedThemeMode = _prefs.getInt(_themeKey) ?? 0;
    _themeMode = AppThemeMode.values[storedThemeMode];

    // Determine if dark mode is enabled based on theme mode
    if (_themeMode == AppThemeMode.system) {
      isDarkModeEnabled = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
      _setupSystemThemeListener();
    } else {
      isDarkModeEnabled = _themeMode == AppThemeMode.dark;
    }

    updateColorsBasedOnTheme(isDarkModeEnabled);
    notifyListeners();
  }

  void _setupSystemThemeListener() {
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
      if (_themeMode == AppThemeMode.system) {
        final isDark = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
        if (isDarkModeEnabled != isDark) {
          isDarkModeEnabled = isDark;
          updateColorsBasedOnTheme(isDarkModeEnabled);
          notifyListeners();
        }
      }
    };
  }

  // Save theme preference
  Future<void> _saveThemeMode(AppThemeMode mode) async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs.setInt(_themeKey, mode.index);
    _themeMode = mode;
  }

  void setLightTheme() {
    _saveThemeMode(AppThemeMode.light);
    isDarkModeEnabled = false;
    updateColorsBasedOnTheme(isDarkModeEnabled);
    notifyListeners();
  }

  void setDarkTheme() {
    _saveThemeMode(AppThemeMode.dark);
    isDarkModeEnabled = true;
    updateColorsBasedOnTheme(isDarkModeEnabled);
    notifyListeners();
  }

  void setSystemTheme() {
    _saveThemeMode(AppThemeMode.system);
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    isDarkModeEnabled = brightness == Brightness.dark;
    updateColorsBasedOnTheme(isDarkModeEnabled);
    _setupSystemThemeListener();
    notifyListeners();
  }
}