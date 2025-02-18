import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constants.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';

final appThemeStateNotifier = ChangeNotifierProvider(
  (ref) => AppThemeState(),
);

class AppThemeState extends ChangeNotifier {
  static const String _themeKey = 'isDarkMode';
  late SharedPreferences _prefs;
  var isDarkModeEnabled = false;

  AppThemeState() {
    _loadTheme();
  }

  // Initialize and load saved theme
  Future<void> _loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    isDarkModeEnabled = _prefs.getBool(_themeKey) ?? false;
    updateColorsBasedOnTheme(isDarkModeEnabled);
    notifyListeners();
  }

  // Save theme preference
  Future<void> _saveTheme(bool isDark) async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs.setBool(_themeKey, isDark);
  }

  void setLightTheme() {
    isDarkModeEnabled = false;
    updateColorsBasedOnTheme(isDarkModeEnabled);
    _saveTheme(isDarkModeEnabled);
    notifyListeners();
  }

  void setDarkTheme() {
    isDarkModeEnabled = true;
    updateColorsBasedOnTheme(isDarkModeEnabled);
    _saveTheme(isDarkModeEnabled);
    notifyListeners();
  }
}
