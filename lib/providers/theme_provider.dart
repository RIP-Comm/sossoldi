import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/constants.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appThemeStateNotifier = ChangeNotifierProvider(
      (ref) => AppThemeState(),
);

class AppThemeState extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system; // Impostato di default su system

  AppThemeState() {
    loadThemePreference();
  }

  Future<void> saveThemePreference(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', theme);
  }

  Future<void> loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString('themeMode') ?? 'system';
    if (themeModeString == 'light') {
      themeMode = ThemeMode.light;
    } else if (themeModeString == 'dark') {
      themeMode = ThemeMode.dark;
    } else {
      themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  void setLightTheme() async {
    themeMode = ThemeMode.light;
    notifyListeners();
    await saveThemePreference('light');
  }

  void setDarkTheme() async {
    themeMode = ThemeMode.dark;
    notifyListeners();
    await saveThemePreference('dark');
  }

  void setAutoTheme() async {
    themeMode = ThemeMode.system;
    notifyListeners();
    await saveThemePreference('system');
  }

}
