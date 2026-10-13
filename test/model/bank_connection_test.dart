// dart format width=400

import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/model/bank_connection.dart';

void main() {
  test('legacy connection columns survive model naming changes and nullable copies', () {
    final legacy = <String, Object?>{
      'id': 7,
      'aspspName': 'Legacy Bank',
      'aspspCountry': 'IT',
      'applicationId': 'app',
      'sessionId': 'active-remote',
      'pendingSessionId': 'pending-remote',
      'pendingAuthorizationId': 'authorization',
      'validUntil': '2026-11-01T00:00:00.000Z',
      'pendingValidUntil': '2026-12-01T00:00:00.000Z',
      'status': 'ACTIVE',
      'psuType': 'personal',
      'createdAt': '2026-09-01T00:00:00.000Z',
      'updatedAt': '2026-09-12T00:00:00.000Z',
    };
    final restored = BankConnection.fromJson(legacy);
    expect(restored.providerId, 'enable_banking');
    expect(restored.institutionName, 'Legacy Bank');
    expect(restored.institutionCountry, 'IT');
    expect(restored.remoteConnectionId, 'active-remote');
    expect(restored.pendingRemoteConnectionId, 'pending-remote');
    expect(restored.toJson(update: true, clock: DateTime.utc(2026, 9, 12)), {...legacy, 'providerId': 'enable_banking'});
    final cleared = restored.copy(providerId: 'alternative', pendingRemoteConnectionId: null);
    expect(cleared.providerId, 'alternative');
    expect(cleared.remoteConnectionId, 'active-remote');
    expect(cleared.pendingRemoteConnectionId, isNull);
    expect(cleared.toJson()['pendingSessionId'], isNull);
  });
}
