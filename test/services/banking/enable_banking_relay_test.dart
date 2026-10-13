import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('versioned HTTPS relay forwards the callback to the app scheme', () {
    final relay = File(
      'docs/enablebanking/eb-callback.html',
    ).readAsStringSync();

    expect(relay, contains("'sossoldi://eb-callback'"));
    expect(relay, contains('window.location.search'));
    expect(relay, isNot(contains('<script src=')));
  });
}
