import 'dart:async';
import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/bank_account.dart';
import '../model/bank_connection.dart';
import '../services/banking/bank_institution.dart';
import '../services/banking/banking_account.dart';
import '../services/banking/banking_balance.dart';
import '../services/banking/banking_exception.dart';
import '../services/banking/banking_reference.dart';
import '../services/banking/lifecycle/bank_authorization_result.dart';
import '../services/banking/lifecycle/banking_platform_support.dart';
import '../services/banking/sync/bank_sync_lifecycle.dart';
import '../services/banking/sync/bank_sync_result.dart';
import '../services/banking/sync/bank_sync_request.dart';
import '../services/banking/sync/bank_sync_service.dart';
import '../services/database/repositories/bank_connection_repository.dart';
import '../services/database/repositories/bank_sync_repository.dart';
import '../services/database/sossoldi_database.dart';
import 'accounts_provider.dart';
import 'banking_provider.dart';
import 'dashboard_provider.dart';
import 'statistics_provider.dart';
import 'transactions_provider.dart';

export 'banking_provider.dart';

part 'banking_ui_provider.g.dart';

class ConnectBankFlowException implements Exception {
  final String message;
  const ConnectBankFlowException(this.message);
}

String bankingErrorMessage(Object error) {
  if (error is ConnectBankFlowException) return error.message;
  if (error is SocketException || error is TimeoutException) {
    return 'The bank could not be reached. Check your connection and try again.';
  }
  if (error is EnableBankingAuthException) {
    return 'Check your Enable Banking application ID and private key in Bank sync settings.';
  }
  if (error is EnableBankingException) {
    return switch (error.kind) {
      EnableBankingFailureKind.applicationAuthentication =>
        'Check your Enable Banking credentials in Bank sync settings.',
      EnableBankingFailureKind.sessionExpired ||
      EnableBankingFailureKind.sessionRevoked ||
      EnableBankingFailureKind.sessionClosed ||
      EnableBankingFailureKind.notFound =>
        'The bank connection is no longer valid. Reconnect the bank.',
      EnableBankingFailureKind.rateLimited =>
        'The bank is receiving too many requests. Try again later.',
      EnableBankingFailureKind.network ||
      EnableBankingFailureKind.timeout ||
      EnableBankingFailureKind.server =>
        'The bank could not be reached. Check your connection and try again.',
      _ => 'The bank could not complete this request. Try again.',
    };
  }
  if (error is BankingException) {
    return switch (error.failure) {
      BankingFailure.authentication || BankingFailure.forbidden =>
        'Check your Enable Banking credentials and reconnect the bank.',
      BankingFailure.connectionExpired =>
        'The consent has expired. Reconnect the bank.',
      BankingFailure.connectionRevoked ||
      BankingFailure.connectionClosed ||
      BankingFailure.notFound => 'The bank connection is no longer available.',
      BankingFailure.rateLimited =>
        'The bank is receiving too many requests. Try again later.',
      BankingFailure.unavailable =>
        'The bank is temporarily unavailable. Try again.',
      _ =>
        'The bank could not complete this request. Try again or restart the connection.',
    };
  }
  return 'Could not complete the bank request. Please try again.';
}

String bankAccountCount(int count) =>
    '$count ${count == 1 ? 'account' : 'accounts'}';

String bankSyncMessage(BankSyncSummary result) {
  final warnings = result.accounts
      .expand((account) => account.warnings)
      .toSet();
  if (warnings.contains('server_clock_regressed')) {
    return 'The bank returned an older sync time. Previous data was kept. Try syncing again later.';
  }
  if (warnings.contains('balance_mismatch')) {
    return 'The bank balance does not match the available transactions. Previous data was kept. Try syncing again or check the missing history with your bank.';
  }
  if (warnings.any(
    {
      'api_connectionRevoked',
      'api_connectionClosed',
      'api_notFound',
      'api_connectionExpired',
      'consent_expired',
      'consent_or_credentials_unavailable',
    }.contains,
  )) {
    return 'The bank connection needs your attention. Reconnect the bank or check your credentials.';
  }
  if (warnings.contains('account_not_found')) {
    return 'The bank could not provide an account. Check its status with your bank, and reconnect any connection marked as requiring reconnection.';
  }
  if (warnings.any(
    {'api_authentication', 'api_forbidden', 'credentials_changed'}.contains,
  )) {
    return 'Check your Enable Banking credentials in Bank sync settings before retrying.';
  }
  if (warnings.contains('history_overlap_missing')) {
    return 'The returned history does not reach the previous sync. Some transactions may be missing. Check the history with your bank.';
  }
  if (warnings.contains('initial_balance_unverified')) {
    return 'The bank did not provide a verifiable booked balance. The first sync is incomplete. Try again later.';
  }
  if (warnings.contains('manual_context_required')) {
    return 'This bank requires additional details for an interactive refresh. Complete the request to continue.';
  }
  if ((result.status == BankSyncStatus.success ||
          result.status == BankSyncStatus.noChange) &&
      warnings.contains('no_comparable_booked_balance')) {
    return 'Transactions checked. The bank balance could not be verified. Try syncing again later.';
  }
  if ((result.status == BankSyncStatus.success ||
          result.status == BankSyncStatus.noChange) &&
      warnings.contains('empty_account_history_unverified')) {
    return 'The zero booked balance was verified. The bank returned no booked transactions; earlier history could not be verified.';
  }
  if ((result.status == BankSyncStatus.success ||
          result.status == BankSyncStatus.noChange) &&
      warnings.contains('bank_default_history_fallback')) {
    return 'Sync completed using the history available from your bank. Earlier transactions may not be available.';
  }
  final count = result.accounts.fold<int>(
    0,
    (total, account) => total + account.inserted,
  );
  return switch (result.status) {
    BankSyncStatus.success =>
      'Synced $count new ${count == 1 ? 'transaction' : 'transactions'}',
    BankSyncStatus.noChange => 'Bank accounts are up to date',
    BankSyncStatus.partial =>
      'Some accounts could not be synced. Retry from Linked banks.',
    BankSyncStatus.retryableFailure =>
      'Sync could not finish. Please retry later.',
    BankSyncStatus.terminalFailure =>
      'Sync could not finish. Check the consent and account currency.',
    BankSyncStatus.skipped =>
      'No accounts were due for sync. Please wait before retrying.',
  };
}

bool bankSyncNeedsAttention(BankSyncSummary result) => result.accounts.any(
  (account) =>
      (!account.completed && account.status != BankSyncStatus.skipped) ||
      account.warnings.any(
        {
          'no_comparable_booked_balance',
          'empty_account_history_unverified',
          'bank_default_history_fallback',
          'balance_mismatch',
          'history_overlap_missing',
        }.contains,
      ),
);

@riverpod
Future<BankSyncSummary> bankConnectionSyncStatus(Ref ref, int connectionId) =>
    ref.watch(bankSyncRepositoryProvider).latestResults(connectionId);

@Riverpod(keepAlive: true)
class BankRecoveryIssue extends _$BankRecoveryIssue {
  @override
  String? build() => null;
  void report(Object error) => state = bankingErrorMessage(error);
  void reportMessage(String message) => state = message;
  void clear() => state = null;
}

class BankAccountImportSelection {
  final BankingAccount account;
  final String name;
  final String symbol;
  final int color;

  const BankAccountImportSelection({
    required this.account,
    required this.name,
    required this.symbol,
    required this.color,
  });
}

class ConnectBankFlowState {
  final List<BankInstitution> aspsps;
  final List<BankingAccount> importable;
  final BankConnection? connection;
  final bool authorizing;

  const ConnectBankFlowState({
    this.aspsps = const [],
    this.importable = const [],
    this.connection,
    this.authorizing = false,
  });

  int? get connectionId => connection?.id;
}

@Riverpod(keepAlive: true)
BankSyncRepository bankSyncRepository(Ref ref) =>
    BankSyncRepository(database: ref.watch(databaseProvider));

@Riverpod(keepAlive: true)
BankSyncService bankSyncService(Ref ref) => BankSyncService(
  accountData: ref.watch(bankAccountDataSourceProvider),
  consent: ref.watch(bankConsentServiceProvider),
  institutions: ref.watch(bankInstitutionDirectoryProvider),
  providerId: ref.watch(bankingServiceProvider).id,
  repository: ref.watch(bankSyncRepositoryProvider),
  readContext: ref.watch(bankAuthorizationContextReaderProvider),
);

void _refreshBankData(Ref ref) {
  ref.invalidate(bankConnectionsProvider);
  ref.invalidate(bankConnectionSyncStatusProvider);
  ref.invalidate(accountsProvider);
  ref.invalidate(transactionsProvider);
  ref.invalidate(dashboardProvider);
  ref.invalidate(statisticsProvider);
}

@Riverpod(keepAlive: true)
class BankConnections extends _$BankConnections {
  @override
  Future<List<BankConnection>> build() async {
    final items = await ref.watch(bankConnectionRepositoryProvider).selectAll();
    return items
        .where(
          (item) =>
              item.status != BankConnectionStatus.revoked &&
              item.status != BankConnectionStatus.disconnected,
        )
        .toList();
  }
}

@riverpod
Future<num?> ebAccountBalance(Ref ref, String accountUid) async {
  final balances = await ref
      .watch(bankAccountDataSourceProvider)
      .getBalances(
        BankingAccountReference(
          providerId: ref.watch(bankingServiceProvider).id,
          remoteId: accountUid,
        ),
      );
  final booked = balances.where(
    (balance) =>
        balance.kind == BankingBalanceKind.closingBooked ||
        balance.kind == BankingBalanceKind.interimBooked,
  );
  if (booked.isEmpty) return null;
  return num.parse(booked.first.amount.decimalAmount);
}

@Riverpod(keepAlive: true)
class ConnectBankFlow extends _$ConnectBankFlow {
  @override
  ConnectBankFlowState build() => const ConnectBankFlowState();

  Future<void> loadAspsps(String country) async {
    final config = await ref.read(enableBankingSettingsProvider.future);
    if (config == null || !config.supportedCountries.contains(country)) {
      throw const ConnectBankFlowException(
        'This country is not enabled for your application.',
      );
    }
    final institutions = await ref
        .read(bankInstitutionDirectoryProvider)
        .getInstitutions(
          country: country,
          customerType: BankingCustomerType.personal,
        );
    final sorted =
        institutions
            .where(
              (item) =>
                  item.customerTypes.contains(BankingCustomerType.personal),
            )
            .toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
    state = ConnectBankFlowState(aspsps: sorted);
  }

  Future<AuthorizationLaunchResult> startConnection(
    BankInstitution institution, {
    BankConnection? reconnecting,
  }) async {
    state = ConnectBankFlowState(aspsps: state.aspsps, authorizing: true);
    try {
      final lifecycle = ref.read(bankConsentLifecycleServiceProvider);
      final attempt = await lifecycle.startAuthorization(
        institution,
        reconnectConnectionId: reconnecting?.id,
      );
      return await lifecycle.launchAuthorization(attempt.url);
    } finally {
      state = ConnectBankFlowState(aspsps: state.aspsps);
    }
  }

  Future<void> reconnect(BankConnection connection) async {
    final institutions = await ref
        .read(bankInstitutionDirectoryProvider)
        .getInstitutions(
          country: connection.institutionCountry,
          customerType: BankingCustomerType.personal,
        );
    final matches = institutions.where(
      (item) =>
          item.providerId == connection.providerId &&
          item.name == connection.institutionName &&
          item.country == connection.institutionCountry,
    );
    if (matches.length != 1) {
      throw const ConnectBankFlowException(
        'This bank is currently unavailable.',
      );
    }
    final result = await startConnection(
      matches.single,
      reconnecting: connection,
    );
    if (!result.opened) {
      throw const ConnectBankFlowException(
        'Could not open the browser. Retry to resume the same authorization.',
      );
    }
  }

  Future<void> resumeImport({int? connectionId}) async {
    final resumable = await ref
        .read(bankConsentLifecycleServiceProvider)
        .resumeAwaitingImports();
    final matches = resumable.where(
      (item) => connectionId == null || item.connection.id == connectionId,
    );
    if (matches.isEmpty) return;
    final item = matches.first;
    final accounts = <BankingAccount>[];
    for (final reference in item.details.accounts) {
      accounts.add(
        await ref.read(bankAccountDataSourceProvider).getAccount(reference),
      );
    }
    if (!ref.mounted) return;
    state = ConnectBankFlowState(
      connection: item.connection,
      importable: accounts,
    );
    ref.invalidate(bankConnectionsProvider);
  }

  Future<BankSyncSummary> importAccounts(
    List<BankAccountImportSelection> selections,
  ) async {
    final connectionId = state.connectionId;
    if (connectionId == null || selections.isEmpty) {
      throw const ConnectBankFlowException(
        'Select accounts from an active connection.',
      );
    }
    if (selections.any(
      (selection) => !state.importable.any(
        (account) => account.reference == selection.account.reference,
      ),
    )) {
      throw const ConnectBankFlowException(
        'The selected account is not part of this connection.',
      );
    }
    final previous = await ref.read(accountsProvider.future);
    await ref
        .read(bankConsentLifecycleServiceProvider)
        .activateConnection(connectionId, [
          for (var index = 0; index < selections.length; index++)
            (
              remote: selections[index].account,
              newAccount: BankAccount(
                name: selections[index].name,
                symbol: selections[index].symbol,
                color: selections[index].color,
                startingValue: 0,
                active: true,
                countNetWorth: true,
                mainAccount: previous.isEmpty && index == 0,
                order: previous.length + index,
              ),
            ),
        ]);
    state = const ConnectBankFlowState();
    _refreshBankData(ref);
    return syncConnectionId(connectionId, initial: true);
  }

  Future<BankSyncSummary> syncConnectionId(
    int id, {
    bool initial = false,
    Map<String, String> psuHeaders = const {},
  }) async {
    try {
      return await ref
          .read(bankSyncServiceProvider)
          .syncConnection(
            id,
            request: BankSyncRequest(
              psuHeaders: psuHeaders,
              trigger: initial
                  ? BankSyncTrigger.background
                  : BankSyncTrigger.manual,
            ),
          );
    } finally {
      _refreshBankData(ref);
    }
  }

  Future<List<String>> requiredSyncHeaders(BankConnection connection) async {
    final banks = await ref
        .read(bankInstitutionDirectoryProvider)
        .getInstitutions(
          country: connection.institutionCountry,
          customerType: connection.psuType == 'business'
              ? BankingCustomerType.business
              : BankingCustomerType.personal,
        );
    final bank = banks.singleWhere(
      (item) =>
          item.providerId == connection.providerId &&
          item.name == connection.institutionName &&
          item.country == connection.institutionCountry,
    );
    return bank.requiredPsuHeaders;
  }

  Future<BankSyncSummary> syncConnection(
    BankConnection connection, {
    Map<String, String> psuHeaders = const {},
  }) => syncConnectionId(connection.id!, psuHeaders: psuHeaders);

  Future<void> disconnect(BankConnection connection) async {
    try {
      await ref.read(bankConsentLifecycleServiceProvider).revoke(connection);
      if (state.connectionId == connection.id) {
        state = const ConnectBankFlowState();
      }
    } finally {
      _refreshBankData(ref);
    }
  }

  Future<void> disconnectLocally(BankConnection connection) async {
    await ref
        .read(bankConsentLifecycleServiceProvider)
        .disconnectLocally(connection);
    _refreshBankData(ref);
  }

  Future<void> cancelAuthorization() =>
      ref.read(bankConsentLifecycleServiceProvider).cancelAuthorization();
}

@Riverpod(keepAlive: true)
Future<void> bankingUiBootstrap(Ref ref) async {
  if (!BankingPlatformSupport.supportsCallback()) return;
  ref.watch(enableBankingSettingsProvider);
  final lifecycle = BankSyncLifecycle(
    service: ref.read(bankSyncServiceProvider),
    prepare: () async {
      ref.invalidate(bankingCallbackBootstrapProvider);
      await ref.read(bankingCallbackBootstrapProvider.future);
      if (!ref.mounted) return false;
      final credentials = await ref.read(enableBankingSettingsProvider.future);
      if (credentials == null || !ref.mounted) return false;
      await ref.read(connectBankFlowProvider.notifier).resumeImport();
      return ref.mounted;
    },
    onResult: (result) {
      if (!ref.mounted) return;
      final issue = ref.read(bankRecoveryIssueProvider.notifier);
      if (bankSyncNeedsAttention(result)) {
        issue.reportMessage(bankSyncMessage(result));
      } else {
        issue.clear();
      }
      _refreshBankData(ref);
    },
    onError: (error) {
      if (ref.mounted) {
        ref.read(bankRecoveryIssueProvider.notifier).report(error);
      }
    },
  );
  ref.onDispose(lifecycle.dispose);
  lifecycle.start();
}
