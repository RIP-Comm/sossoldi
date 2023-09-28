
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';

final appThemeStateNotifier = ChangeNotifierProvider(
  (ref) => AppThemeState(),
);

class AppThemeState extends ChangeNotifier {
  var isDarkModeEnabled = false;
  
  void setLightTheme(){
    isDarkModeEnabled = false;
    notifyListeners();
  }

  void setDarkTheme(){
    isDarkModeEnabled = true;
    notifyListeners();
  }
}