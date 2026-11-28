import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widgets whose positional string argument is shown to the user.
const textWidgets = {'Text', 'TextSpan', 'SelectableText'};

/// Named arguments whose string value is shown to the user.
const textArguments = {
  'body',
  'content',
  'counterText',
  'description',
  'errorText',
  'helperText',
  'hintText',
  'label',
  'labelText',
  'message',
  'prefixText',
  'semanticLabel',
  'semanticsLabel',
  'subtitle',
  'suffixText',
  'text',
  'title',
  'tooltip',
};

/// Texts that are allowed to stay hardcoded, by file.
const allowed = {
  // App name
  'lib/main.dart': {'Sossoldi'},
  // Developer menu, only visible after enabling the developer options
  'lib/pages/settings/settings_page.dart': {
    'Developer options activated.',
    'OK',
    'WARNING: tapping on any button on the red bar, erases permanently your data. Do it at your own risk',
    '[DEV ONLY]\nDANGEROUS\nZONE',
    'RESET DB',
    'CLEAR AND FILL DEMO DATA',
    'DB Cleared, and DEMO data added',
  },
};

/// Folders whose strings never reach the UI.
const ignoredFolders = ['lib/l10n/', 'lib/services/database/migrations/'];

class _HardcodedStringFinder extends RecursiveAstVisitor<void> {
  _HardcodedStringFinder(this.unit);

  final CompilationUnit unit;
  final List<(int, String)> found = [];

  @override
  void visitAdjacentStrings(AdjacentStrings node) => _check(node);

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) => _check(node);

  @override
  void visitStringInterpolation(StringInterpolation node) {
    _check(node);
    // Interpolated expressions can contain other user facing strings
    super.visitStringInterpolation(node);
  }

  void _check(StringLiteral node) {
    if (node.parent is AdjacentStrings || !_isShownToUser(node)) return;
    final text = _literalText(node);
    if (RegExp('[A-Za-z]{2,}').hasMatch(text)) {
      found.add((unit.lineInfo.getLocation(node.offset).lineNumber, text));
    }
  }

  static String _literalText(StringLiteral node) => switch (node) {
    SimpleStringLiteral() => node.value,
    AdjacentStrings() => node.strings.map(_literalText).join(),
    StringInterpolation() =>
      node.elements.whereType<InterpolationString>().map((e) => e.value).join(),
  };

  static bool _isShownToUser(AstNode node) {
    var child = node;
    var parent = node.parent;
    while (parent is ConditionalExpression ||
        parent is ParenthesizedExpression ||
        (parent is BinaryExpression && parent.operator.lexeme == '+')) {
      child = parent!;
      parent = parent.parent;
    }
    if (parent is NamedExpression) {
      return textArguments.contains(parent.name.label.name) &&
          !_isDeveloperMessage(_calleeName(parent.parent?.parent));
    }
    if (parent is ArgumentList) {
      return textWidgets.contains(_calleeName(parent.parent)) &&
          parent.arguments.first == child;
    }
    return false;
  }

  static String? _calleeName(AstNode? call) => switch (call) {
    MethodInvocation() => call.methodName.name,
    InstanceCreationExpression() => call.constructorName.type.name.lexeme,
    _ => null,
  };

  /// Exception messages are meant for developers and logs, not for users.
  static bool _isDeveloperMessage(String? callee) =>
      callee != null &&
      (callee.endsWith('Exception') ||
          callee.endsWith('Error') ||
          callee.endsWith('Failure'));
}

void main() {
  test('user facing texts are localized', () {
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .map((f) => f.path)
        .where((path) => path.endsWith('.dart'))
        .where((path) => !path.endsWith('.g.dart'))
        .where((path) => !ignoredFolders.any(path.startsWith));

    final problems = <String>[];
    for (final path in files) {
      final unit = parseFile(
        path: File(path).absolute.path,
        featureSet: FeatureSet.latestLanguageVersion(),
      ).unit;
      final finder = _HardcodedStringFinder(unit);
      unit.accept(finder);
      for (final (line, text) in finder.found) {
        if (allowed[path]?.contains(text) ?? false) continue;
        problems.add('$path:$line: ${text.replaceAll('\n', r'\n')}');
      }
    }

    expect(
      problems,
      isEmpty,
      reason:
          'Add these texts to lib/l10n/app_en.arb and use AppLocalizations '
          '(see docs/contributing/translations.md)',
    );
  });
}
