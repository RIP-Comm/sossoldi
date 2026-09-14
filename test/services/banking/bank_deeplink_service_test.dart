import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/services/banking/lifecycle/bank_authorization_callback.dart';
import 'package:sossoldi/services/banking/lifecycle/bank_deeplink_service.dart';

class _Source implements UriLinkSource {
  final controller = StreamController<Uri>.broadcast();
  Uri? initial;
  Object? initialError;

  @override
  Stream<Uri> get uriStream => controller.stream;

  @override
  Future<Uri?> getInitialUri() async {
    if (initialError case final error?) throw error;
    return initial;
  }
}

void main() {
  test(
    'strictly accepts only the configured callback scheme host and path',
    () {
      expect(
        BankDeeplinkService.parse(
          Uri.parse('sossoldi://eb-callback?code=a&state=b'),
        )?.code,
        'a',
      );
      expect(
        BankDeeplinkService.parse(
          Uri.parse('https://eb-callback?code=a&state=b'),
        ),
        isNull,
      );
      expect(
        BankDeeplinkService.parse(
          Uri.parse('sossoldi://eb-callback/other?code=a&state=b'),
        ),
        isNull,
      );
    },
  );

  test(
    'cold-start link is retried after retryable result then consumed',
    () async {
      final source = _Source()
        ..initial = Uri.parse('sossoldi://eb-callback?code=a&state=b');
      final service = BankDeeplinkService(source: source);
      var calls = 0;

      await service.start((callback) async {
        calls++;
        return calls == 1
            ? BankCallbackDisposition.retryable
            : BankCallbackDisposition.terminal;
      });
      source.controller.add(source.initial!);
      await Future<void>.delayed(Duration.zero);
      source.controller.add(source.initial!);
      await Future<void>.delayed(Duration.zero);

      expect(calls, 2);
      await service.dispose();
      await source.controller.close();
    },
  );

  test('plugin and callback failures are observable and retryable', () async {
    final source = _Source()..initialError = StateError('plugin failed');
    final service = BankDeeplinkService(source: source);
    final errors = <Object>[];

    await service.start(
      (callback) async => throw TypeError(),
      onError: (error) async => errors.add(error),
    );
    source.controller.add(Uri.parse('sossoldi://eb-callback?code=a&state=b'));
    await Future<void>.delayed(Duration.zero);

    expect(errors, hasLength(2));
    await service.dispose();
    await source.controller.close();
  });
}
