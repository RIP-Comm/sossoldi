import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'settings_provider.dart';

part 'authentication_provider.g.dart';

@Riverpod(keepAlive: true)
class AuthenticationState extends _$AuthenticationState {
  static const String _authKey = 'user_requires_authentication';

  @override
  bool build() {
    final prefs = ref.read(sharedPrefProvider);
    return prefs.getBool(_authKey) ?? false;
  }

  Future<void> updateAuthentication() async {
    final prefs = ref.read(sharedPrefProvider);
    await prefs.setBool(_authKey, !state);
    state = !state;
  }
}
