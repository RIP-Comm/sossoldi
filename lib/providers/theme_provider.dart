import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appThemeStateNotifier = ChangeNotifierProvider(
  (ref) => AppThemeState(),
);

class AppThemeState extends ChangeNotifier {
  static const String _themeKey = 'themeMode';
  late SharedPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.system;

  bool get isDarkModeEnabled => _themeMode == ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  AppThemeState() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    final storedThemeMode = _prefs.getString(_themeKey) ?? ThemeMode.system.name;
    _themeMode = switch (storedThemeMode) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
    notifyListeners();
  }

  Future<void> setTheme({required ThemeMode mode}) async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs.setString(_themeKey, mode.name);
    _themeMode = mode;
    notifyListeners();
  }

  void setNextTheme() {
    if (_themeMode == ThemeMode.light) {
      setTheme(mode: ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      setTheme(mode: ThemeMode.system);
    } else {
      setTheme(mode: ThemeMode.light);
    }
  }
}
