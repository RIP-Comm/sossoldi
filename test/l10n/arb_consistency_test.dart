import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, String> readMessages(File file) {
  final Map<String, dynamic> arb = jsonDecode(file.readAsStringSync());
  return {
    for (final entry in arb.entries)
      if (!entry.key.startsWith('@')) entry.key: entry.value as String,
  };
}

Set<String> placeholders(String message) =>
    RegExp(r'\{(\w+)\}').allMatches(message).map((m) => m.group(1)!).toSet();

void main() {
  final template = readMessages(File('lib/l10n/app_en.arb'));
  final translations = Directory('lib/l10n').listSync().whereType<File>().where(
    (f) => f.path.endsWith('.arb') && !f.path.endsWith('app_en.arb'),
  );

  test('there is at least one translation besides the template', () {
    expect(translations, isNotEmpty);
  });

  for (final file in translations) {
    final name = file.uri.pathSegments.last;
    final messages = readMessages(file);

    test('$name has the same keys as app_en.arb', () {
      expect(messages.keys.toSet(), template.keys.toSet());
    });

    test('$name uses the same placeholders as app_en.arb', () {
      for (final key in template.keys) {
        expect(
          placeholders(messages[key] ?? ''),
          placeholders(template[key]!),
          reason: key,
        );
      }
    });
  }
}
