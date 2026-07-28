import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/banking/enable_banking_config.dart';
import '../services/banking/enable_banking_credentials_store.dart';

part 'banking_provider.g.dart';

@Riverpod(keepAlive: true)
EnableBankingCredentialsStore enableBankingCredentialsStore(Ref ref) =>
    const EnableBankingCredentialsStore();

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
      final store = ref.read(enableBankingCredentialsStoreProvider);
      await store.saveCredentials(
        appId: appId,
        privateKeyPem: privateKeyPem,
        config: config,
      );
      return store.readConfig();
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
