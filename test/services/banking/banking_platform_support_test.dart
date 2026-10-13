import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/services/banking/lifecycle/banking_platform_support.dart';

void main() {
  test('feature-gates platforms without a reliable callback registration', () {
    expect(
      BankingPlatformSupport.supportsCallback(
        platform: TargetPlatform.android,
        isWeb: false,
      ),
      isTrue,
    );
    expect(
      BankingPlatformSupport.supportsCallback(
        platform: TargetPlatform.iOS,
        isWeb: false,
      ),
      isTrue,
    );
    expect(
      BankingPlatformSupport.supportsCallback(
        platform: TargetPlatform.macOS,
        isWeb: false,
      ),
      isTrue,
    );
    expect(
      BankingPlatformSupport.supportsCallback(
        platform: TargetPlatform.windows,
        isWeb: false,
      ),
      isFalse,
    );
    expect(
      BankingPlatformSupport.supportsCallback(
        platform: TargetPlatform.linux,
        isWeb: false,
      ),
      isFalse,
    );
    expect(
      BankingPlatformSupport.supportsCallback(
        platform: TargetPlatform.android,
        isWeb: true,
      ),
      isFalse,
    );
  });
}
