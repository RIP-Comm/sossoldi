// dart format width=400

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/services/banking/banking_exception.dart';
import 'package:sossoldi/services/banking/lifecycle/pending_bank_authorization.dart';
import 'package:sossoldi/services/banking/lifecycle/pending_bank_authorization_store.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('legacy staged authorization keeps its storage keys and phase through a round trip', () async {
    final legacy = <String, Object?>{
      'version': 1,
      'state': 'legacy-state',
      'authorization_id': 'legacy-auth',
      'authorization_url': 'https://bank.example/authorize',
      'application_id': 'legacy-app',
      'aspsp_name': 'Legacy Bank',
      'aspsp_country': 'IT',
      'redirect_uri': 'sossoldi://eb-callback',
      'expires_at': '2026-09-12T10:15:00.000Z',
      'consent_valid_until': '2026-12-01T00:00:00.000Z',
      'reconnect_connection_id': 7,
      'staged_connection_id': 9,
      'phase': 'sessionStaged',
    };
    FlutterSecureStorage.setMockInitialValues({'eb_pending_authorization_v1': jsonEncode(legacy)});
    const store = SecurePendingBankAuthorizationStore();
    final restored = (await store.read())!;
    expect(restored.providerId, 'enable_banking');
    expect(restored.institutionName, 'Legacy Bank');
    expect(restored.institutionCountry, 'IT');
    expect(restored.phase, PendingAuthorizationPhase.connectionStaged);
    expect(restored.stagedConnectionId, 9);
    await store.save(restored);
    final encoded = jsonDecode((await const FlutterSecureStorage().read(key: 'eb_pending_authorization_v1'))!) as Map<String, dynamic>;
    expect(encoded, {...legacy, 'provider_id': 'enable_banking'});
    expect((await store.read())!.phase, PendingAuthorizationPhase.connectionStaged);
  });

  test('persists every cold-start callback field in encrypted storage', () async {
    const store = SecurePendingBankAuthorizationStore();
    final pending = PendingBankAuthorization(
      providerId: 'alternative',
      state: 'csrf-state',
      authorizationId: 'authorization-id',
      authorizationUrl: 'https://bank.example/authorize',
      applicationId: 'app-id',
      institutionName: 'Test Bank',
      institutionCountry: 'IT',
      redirectUri: 'sossoldi://eb-callback',
      expiresAt: DateTime.utc(2026, 9, 1, 12, 15),
      consentValidUntil: DateTime.utc(2026, 12, 1),
      reconnectConnectionId: 7,
    );

    await store.save(pending);
    final restored = await const SecurePendingBankAuthorizationStore().read();

    expect(restored?.providerId, 'alternative');
    expect(PendingBankAuthorization.fromJson(pending.toJson()..remove('provider_id')).providerId, 'enable_banking');
    expect(restored?.state, 'csrf-state');
    expect(restored?.authorizationId, 'authorization-id');
    expect(restored?.institutionName, 'Test Bank');
    expect(restored?.reconnectConnectionId, 7);
    expect(restored?.expiresAt, DateTime.utc(2026, 9, 1, 12, 15));
  });

  test('corrupted pending state is rejected instead of partially read', () async {
    FlutterSecureStorage.setMockInitialValues({'eb_pending_authorization_v1': '{bad json'});

    await expectLater(() => const SecurePendingBankAuthorizationStore().read(), throwsA(isA<BankingException>().having((error) => error.failure, 'kind', BankingFailure.invalidResponse)));
  });
}
