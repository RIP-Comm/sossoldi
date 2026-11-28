import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/providers/banking_ui_provider.dart';
import 'package:sossoldi/services/banking/sync/bank_sync_result.dart';

void main() {
  test(
    'missing account does not promise that a confirmed missing consent can sync',
    () {
      final message = bankSyncMessage(
        BankSyncSummary([
          const BankSyncResult(
            accountId: 1,
            status: BankSyncStatus.terminalFailure,
            warnings: ['account_not_found'],
          ),
        ]),
      );
      expect(message, contains('Check its status'));
      expect(message, isNot(contains('Other accounts can still sync')));
    },
  );
  test(
    'confirmed consent failure has priority over an isolated missing account',
    () {
      final message = bankSyncMessage(
        BankSyncSummary([
          const BankSyncResult(
            accountId: 1,
            status: BankSyncStatus.terminalFailure,
            warnings: ['account_not_found'],
          ),
          const BankSyncResult(
            accountId: 2,
            status: BankSyncStatus.terminalFailure,
            warnings: ['consent_or_credentials_unavailable'],
          ),
        ]),
      );
      expect(message, contains('Reconnect the bank'));
    },
  );
  test('remote error messages never disclose provider response content', () {
    for (final kind in EnableBankingFailureKind.values) {
      final message = bankingErrorMessage(
        EnableBankingException(
          kind: kind,
          message: 'sensitive-provider-detail',
          error: 'sensitive-provider-code',
        ),
      );
      expect(message, isNot(contains('sensitive-provider')));
      expect(message, isNot(contains('Exception')));
    }
  });
  test('network errors explain the recovery action', () {
    expect(
      bankingErrorMessage(const SocketException('private host')),
      contains('Check your connection'),
    );
    expect(
      bankingErrorMessage(const SocketException('private host')),
      isNot(contains('private host')),
    );
  });
}
