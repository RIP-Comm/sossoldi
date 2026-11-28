import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/services/banking/bank_account_data_source.dart';
import 'package:sossoldi/services/banking/bank_authorization_context.dart';
import 'package:sossoldi/services/banking/bank_institution.dart';
import 'package:sossoldi/services/banking/bank_institution_directory.dart';
import 'package:sossoldi/services/banking/banking_account.dart';
import 'package:sossoldi/services/banking/banking_balance.dart';
import 'package:sossoldi/services/banking/banking_money.dart';
import 'package:sossoldi/services/banking/banking_reference.dart';
import 'package:sossoldi/services/banking/banking_request_context.dart';
import 'package:sossoldi/services/banking/banking_transaction.dart';
import 'package:sossoldi/services/banking/sync/bank_sync_service.dart';
import 'package:sossoldi/services/banking/sync/bank_sync_result.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../support/bank_sync_harness.dart';

class _Alternative implements BankInstitutionDirectory, BankAccountDataSource {
  Future<void> Function()? beforeBalance;
  bool wrongAccount = false;
  int calls = 0;

  @override
  Future<List<BankInstitution>> getInstitutions({
    String? country,
    BankingCustomerType customerType = BankingCustomerType.personal,
  }) async {
    calls++;
    return [
      BankInstitution(
        providerId: 'alternative',
        id: 'bank',
        name: 'Synthetic Bank',
        country: 'IT',
      ),
    ];
  }

  @override
  Future<BankingAccount> getAccount(
    BankingAccountReference reference, {
    BankingRequestContext context = const BankingRequestContext(),
  }) async {
    expect(reference.providerId, 'alternative');
    return BankingAccount(
      reference: wrongAccount
          ? BankingAccountReference(
              providerId: 'other',
              remoteId: reference.remoteId,
            )
          : reference,
      currency: 'EUR',
    );
  }

  @override
  Future<List<BankingBalance>> getBalances(
    BankingAccountReference reference, {
    BankingRequestContext context = const BankingRequestContext(),
  }) async {
    await beforeBalance?.call();
    return [
      BankingBalance(
        name: 'Booked',
        amount: BankingMoney(decimalAmount: '232.75', currency: 'EUR'),
        kind: BankingBalanceKind.interimBooked,
        observedAt: DateTime.utc(2026, 9, 7, 11),
        lastCommittedEntryId: 'ref-1',
      ),
    ];
  }

  @override
  Future<BankingTransactionsPage> getTransactions(
    BankingAccountReference reference, {
    BankingTransactionQuery query = const BankingTransactionQuery(),
  }) async {
    expect(query.collectRejectedRecords, isTrue);
    return BankingTransactionsPage(
      serverTime: DateTime.utc(2026, 9, 7, 12),
      transactions: [
        BankingTransaction(
          entryId: 'ref-1',
          status: BankingTransactionStatus.booked,
          direction: BankingDirection.debit,
          amount: BankingMoney(decimalAmount: '73.14', currency: 'EUR'),
          bookingDate: DateTime.utc(2026, 9, 6),
        ),
      ],
    );
  }
}

void main() {
  late BankSyncHarness h;
  late _Alternative provider;
  late BankSyncService service;
  late BankAuthorizationContext authorization;
  setUpAll(sqfliteFfiInit);
  setUp(() async {
    h = BankSyncHarness(databaseFactoryFfi);
    await h.open();
    await h.db.update('bankConnection', {
      'providerId': 'alternative',
    }, where: 'id = 1');
    provider = _Alternative();
    authorization = const BankAuthorizationContext(
      providerId: 'alternative',
      applicationId: 'synthetic-app',
      redirectUri: 'app://callback',
    );
    service = BankSyncService(
      accountData: provider,
      institutions: provider,
      providerId: 'alternative',
      repository: h.repository,
      readContext: () async => authorization,
      clock: () => h.localTime,
      limits: const BankSyncLimits(backgroundInterval: Duration.zero),
    );
  });
  tearDown(() => h.close());

  test(
    'another provider reconciles through the same core without Enable Banking HTTP calls',
    () async {
      expect((await service.syncAccount(1)).status, BankSyncStatus.success);
      expect((await h.state())['openingMinor'], '30589');
      expect(await h.total(), closeTo(232.75, 0.000001));
      expect((await service.syncAccount(1)).status, BankSyncStatus.noChange);
      expect(await h.transactions(), hasLength(1));
      expect(h.requests, isEmpty);
    },
  );

  test(
    'account enumeration and direct calls cannot cross providers sharing an application ID',
    () async {
      expect((await h.service.syncAll()).accounts, isEmpty);
      expect(
        (await h.service.syncAccount(1)).status,
        BankSyncStatus.terminalFailure,
      );
      expect(h.requests, isEmpty);
      expect(await h.transactions(), isEmpty);
      expect((await service.syncAll()).accounts, hasLength(1));
    },
  );

  test(
    'credentials for another provider are rejected before any remote request',
    () async {
      authorization = const BankAuthorizationContext(
        providerId: 'other',
        applicationId: 'synthetic-app',
        redirectUri: 'app://callback',
      );
      expect(
        (await service.syncAccount(1)).status,
        BankSyncStatus.terminalFailure,
      );
      expect(provider.calls, 0);
      expect(await h.transactions(), isEmpty);
    },
  );

  test(
    'provider change in the database during fetch invalidates the atomic commit',
    () async {
      provider.beforeBalance = () async {
        await h.db.update('bankConnection', {
          'providerId': 'other',
        }, where: 'id = 1');
      };
      expect((await service.syncAccount(1)).status, BankSyncStatus.partial);
      expect(await h.transactions(), isEmpty);
      expect(await h.db.query('bankSyncState'), isEmpty);
    },
  );

  test(
    'provider change in the credential context during fetch rejects the batch',
    () async {
      provider.beforeBalance = () async {
        authorization = const BankAuthorizationContext(
          providerId: 'other',
          applicationId: 'synthetic-app',
          redirectUri: 'app://callback',
        );
      };
      expect(
        (await service.syncAccount(1)).warnings,
        contains('credentials_changed'),
      );
      expect(await h.transactions(), isEmpty);
    },
  );

  test(
    'an account response from another provider cannot be persisted',
    () async {
      provider.wrongAccount = true;
      expect(
        (await service.syncAccount(1)).warnings,
        contains('account_identity_mismatch'),
      );
      expect(await h.transactions(), isEmpty);
    },
  );
}
