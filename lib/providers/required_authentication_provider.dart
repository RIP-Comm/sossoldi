import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'required_authentication_provider.g.dart';

@Riverpod(keepAlive: true)
class RequiredAuthenticationState extends _$RequiredAuthenticationState {
  late SharedPreferences _prefs;

  @override
  bool build() {
    _initializeState();
    return false;
  }

  Future<void> _initializeState() async {
    _prefs = await SharedPreferences.getInstance();
    state = _prefs.getBool("user_requires_authentication") ?? false;
  }

  Future<void> setAuthenticationRequired() async {
    state = true;
    await _prefs.setBool("user_requires_authentication", true);
  }

  Future<void> setNoAuthentication() async {
    state = false;
    await _prefs.setBool("user_requires_authentication", false);
  }
}
