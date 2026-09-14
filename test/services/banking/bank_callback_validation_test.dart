// dart format width=400

import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/services/banking/lifecycle/bank_deeplink_service.dart';

void main() {
  for (final value in [
    'https://eb-callback?code=c&state=s',
    'sossoldi://wrong?code=c&state=s',
    'sossoldi://eb-callback/path?code=c&state=s',
    'sossoldi://eb-callback:123?code=c&state=s',
    'sossoldi://eb-callback?code=c&state=s&state=s',
    'sossoldi://eb-callback?code=c&code=d&state=s',
    'sossoldi://eb-callback?code=c&state=s&error=denied',
    'sossoldi://eb-callback?code=&state=s',
    'sossoldi://eb-callback?code=%20&state=s',
    'sossoldi://eb-callback?state=s',
    'sossoldi://eb-callback?code=c',
    'sossoldi://eb-callback?code=c&state=',
    'sossoldi://eb-callback?code=c&state=s#fragment',
    'sossoldi://user@eb-callback?code=c&state=s',
    'sossoldi://eb-callback?error=denied&error=denied&state=s',
    'sossoldi://eb-callback?error=&state=s',
    'sossoldi://eb-callback?error=denied&state=s&error_description=a&error_description=b',
  ]) {
    test('rejects malformed callback before lifecycle dispatch: $value', () {
      expect(BankDeeplinkService.parse(Uri.parse(value)), isNull);
    });
  }

  test('extracts the code and state for lifecycle validation without changing them', () {
    final callback = BankDeeplinkService.parse(Uri.parse('sossoldi://eb-callback?code=a%2Bb%2Fc&state=persisted-state'))!;
    expect(callback.code, 'a+b/c');
    expect(callback.state, 'persisted-state');
    expect(callback.error, isNull);
  });

  test('preserves cancellation callbacks for lifecycle cleanup', () {
    final callback = BankDeeplinkService.parse(Uri.parse('sossoldi://eb-callback?error=access_denied&error_description=Cancelled&state=persisted-state'))!;
    expect(callback.code, isNull);
    expect(callback.state, 'persisted-state');
    expect(callback.error, 'access_denied');
    expect(callback.errorDescription, 'Cancelled');
    expect(callback.isSuccess, isFalse);
  });
}
