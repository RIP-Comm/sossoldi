// dart format width=400

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/banking/bank_account_data_source.dart' as domain;
import '../services/banking/bank_authorization_context.dart';
import '../services/banking/bank_consent_service.dart' as domain;
import '../services/banking/bank_institution_directory.dart' as domain;
import '../services/banking/banking_provider.dart';
import '../services/banking/enable_banking/enable_banking_config.dart';
import '../services/banking/enable_banking/enable_banking_dependencies.dart';
import '../services/banking/enable_banking/enable_banking_errors.dart';
import '../services/banking/enable_banking/enable_banking_provider.dart';
import '../services/banking/lifecycle/bank_authorization_callback.dart';
import '../services/banking/lifecycle/bank_consent_lifecycle_service.dart';
import '../services/banking/lifecycle/bank_deeplink_service.dart';
import '../services/banking/lifecycle/banking_platform_support.dart';
import '../services/banking/lifecycle/pending_bank_authorization_store.dart';
import '../services/database/repositories/bank_connection_repository.dart';

part 'banking_provider.g.dart';

@Riverpod(keepAlive: true)
BankingProvider bankingService(Ref ref) => EnableBankingProvider(ref.watch(enableBankingApiProvider));

@Riverpod(keepAlive: true)
domain.BankInstitutionDirectory bankInstitutionDirectory(Ref ref) => ref.watch(bankingServiceProvider).institutions;

@Riverpod(keepAlive: true)
domain.BankConsentService bankConsentService(Ref ref) => ref.watch(bankingServiceProvider).consent;

@Riverpod(keepAlive: true)
domain.BankAccountDataSource bankAccountDataSource(Ref ref) => ref.watch(bankingServiceProvider).accountData;

@Riverpod(keepAlive: true)
BankAuthorizationContextReader bankAuthorizationContextReader(Ref ref) {
  final store = ref.watch(enableBankingCredentialsStoreProvider);
  return () => readEnableBankingAuthorizationContext(store);
}

@Riverpod(keepAlive: true)
PendingBankAuthorizationStore pendingBankAuthorizationStore(Ref ref) => const SecurePendingBankAuthorizationStore();

@Riverpod(keepAlive: true)
BankConsentLifecycleService bankConsentLifecycleService(Ref ref) => BankConsentLifecycleService(consent: ref.watch(bankConsentServiceProvider), institutions: ref.watch(bankInstitutionDirectoryProvider), readContext: ref.watch(bankAuthorizationContextReaderProvider), pendingStore: ref.watch(pendingBankAuthorizationStoreProvider), connections: ref.watch(bankConnectionRepositoryProvider));

@Riverpod(keepAlive: true)
BankDeeplinkService bankDeeplinkService(Ref ref) {
  final service = BankDeeplinkService();
  ref.onDispose(() => unawaited(service.dispose()));
  return service;
}

class BankCallbackResultState {
  final bool processing;
  final int? connectionId;
  final Object? error;

  const BankCallbackResultState({this.processing = false, this.connectionId, this.error});
}

@Riverpod(keepAlive: true)
class BankCallbackResult extends _$BankCallbackResult {
  @override
  BankCallbackResultState build() => const BankCallbackResultState();

  Future<BankCallbackDisposition> handle(BankAuthorizationCallback callback) async {
    state = const BankCallbackResultState(processing: true);
    return ref
        .read(bankConsentLifecycleServiceProvider)
        .handleCallback(
          callback,
          onStaged: (staged) async {
            state = BankCallbackResultState(connectionId: staged.connection.id);
          },
          onError: reportError,
        );
  }

  Future<void> reportError(Object error) async {
    state = BankCallbackResultState(error: error);
  }
}

@Riverpod(keepAlive: true)
Future<void> bankingCallbackBootstrap(Ref ref) async {
  if (!BankingPlatformSupport.supportsCallback()) return;
  await ref.read(bankConsentLifecycleServiceProvider).clearExpiredAuthorization();
  await ref.watch(bankDeeplinkServiceProvider).start(ref.read(bankCallbackResultProvider.notifier).handle, onError: ref.read(bankCallbackResultProvider.notifier).reportError);
}

@Riverpod(keepAlive: true)
class EnableBankingSettings extends _$EnableBankingSettings {
  @override
  Future<EnableBankingConfig?> build() async {
    final store = ref.watch(enableBankingCredentialsStoreProvider);
    return store.readConfig();
  }

  Future<bool> hasCredentials() async {
    final store = ref.watch(enableBankingCredentialsStoreProvider);
    return store.hasCredentials();
  }

  Future<void> save({required String appId, required String privateKeyPem, required EnableBankingConfig config}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final store = ref.read(enableBankingCredentialsStoreProvider);
      final previous = await store.readCredentials();
      final saved = await ref.read(enableBankingCredentialsServiceProvider).saveVerifiedCredentials(appId: appId, privateKeyPem: privateKeyPem, redirectUri: config.redirectUri, defaultCountry: config.defaultCountry);
      try {
        await ref.read(bankConnectionRepositoryProvider).markOtherApplicationsReauthRequired(saved.appId, providerId: enableBankingId);
      } catch (_) {
        if (previous == null) {
          await store.clear();
        } else {
          await store.saveCredentials(appId: previous.config.appId, privateKeyPem: previous.privateKeyPem, config: previous.config);
        }
        rethrow;
      }
      return saved;
    });
  }

  Future<void> clear() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final store = ref.read(enableBankingCredentialsStoreProvider);
      await ref.read(bankConnectionRepositoryProvider).markAllReauthRequired(providerId: enableBankingId);
      await store.clear();
      return null;
    });
  }
}
