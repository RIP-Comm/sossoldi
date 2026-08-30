import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('main Android manifest grants Internet access to release builds', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(
      manifest,
      contains(
        '<uses-permission '
        'android:name="android.permission.INTERNET"/>',
      ),
    );
  });
}
