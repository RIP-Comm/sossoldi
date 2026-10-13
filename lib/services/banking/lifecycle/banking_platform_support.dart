import 'package:flutter/foundation.dart';

class BankingPlatformSupport {
  const BankingPlatformSupport._();

  static bool supportsCallback({
    TargetPlatform? platform,
    bool isWeb = kIsWeb,
  }) {
    if (isWeb) return false;
    return switch (platform ?? defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS => true,
      TargetPlatform.windows ||
      TargetPlatform.linux ||
      TargetPlatform.fuchsia => false,
    };
  }
}
