// dart format width=400

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:url_launcher/url_launcher.dart';

import '../../../model/bank_account.dart';
import '../../../model/bank_account_link.dart';
import '../../../model/bank_connection.dart';
import '../../database/repositories/bank_connection_repository.dart';
import '../bank_authorization_context.dart';
import '../bank_consent_service.dart';
import '../bank_institution.dart';
import '../bank_institution_directory.dart';
import '../banking_account.dart';
import '../banking_authorization.dart';
import '../banking_connection.dart';
import '../banking_exception.dart';
import '../banking_reference.dart';
import 'bank_authorization_callback.dart';
import 'bank_authorization_result.dart';
import 'banking_platform_support.dart';
import 'pending_bank_authorization.dart';
import 'pending_bank_authorization_store.dart';

const _kDefaultConsentValidity = Duration(days: 90);
const _kAuthorizationLifetime = Duration(minutes: 15);

class BankConsentLifecycleService {
  final BankConsentService _consent;
  final BankInstitutionDirectory _institutions;
  final BankAuthorizationContextReader _readContext;
  final PendingBankAuthorizationStore _pendingStore;
  final BankConnectionRepository _connections;
  final DateTime Function() _clock;
  final bool Function() _callbackSupported;
  final Random _random;

  Future<void> _callbackQueue = Future.value();

  BankConsentLifecycleService({required BankConsentService consent, required BankInstitutionDirectory institutions, required BankAuthorizationContextReader readContext, required PendingBankAuthorizationStore pendingStore, required BankConnectionRepository connections, DateTime Function()? clock, bool Function()? callbackSupported, Random? random})
    : _consent = consent,
      _institutions = institutions,
      _readContext = readContext,
      _pendingStore = pendingStore,
      _connections = connections,
      _clock = clock ?? DateTime.now,
      _callbackSupported = callbackSupported ?? BankingPlatformSupport.supportsCallback,
      _random = random ?? Random.secure();

  Future<AuthorizationAttempt> startAuthorization(BankInstitution selectedBankInstitution, {int? reconnectConnectionId}) async {
    if (!_callbackSupported()) {
      throw const BankingException(providerId: 'application', failure: BankingFailure.rejected);
    }
    final config = await _readContext();
    if (selectedBankInstitution.providerId != config.providerId) throw BankingException(providerId: config.providerId, failure: BankingFailure.rejected);
    final existingPending = await _pendingStore.read();
    if (existingPending != null) {
      if (!existingPending.expiresAt.isAfter(_clock().toUtc())) {
        await _pendingStore.clear();
      } else if (existingPending.providerId == config.providerId && existingPending.applicationId == config.applicationId && existingPending.redirectUri == config.redirectUri && existingPending.institutionName == selectedBankInstitution.name && existingPending.institutionCountry == selectedBankInstitution.country && existingPending.reconnectConnectionId == reconnectConnectionId) {
        return AuthorizationAttempt(url: Uri.parse(existingPending.authorizationUrl), consentValidUntil: existingPending.consentValidUntil);
      } else {
        throw const BankingException(providerId: 'application', failure: BankingFailure.rejected);
      }
    }

    final institution = reconnectConnectionId == null ? selectedBankInstitution : await _freshReconnectBankInstitution(selectedBankInstitution, reconnectConnectionId, config.applicationId);
    if (!institution.customerTypes.contains(BankingCustomerType.personal)) {
      throw const BankingException(providerId: 'application', failure: BankingFailure.rejected);
    }
    final maximum = institution.maximumConsentDuration;
    final validity = maximum == null ? _kDefaultConsentValidity : Duration(seconds: min(_kDefaultConsentValidity.inSeconds, max(0, maximum.inSeconds)));
    if (validity == Duration.zero) {
      throw const BankingException(providerId: 'application', failure: BankingFailure.invalidResponse);
    }

    final now = _clock().toUtc();
    final state = _newState();
    final consentValidUntil = now.add(validity);
    final authorization = await _consent.startAuthorization(BankingAuthorizationRequest(institution: institution, state: state, validUntil: consentValidUntil, redirectUri: Uri.parse(config.redirectUri)));
    final authorizationUri = authorization.uri;
    if (authorization.providerId != config.providerId || authorization.authorizationId.trim().isEmpty || authorizationUri.host.isEmpty || authorizationUri.userInfo.isNotEmpty || !authorizationUri.hasScheme || authorizationUri.scheme != 'https') {
      throw const BankingException(providerId: 'application', failure: BankingFailure.invalidResponse);
    }
    await _pendingStore.save(
      PendingBankAuthorization(
        providerId: config.providerId,
        state: state,
        authorizationId: authorization.authorizationId,
        authorizationUrl: authorization.uri.toString(),
        applicationId: config.applicationId,
        institutionName: institution.name,
        institutionCountry: institution.country,
        redirectUri: config.redirectUri,
        expiresAt: now.add(_kAuthorizationLifetime),
        consentValidUntil: consentValidUntil,
        reconnectConnectionId: reconnectConnectionId,
      ),
    );
    return AuthorizationAttempt(url: authorizationUri, consentValidUntil: consentValidUntil);
  }

  Future<AuthorizationLaunchResult> launchAuthorization(Uri url, {AuthorizationUrlLauncher? launcher}) async {
    final opened = await (launcher ?? _launch)(url);
    return AuthorizationLaunchResult(url: url, opened: opened);
  }

  Future<void> cancelAuthorization() => _pendingStore.clear();

  Future<bool> clearExpiredAuthorization() async {
    final pending = await _pendingStore.read();
    if (pending == null || pending.expiresAt.isAfter(_clock().toUtc())) {
      return false;
    }
    await _pendingStore.clear();
    return true;
  }

  Future<StagedBankConnection> completeCallback(BankAuthorizationCallback callback) {
    final completer = Completer<void>();
    final previous = _callbackQueue;
    _callbackQueue = previous.then((_) => completer.future);
    return previous.then((_) async {
      try {
        return await _completeCallback(callback);
      } finally {
        completer.complete();
      }
    });
  }

  Future<BankCallbackDisposition> handleCallback(BankAuthorizationCallback callback, {Future<void> Function(StagedBankConnection result)? onStaged, Future<void> Function(Object error)? onError}) async {
    try {
      final staged = await completeCallback(callback);
      if (onStaged != null) await onStaged(staged);
      return BankCallbackDisposition.terminal;
    } on BankingException catch (error) {
      if (onError != null) await onError(error);
      return error.isRetryable ? BankCallbackDisposition.retryable : BankCallbackDisposition.terminal;
    } catch (error) {
      if (onError != null) await onError(error);
      return BankCallbackDisposition.retryable;
    }
  }

  Future<StagedBankConnection> _completeCallback(BankAuthorizationCallback callback) async {
    final pending = await _pendingStore.read();
    if (pending == null) {
      throw const BankingException(providerId: 'application', failure: BankingFailure.rejected);
    }
    if (callback.state == null || callback.state != pending.state) {
      throw const BankingException(providerId: 'application', failure: BankingFailure.rejected);
    }
    if (!pending.expiresAt.isAfter(_clock().toUtc())) {
      await _pendingStore.clear();
      throw const BankingException(providerId: 'application', failure: BankingFailure.connectionExpired);
    }
    if (callback.error != null) {
      await _pendingStore.clear();
      throw const BankingException(providerId: 'application', failure: BankingFailure.rejected);
    }
    if (callback.code == null || callback.code!.trim().isEmpty) {
      throw const BankingException(providerId: 'application', failure: BankingFailure.rejected);
    }

    final context = await _readContext();
    if (context.providerId != pending.providerId || context.applicationId != pending.applicationId || context.redirectUri != pending.redirectUri) throw BankingException(providerId: pending.providerId, failure: BankingFailure.authentication);

    if (pending.stagedConnectionId case final id?) {
      return StagedBankConnection(connection: await _connections.selectById(id));
    }
    final durable = await _connections.findByPendingAuthorizationId(pending.authorizationId, providerId: pending.providerId);
    if (durable != null) {
      await _pendingStore.save(pending.copy(stagedConnectionId: durable.id, phase: PendingAuthorizationPhase.connectionStaged));
      return StagedBankConnection(connection: durable);
    }

    final result = await _consent.createConnection(callback.code!);
    if (result.connection.reference.providerId != pending.providerId ||
        result.connection.institution.providerId != pending.providerId ||
        result.connection.reference.remoteId.trim().isEmpty ||
        result.connection.status != BankingConnectionStatus.active ||
        !result.connection.validUntil.isAfter(_clock().toUtc()) ||
        !result.connection.institution.customerTypes.contains(BankingCustomerType.personal) ||
        result.connection.institution.name != pending.institutionName ||
        result.connection.institution.country != pending.institutionCountry) {
      throw const BankingException(providerId: 'application', failure: BankingFailure.invalidResponse);
    }
    final connection = await _connections.stageConnection(
      providerId: pending.providerId,
      authorizationId: pending.authorizationId,
      applicationId: pending.applicationId,
      institutionName: result.connection.institution.name,
      institutionCountry: result.connection.institution.country,
      remoteConnectionId: result.connection.reference.remoteId,
      validUntil: result.connection.validUntil,
      psuType: 'personal',
      reconnectConnectionId: pending.reconnectConnectionId,
    );
    await _pendingStore.save(pending.copy(stagedConnectionId: connection.id, phase: PendingAuthorizationPhase.connectionStaged));
    return StagedBankConnection(connection: connection, createdConnection: result);
  }

  Future<BankConnection> activateConnection(int connectionId, List<({BankingAccount remote, BankAccount? newAccount})> selections) async {
    final staged = await _connections.selectById(connectionId);
    if (selections.any((selection) => selection.remote.reference.providerId != staged.providerId)) throw BankingException(providerId: staged.providerId, failure: BankingFailure.rejected);
    final links = selections.map((selection) => BankAccountLink(uid: selection.remote.reference.remoteId, identificationHashes: selection.remote.reference.identityKeys.map((value) => value.trim()).where((value) => value.isNotEmpty).toSet(), iban: selection.remote.iban, newAccount: selection.newAccount)).toList(growable: false);
    final connection = await _connections.activateStagedConnection(connectionId, links);
    final pending = await _pendingStore.read();
    if (pending?.stagedConnectionId == connectionId) {
      await _pendingStore.clear();
    }
    return connection;
  }

  Future<List<ResumableBankConnection>> resumeAwaitingImports() async {
    final result = <ResumableBankConnection>[];
    for (final connection in await _connections.selectAwaitingImport()) {
      final remoteConnectionId = connection.pendingRemoteConnectionId;
      if (remoteConnectionId == null) continue;
      try {
        final details = await _consent.getConnection(await _reference(connection, remoteConnectionId));
        final localStatus = details.status == BankingConnectionStatus.active && details.isExpiredAt(_clock().toUtc()) ? BankConnectionStatus.expired : _localStatus(details.status);
        if (localStatus != BankConnectionStatus.awaitingImport) {
          await _rejectStagedConnection(connection, localStatus);
          continue;
        }
        result.add(ResumableBankConnection(connection: connection, details: details));
      } on BankingException catch (error) {
        final status = _statusForFailure(error.failure);
        if (status != null) {
          await _rejectStagedConnection(connection, status);
          continue;
        }
        rethrow;
      }
    }
    return result;
  }

  Future<void> _rejectStagedConnection(BankConnection connection, BankConnectionStatus failedStatus) async {
    final id = connection.id!;
    if (failedStatus == BankConnectionStatus.reauthRequired) {
      await _connections.markStatus(id, failedStatus);
      return;
    }
    if (connection.remoteConnectionId == null) {
      await _connections.failStagedConnection(id, failedStatus);
    } else {
      await _connections.discardStagedConnection(id);
    }
    final pending = await _pendingStore.read();
    if (pending?.stagedConnectionId == id) await _pendingStore.clear();
  }

  Future<BankConnectionStatus> refreshConnectionState(BankConnection connection) async {
    final id = connection.id;
    final remoteConnectionId = connection.remoteConnectionId;
    if (id == null || remoteConnectionId == null) {
      return connection.status;
    }
    try {
      final details = await _consent.getConnection(await _reference(connection, remoteConnectionId));
      final status = switch (details.status) {
        BankingConnectionStatus.active => details.validUntil.isAfter(_clock().toUtc()) ? BankConnectionStatus.active : BankConnectionStatus.expired,
        BankingConnectionStatus.expired => BankConnectionStatus.expired,
        BankingConnectionStatus.revoked || BankingConnectionStatus.closed => BankConnectionStatus.revoked,
        BankingConnectionStatus.cancelled || BankingConnectionStatus.invalid => BankConnectionStatus.reauthRequired,
        BankingConnectionStatus.pending => BankConnectionStatus.authorizing,
      };
      await _connections.markStatus(id, status);
      return status;
    } on BankingException catch (error) {
      final status = _statusForFailure(error.failure);
      if (status == null) rethrow;
      await _connections.markStatus(id, status);
      return status;
    }
  }

  Future<void> revoke(BankConnection connection) async {
    if (connection.id == null || connection.remoteConnectionId == null) {
      throw const BankingException(providerId: 'application', failure: BankingFailure.rejected);
    }
    await _connections.markStatus(connection.id!, BankConnectionStatus.revocationPending);
    try {
      await _consent.revokeConnection(await _reference(connection, connection.remoteConnectionId!));
    } on BankingException catch (error) {
      if (!error.confirmsMissingConnection) rethrow;
    }
    await _connections.finalizeRemoteRevocation(connection.id!);
  }

  Future<void> disconnectLocally(BankConnection connection) async {
    if (connection.id == null) {
      throw const BankingException(providerId: 'application', failure: BankingFailure.rejected);
    }
    await _connections.disconnectLocally(connection.id!);
  }

  Future<BankInstitution> _freshReconnectBankInstitution(BankInstitution selected, int connectionId, String applicationId) async {
    final connection = await _connections.selectById(connectionId);
    if (connection.providerId != selected.providerId || connection.applicationId != applicationId || connection.institutionName != selected.name || connection.institutionCountry != selected.country) {
      throw const BankingException(providerId: 'application', failure: BankingFailure.rejected);
    }
    final current = await _institutions.getInstitutions(country: selected.country);
    return current.firstWhere(
      (item) => item.providerId == selected.providerId && item.id == selected.id && item.name == selected.name && item.country == selected.country,
      orElse: () => throw const BankingException(providerId: 'application', failure: BankingFailure.rejected),
    );
  }

  BankConnectionStatus _localStatus(BankingConnectionStatus status) => switch (status) {
    BankingConnectionStatus.active => BankConnectionStatus.awaitingImport,
    BankingConnectionStatus.expired => BankConnectionStatus.expired,
    BankingConnectionStatus.revoked || BankingConnectionStatus.closed => BankConnectionStatus.revoked,
    BankingConnectionStatus.cancelled || BankingConnectionStatus.invalid => BankConnectionStatus.reauthRequired,
    BankingConnectionStatus.pending => BankConnectionStatus.authorizing,
  };

  BankConnectionStatus? _statusForFailure(BankingFailure kind) => switch (kind) {
    BankingFailure.connectionExpired => BankConnectionStatus.expired,
    BankingFailure.connectionRevoked || BankingFailure.connectionClosed || BankingFailure.notFound => BankConnectionStatus.revoked,
    BankingFailure.authentication || BankingFailure.forbidden => BankConnectionStatus.reauthRequired,
    _ => null,
  };

  Future<BankingConnectionReference> _reference(BankConnection connection, String remoteId) async {
    final context = await _readContext();
    if (connection.providerId != context.providerId || connection.applicationId != context.applicationId) throw BankingException(providerId: connection.providerId, failure: BankingFailure.authentication);
    return BankingConnectionReference(providerId: connection.providerId, remoteId: remoteId);
  }

  String _newState() {
    final bytes = List<int>.generate(32, (_) => _random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  static Future<bool> _launch(Uri url) => launchUrl(url, mode: LaunchMode.externalApplication);
}
