import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final requiredAuthenticationStateNotifier = ChangeNotifierProvider(
  (ref) => RequiredAuthenticationState(),
);

class RequiredAuthenticationState extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool userRequiresAuthentication = false;

  RequiredAuthenticationState() {
    _initializeState();
  }

  Future<void> _initializeState() async {
    _prefs = await SharedPreferences.getInstance();
    userRequiresAuthentication =
        _prefs.getBool("user_requires_authentication") ?? false;
    notifyListeners();
  }

  void setAuthenticationRequired() async {
    userRequiresAuthentication = true;
    _prefs.setBool("user_requires_authentication", true);
    notifyListeners();
  }

  void setNoAuthentication() async {
    userRequiresAuthentication = false;
    _prefs.setBool("user_requires_authentication", false);
    notifyListeners();
  }
}
