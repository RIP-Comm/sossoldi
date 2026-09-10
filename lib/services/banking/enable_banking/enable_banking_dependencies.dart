import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'enable_banking_api.dart';
import 'enable_banking_auth.dart';
import 'enable_banking_config.dart';
import 'enable_banking_credentials_service.dart';
import 'enable_banking_credentials_store.dart';

part 'enable_banking_dependencies.g.dart';

@Riverpod(keepAlive: true)
EnableBankingCredentialsStore enableBankingCredentialsStore(Ref ref) =>
    const EnableBankingCredentialsStore();

@Riverpod(keepAlive: true)
EnableBankingAuth enableBankingAuth(Ref ref) => EnableBankingAuth();

@Riverpod(keepAlive: true)
EnableBankingApi enableBankingApi(Ref ref) => EnableBankingApi(
  auth: ref.watch(enableBankingAuthProvider),
  store: ref.watch(enableBankingCredentialsStoreProvider),
);

@Riverpod(keepAlive: true)
EnableBankingCredentialsService enableBankingCredentialsService(Ref ref) =>
    EnableBankingCredentialsService(
      api: ref.watch(enableBankingApiProvider),
      store: ref.watch(enableBankingCredentialsStoreProvider),
    );

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

  Future<void> save({
    required String appId,
    required String privateKeyPem,
    required EnableBankingConfig config,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final saved = await ref
          .read(enableBankingCredentialsServiceProvider)
          .saveVerifiedCredentials(
            appId: appId,
            privateKeyPem: privateKeyPem,
            redirectUri: config.redirectUri,
            defaultCountry: config.defaultCountry,
          );
      return saved;
    });
  }

  Future<void> clear() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final store = ref.read(enableBankingCredentialsStoreProvider);
      await store.clear();
      return null;
    });
  }
}
