import 'dart:async';
import 'dart:math';

import 'package:sqflite/sqflite.dart';

import '../../../model/bank_connection.dart';
import '../../database/repositories/bank_sync_repository.dart';
import 'bank_balance_selector.dart';
import '../bank_account_data_source.dart';
import '../bank_consent_service.dart';
import '../banking_connection.dart';
import '../bank_institution_directory.dart';
import '../bank_institution.dart';
import '../bank_authorization_context.dart';
import '../banking_reference.dart';
import '../banking_request_context.dart';
import '../banking_exception.dart';
import 'bank_money.dart';
import 'bank_remote_transaction.dart';
import 'bank_sync_request.dart';
import 'bank_sync_result.dart';
import '../banking_transaction.dart';

class BankSyncLimits {
  final int pages;
  final int records;
  final int retries;
  final Duration timeout;
  final Duration manualInterval;
  final Duration backgroundInterval;

  const BankSyncLimits({
    this.pages = 100,
    this.records = 50000,
    this.retries = 3,
    this.timeout = const Duration(minutes: 3),
    this.manualInterval = const Duration(seconds: 15),
    this.backgroundInterval = const Duration(hours: 6),
  });
}

/// Fetches and validates a complete batch before a single local commit.
class BankSyncService {
  final BankAccountDataSource _accountData;
  final BankConsentService? _consent;
  final BankInstitutionDirectory _institutions;
  final String _providerId;
  final BankSyncRepository _repository;
  final BankAuthorizationContextReader _readContext;
  final BankSyncLimits limits;
  final Future<void> Function(Duration) _sleep;
  final double Function() _jitter;
  final DateTime Function() _clock;
  final Duration Function()? _elapsedOverride;
  final Stopwatch _monotonic = Stopwatch()..start();
  final Map<int, Future<BankSyncResult>> _running = {};
  final Map<(int, BankSyncTrigger), Duration> _lastAttempt = {};

  BankSyncService({
    required BankAccountDataSource accountData,
    BankConsentService? consent,
    required BankInstitutionDirectory institutions,
    required String providerId,
    required BankSyncRepository repository,
    required BankAuthorizationContextReader readContext,
    this.limits = const BankSyncLimits(),
    Future<void> Function(Duration)? sleep,
    double Function()? jitter,
    DateTime Function()? clock,
    Duration Function()? elapsed,
  }) : _accountData = accountData,
       _consent = consent,
       _institutions = institutions,
       _providerId = providerId,
       _repository = repository,
       _readContext = readContext,
       _sleep = sleep ?? Future<void>.delayed,
       _jitter = jitter ?? Random().nextDouble,
       _clock = clock ?? DateTime.now,
       _elapsedOverride = elapsed {
    if (limits.pages < 1 ||
        limits.records < 1 ||
        limits.retries < 0 ||
        limits.retries > 10 ||
        limits.timeout <= Duration.zero) {
      throw ArgumentError('Invalid bank sync limits');
    }
  }

  Future<BankSyncResult> syncAccount(
    int accountId, {
    BankSyncRequest request = const BankSyncRequest(),
  }) {
    final running = _running[accountId];
    if (running != null) return running;
    final future = _sync(accountId, request);
    _running[accountId] = future;
    unawaited(
      future.then<void>(
        (_) {
          _running.remove(accountId);
        },
        onError: (Object error, StackTrace stack) {
          _running.remove(accountId);
        },
      ),
    );
    return future;
  }

  Future<BankSyncSummary> syncConnection(
    int connectionId, {
    BankSyncRequest request = const BankSyncRequest(),
  }) async {
    final results = <BankSyncResult>[];
    for (final id in await _repository.accountIds(
      connectionId: connectionId,
      providerId: _providerId,
    )) {
      results.add(await syncAccount(id, request: request));
    }
    return BankSyncSummary(results);
  }

  Future<BankSyncSummary> syncAll({
    BankSyncRequest request = const BankSyncRequest(),
  }) async {
    final results = <BankSyncResult>[];
    for (final id in await _repository.accountIds(providerId: _providerId)) {
      results.add(await syncAccount(id, request: request));
    }
    return BankSyncSummary(results);
  }

  Future<T> _retry<T>(Future<T> Function() action, Stopwatch watch) async {
    for (var attempt = 0; ; attempt++) {
      final remaining = limits.timeout - watch.elapsed;
      if (remaining <= Duration.zero) throw TimeoutException('Sync deadline');
      try {
        return await action().timeout(remaining);
      } on BankingException catch (error) {
        if (!error.isRetryable || attempt >= limits.retries) rethrow;
        final backoff = Duration(
          milliseconds: (500 * (1 << attempt) * (1 + _jitter())).round(),
        );
        final delay = error.retryAfter != null && error.retryAfter! > backoff
            ? error.retryAfter!
            : backoff;
        if (delay >= limits.timeout - watch.elapsed) rethrow;
        await _sleep(delay);
      }
    }
  }

  Future<BankSyncResult> _failure(
    int id,
    BankSyncStatus status,
    String warning, {
    int rejected = 0,
  }) async {
    final result = BankSyncResult(
      accountId: id,
      status: status,
      rejected: rejected,
      warnings: [warning],
    );
    try {
      await _repository.recordFailure(result);
    } on DatabaseException {
      return BankSyncResult(
        accountId: id,
        status: BankSyncStatus.terminalFailure,
        rejected: rejected,
        warnings: [warning, 'audit_write_failed'],
      );
    }
    return result;
  }

  Future<BankSyncResult> _sync(int accountId, BankSyncRequest request) async {
    final watch = Stopwatch()..start();
    BankSyncContext? startedContext;
    try {
      final context = await _repository.readContext(accountId);
      startedContext = context;
      final authorization = await _readContext();
      if (context.connection.providerId != _providerId ||
          authorization.providerId != _providerId ||
          context.connection.status != BankConnectionStatus.active ||
          context.connection.remoteConnectionId == null ||
          context.account.ebAccountUid == null ||
          authorization.applicationId != context.connection.applicationId) {
        return _failure(
          accountId,
          BankSyncStatus.terminalFailure,
          'consent_or_credentials_unavailable',
        );
      }
      final scale = BankMoney.scales[context.currency];
      if (scale == null || scale > 2) {
        return _failure(
          accountId,
          BankSyncStatus.terminalFailure,
          'unsupported_global_currency_precision',
        );
      }
      final interval = request.trigger == BankSyncTrigger.manual
          ? limits.manualInterval
          : limits.backgroundInterval;
      final key = (accountId, request.trigger);
      final last = _lastAttempt[key];
      final elapsed = _elapsedOverride?.call() ?? _monotonic.elapsed;
      if (last != null && elapsed - last < interval) {
        return BankSyncResult(
          accountId: accountId,
          status: BankSyncStatus.skipped,
          warnings: const ['throttled'],
        );
      }
      final completedAt = context.completedAt;
      final now = _clock().toUtc();
      if (request.trigger == BankSyncTrigger.background &&
          completedAt != null &&
          !completedAt.isAfter(now) &&
          now.difference(completedAt) < interval) {
        return BankSyncResult(
          accountId: accountId,
          status: BankSyncStatus.skipped,
          warnings: const ['not_due'],
        );
      }
      _lastAttempt[key] = elapsed;
      final banks = await _retry(
        () => _institutions.getInstitutions(
          country: context.connection.institutionCountry,
          customerType: context.connection.psuType == 'business'
              ? BankingCustomerType.business
              : BankingCustomerType.personal,
        ),
        watch,
      );
      final matches = banks
          .where(
            (bank) =>
                bank.providerId == _providerId &&
                bank.name == context.connection.institutionName &&
                bank.country == context.connection.institutionCountry,
          )
          .toList();
      if (matches.length != 1) {
        return _failure(
          accountId,
          BankSyncStatus.terminalFailure,
          'bank_metadata_unavailable',
        );
      }
      final requiredHeaders = matches.single.requiredPsuHeaders;
      Map<String, String> psuHeaders;
      try {
        psuHeaders = request.headersFor(requiredHeaders);
      } on FormatException {
        return _failure(
          accountId,
          BankSyncStatus.partial,
          'manual_context_required',
        );
      }
      final headers = BankingRequestContext(psuHeaders: psuHeaders);
      final reference = BankingAccountReference(
        providerId: _providerId,
        remoteId: context.account.ebAccountUid!,
      );
      final details = await _retry(
        () => _accountData.getAccount(reference, context: headers),
        watch,
      );
      if (details.reference != reference) {
        return _failure(
          accountId,
          BankSyncStatus.terminalFailure,
          'account_identity_mismatch',
        );
      }
      if (details.currency != context.currency) {
        return _failure(
          accountId,
          BankSyncStatus.terminalFailure,
          'account_currency_mismatch',
        );
      }
      if (details.reference.identityKeys.isNotEmpty &&
          !details.reference.identityKeys.contains(
            context.account.identificationHash,
          )) {
        return _failure(
          accountId,
          BankSyncStatus.terminalFailure,
          'account_identity_mismatch',
        );
      }
      final warnings = <String>[];
      var strategy = BankingHistoryStrategy.longest;
      DateTime? dateFrom;
      if (context.checkpoint != null && context.checkpoint!.isAfter(now)) {
        dateFrom = null;
        strategy = BankingHistoryStrategy.longest;
        warnings.add('future_checkpoint_reset');
      }
      final items = <BankRemoteTransaction>[];
      final seenKeys = <String>{};
      String? continuation;
      DateTime? serverTime;
      var rejected = 0;
      var rawCount = 0;
      var fallback = false;
      for (var pageIndex = 0; ; pageIndex++) {
        if (pageIndex >= limits.pages) {
          return _failure(
            accountId,
            BankSyncStatus.retryableFailure,
            'page_limit',
          );
        }
        BankingTransactionsPage page;
        try {
          page = await _retry(
            () => _accountData.getTransactions(
              reference,
              query: BankingTransactionQuery(
                dateFrom: dateFrom,
                cursor: continuation,
                strategy: strategy,
                context: headers,
                collectRejectedRecords: true,
              ),
            ),
            watch,
          );
        } on BankingException catch (error) {
          if (pageIndex == 0 &&
              !fallback &&
              error.failure == BankingFailure.unsupportedHistoryPeriod) {
            fallback = true;
            strategy = BankingHistoryStrategy.standard;
            dateFrom = null;
            warnings.add('bank_default_history_fallback');
            page = await _retry(
              () => _accountData.getTransactions(
                reference,
                query: BankingTransactionQuery(
                  strategy: strategy,
                  context: headers,
                  collectRejectedRecords: true,
                ),
              ),
              watch,
            );
          } else {
            rethrow;
          }
        }
        if (page.serverTime != null) {
          serverTime ??= page.serverTime;
          if (page.serverTime!.difference(serverTime!).abs() >
              limits.timeout + const Duration(minutes: 1)) {
            return _failure(
              accountId,
              BankSyncStatus.retryableFailure,
              'server_clock_changed',
            );
          }
        }
        rawCount += page.transactions.length + page.rejectedRecords;
        if (rawCount > limits.records) {
          return _failure(
            accountId,
            BankSyncStatus.retryableFailure,
            'record_limit',
          );
        }
        rejected += page.rejectedRecords;
        for (final transaction in page.transactions) {
          try {
            final item = BankRemoteTransaction.fromTransaction(
              transaction,
              context.currency,
            );
            items.add(item);
          } on FormatException {
            rejected++;
          }
        }
        continuation = page.nextCursor;
        if (continuation == null) break;
        if (!seenKeys.add(continuation)) {
          return _failure(
            accountId,
            BankSyncStatus.retryableFailure,
            'continuation_cycle',
          );
        }
      }
      if (serverTime != null) {
        final serverDay = DateTime.utc(
          serverTime.year,
          serverTime.month,
          serverTime.day,
        );
        rejected += items
            .where(
              (item) => item.status == 'BOOK' && item.date.isAfter(serverDay),
            )
            .length;
      }
      if (rejected > 0) {
        return _failure(
          accountId,
          BankSyncStatus.partial,
          'invalid_financial_records',
          rejected: rejected,
        );
      }
      final unique = <String>{};
      if (items.any((item) => !unique.add(item.key))) {
        return _failure(
          accountId,
          BankSyncStatus.partial,
          'ambiguous_transaction_identity',
        );
      }
      if (context.checkpoint != null &&
          items.isNotEmpty &&
          !items.any((item) => !item.date.isAfter(context.checkpoint!))) {
        warnings.add('history_overlap_missing');
      }
      final balances = await _retry(
        () => _accountData.getBalances(reference, context: headers),
        watch,
      );
      final balance = selectBankBalance(
        balances,
        items,
        context.currency,
        serverTime,
      );
      if (!items.any((item) => item.status == 'BOOK') && balance != null) {
        warnings.add('empty_account_history_unverified');
      }
      if (balance == null) {
        warnings.add('no_comparable_booked_balance');
        if (!context.initialized) {
          return _failure(
            accountId,
            BankSyncStatus.partial,
            'initial_balance_unverified',
          );
        }
      }
      if (serverTime == null) {
        return _failure(
          accountId,
          BankSyncStatus.retryableFailure,
          'missing_server_clock',
        );
      }
      if (context.connection.validUntil == null ||
          !context.connection.validUntil!.isAfter(serverTime)) {
        await _repository.markConsentFailure(
          context,
          BankConnectionStatus.expired,
        );
        return _failure(
          accountId,
          BankSyncStatus.terminalFailure,
          'consent_expired',
        );
      }
      if (watch.elapsed >= limits.timeout) {
        throw TimeoutException('Sync deadline');
      }
      final latestAuthorization = await _readContext();
      if (latestAuthorization.providerId != authorization.providerId ||
          latestAuthorization.applicationId != authorization.applicationId) {
        return _failure(
          accountId,
          BankSyncStatus.terminalFailure,
          'credentials_changed',
        );
      }
      return await _repository.commit(
        context,
        items,
        serverTime: serverTime,
        strategy: strategy == BankingHistoryStrategy.longest
            ? 'longest'
            : 'default',
        requestedFrom: dateFrom,
        requiredPsuHeaders: requiredHeaders,
        balance: balance,
        warnings: warnings,
      );
    } on BankSyncIntegrityException catch (error) {
      return _failure(accountId, BankSyncStatus.partial, error.code);
    } on BankingException catch (error) {
      if (startedContext != null) {
        var status = switch (error.failure) {
          BankingFailure.connectionExpired => BankConnectionStatus.expired,
          BankingFailure.connectionRevoked || BankingFailure.connectionClosed =>
            BankConnectionStatus.reauthRequired,
          _ => null,
        };
        if (error.failure == BankingFailure.notFound) {
          status = await _confirmedConsentFailure(startedContext);
        }
        if (status != null) {
          await _repository.markConsentFailure(startedContext, status);
        }
      }
      return _failure(
        accountId,
        error.isRetryable
            ? BankSyncStatus.retryableFailure
            : BankSyncStatus.terminalFailure,
        error.failure == BankingFailure.notFound
            ? 'account_not_found'
            : 'api_${error.failure.name}',
      );
    } on TimeoutException {
      return _failure(
        accountId,
        BankSyncStatus.retryableFailure,
        'operation_timeout',
      );
    } on FormatException {
      return _failure(
        accountId,
        BankSyncStatus.partial,
        'invalid_or_changed_sync_context',
      );
    } on TypeError {
      return _failure(
        accountId,
        BankSyncStatus.partial,
        'invalid_response_schema',
      );
    } on DatabaseException {
      return _failure(
        accountId,
        BankSyncStatus.retryableFailure,
        'database_commit_failed',
      );
    } finally {
      watch.stop();
    }
  }

  Future<BankConnectionStatus?> _confirmedConsentFailure(
    BankSyncContext context,
  ) async {
    final consent = _consent;
    if (consent == null) return null;
    try {
      final reference = BankingConnectionReference(
        providerId: context.connection.providerId,
        remoteId: context.connection.remoteConnectionId!,
      );
      final connection = await consent.getConnection(reference);
      if (connection.reference != reference) return null;
      return switch (connection.status) {
        BankingConnectionStatus.expired => BankConnectionStatus.expired,
        BankingConnectionStatus.cancelled ||
        BankingConnectionStatus.closed ||
        BankingConnectionStatus.invalid ||
        BankingConnectionStatus.revoked => BankConnectionStatus.reauthRequired,
        _ => null,
      };
    } on BankingException catch (error) {
      return switch (error.failure) {
        BankingFailure.connectionExpired => BankConnectionStatus.expired,
        BankingFailure.notFound ||
        BankingFailure.connectionRevoked ||
        BankingFailure.connectionClosed => BankConnectionStatus.reauthRequired,
        _ => null,
      };
    } catch (_) {
      // An inconclusive session check must not invalidate the other accounts.
      return null;
    }
  }
}
