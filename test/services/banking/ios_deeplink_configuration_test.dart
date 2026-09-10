import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app_links is the only iOS deep-link handler', () {
    final infoPlist = File('ios/Runner/Info.plist').readAsStringSync();

    expect(
      infoPlist,
      contains(
        '<key>FlutterDeepLinkingEnabled</key>\n'
        '\t<false/>',
      ),
    );
  });
}
