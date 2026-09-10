// dart format width=400

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sossoldi/providers/banking_provider.dart';
import 'package:sossoldi/services/banking/bank_institution.dart';
import 'package:sossoldi/services/banking/banking_exception.dart';
import 'package:sossoldi/services/banking/bank_institution_directory.dart' as domain;
import 'package:sossoldi/services/banking/banking_provider.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_api.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_auth.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_credentials_store.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_provider.dart';

class _Auth extends EnableBankingAuth {
  @override
  Future<String> getValidToken(EnableBankingCredentialsStore store) async => 'test';
}

class _AlternativeBanking implements domain.BankInstitutionDirectory {
  final id = 'alternative';

  @override
  Future<List<BankInstitution>> getInstitutions({String? country, BankingCustomerType customerType = BankingCustomerType.personal}) async => [BankInstitution(providerId: id, id: 'bank', name: 'Alternative', country: country ?? 'IT')];
}

BankingProvider _provider(MockClientHandler handler) => EnableBankingProvider(EnableBankingApi(auth: _Auth(), store: const EnableBankingCredentialsStore(), client: MockClient(handler)));

void main() {
  test('app provider can be replaced without Enable Banking credentials', () async {
    final container = ProviderContainer(overrides: [bankInstitutionDirectoryProvider.overrideWithValue(_AlternativeBanking())]);
    addTearDown(container.dispose);
    final service = container.read(bankInstitutionDirectoryProvider);
    expect((await service.getInstitutions()).single.providerId, 'alternative');
    expect((await service.getInstitutions(country: 'GB')).single.country, 'GB');
  });

  test('real client maps institution metadata and forwards generic filters', () async {
    final service = _provider((request) async {
      expect(request.url.path, '/aspsps');
      expect(request.url.queryParameters, {'country': 'IT', 'psu_type': 'business'});
      return http.Response(
        jsonEncode({
          'aspsps': [
            {
              'name': 'Bank',
              'country': 'IT',
              'logo': 'https://example.com/logo.png',
              'psu_types': ['personal', 'business', 'future'],
              'maximum_consent_validity': 3600,
              'beta': true,
              'sandbox': {'users': []},
            },
            {'name': 'Bank', 'country': 'GB'},
          ],
        }),
        200,
      );
    });
    final banks = await service.institutions.getInstitutions(country: 'IT', customerType: BankingCustomerType.business);
    expect(banks.first.providerId, service.id);
    expect(banks.first.id, isNot(banks.last.id));
    expect(banks.first.name, 'Bank');
    expect(banks.first.logoUri, Uri.parse('https://example.com/logo.png'));
    expect(banks.first.maximumConsentDuration, const Duration(hours: 1));
    expect(banks.first.customerTypes, {BankingCustomerType.personal, BankingCustomerType.business});
    expect(banks.first.isSandbox, isTrue);
    expect(banks.first.isBeta, isTrue);
    expect(banks.last.maximumConsentDuration, isNull);
    expect(banks.last.customerTypes, isEmpty);
    expect(() => banks.clear(), throwsUnsupportedError);
    expect(() => banks.first.customerTypes.clear(), throwsUnsupportedError);
  });

  for (final entry in {401: BankingFailure.authentication, 403: BankingFailure.forbidden, 429: BankingFailure.rateLimited, 503: BankingFailure.unavailable, 400: BankingFailure.rejected}.entries) {
    test('HTTP ${entry.key} produces a generic error without response data', () async {
      final service = _provider((_) async => http.Response('{"message":"sensitive-response"}', entry.key));
      await expectLater(service.institutions.getInstitutions(), throwsA(isA<BankingException>().having((e) => e.failure, 'failure', entry.value).having((e) => e.toString(), 'diagnostic', isNot(contains('sensitive-response')))));
    });
  }

  for (final body in ['invalid json', '{"aspsps":[{"name":42}]}']) {
    test('malformed payload becomes invalidResponse: $body', () async {
      final service = _provider((_) async => http.Response(body, 200));
      await expectLater(service.institutions.getInstitutions(), throwsA(isA<BankingException>().having((e) => e.failure, 'failure', BankingFailure.invalidResponse)));
    });
  }

  test('transport errors are provider independent', () async {
    final service = _provider((_) async => throw http.ClientException('network'));
    await expectLater(service.institutions.getInstitutions(), throwsA(isA<BankingException>().having((e) => e.failure, 'failure', BankingFailure.unavailable)));
  });

  for (final error in [const EnableBankingAuthException('missing credentials'), const SocketException('network'), TimeoutException('timeout')]) {
    test('maps ${error.runtimeType} without leaking implementation types', () async {
      final service = _provider((_) async => throw error);
      final failure = error is EnableBankingAuthException ? BankingFailure.authentication : BankingFailure.unavailable;
      await expectLater(service.institutions.getInstitutions(), throwsA(isA<BankingException>().having((e) => e.failure, 'failure', failure)));
    });
  }

  test('only the composition root can import the Enable Banking module', () {
    for (final entity in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!entity.path.endsWith('.dart') || entity.path.endsWith('.g.dart') || entity.path.contains('/banking/enable_banking/') || entity.path == 'lib/providers/banking_provider.dart') continue;
      expect(RegExp(r'''(?:import|export)\s+['"][^'"]*enable_banking/''').hasMatch(entity.readAsStringSync()), isFalse, reason: entity.path);
    }
  });
}
