// dart format width=400

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/model/bank_connection.dart';
import 'package:sossoldi/providers/banking_provider.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_api.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_auth.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_config.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_credentials_store.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_dependencies.dart';
import 'package:sossoldi/services/banking/enable_banking/models/eb_application.dart';
import 'package:sossoldi/services/database/migration_manager.dart';
import 'package:sossoldi/services/database/repositories/bank_connection_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _ApplicationApi extends EnableBankingApi {
  _ApplicationApi() : super(auth: EnableBankingAuth(), store: const EnableBankingCredentialsStore());

  Object? failure;
  int calls = 0;

  @override
  Future<EbApplication> verifyApplicationCredentials({required String appId, required String privateKeyPem}) async {
    calls++;
    if (failure case final error?) throw error;
    return EbApplication(name: 'Synthetic application', kid: appId, environment: EnableBankingEnvironment.production, active: true, services: ['AIS'], countries: ['IT'], redirectUrls: [kEbRedirectUri]);
  }
}

class _Connections extends BankConnectionRepository {
  _Connections(super.database) : super.withDatabase();

  bool failWrites = false;

  @override
  Future<void> markOtherApplicationsReauthRequired(String applicationId, {required String providerId}) async {
    if (failWrites) throw StateError('Synthetic database write failure');
    await super.markOtherApplicationsReauthRequired(applicationId, providerId: providerId);
  }

  @override
  Future<void> markAllReauthRequired({required String providerId}) async {
    if (failWrites) throw StateError('Synthetic database write failure');
    await super.markAllReauthRequired(providerId: providerId);
  }
}

void main() {
  const store = EnableBankingCredentialsStore();
  late Database db;
  late _Connections connections;
  late _ApplicationApi api;
  late ProviderContainer container;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    sqfliteFfiInit();
    final manager = MigrationManager();
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(version: manager.latestVersion, onCreate: (db, version) => manager.migrate(db, 0, version)),
    );
    connections = _Connections(db);
    api = _ApplicationApi();
    container = ProviderContainer(overrides: [enableBankingCredentialsStoreProvider.overrideWithValue(store), enableBankingApiProvider.overrideWithValue(api), bankConnectionRepositoryProvider.overrideWithValue(connections)]);
    await container.read(enableBankingSettingsProvider.future);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> seedCredentials() => store.saveCredentials(
    appId: 'old-app',
    privateKeyPem: 'old-synthetic-key',
    config: const EnableBankingConfig(appId: 'old-app', defaultCountry: 'IT', supportedCountries: ['IT'], redirectUrls: [kEbRedirectUri]),
  );
  Future<BankConnection> seedConnection(String applicationId, {String providerId = 'enable_banking'}) => connections.insert(BankConnection(providerId: providerId, applicationId: applicationId, institutionName: 'Synthetic bank', institutionCountry: 'IT', status: BankConnectionStatus.active));
  Future<void> save() => container
      .read(enableBankingSettingsProvider.notifier)
      .save(
        appId: 'new-app',
        privateKeyPem: 'new-synthetic-key',
        config: const EnableBankingConfig(appId: 'new-app', defaultCountry: 'it'),
      );

  test('settings read the provider credential store', () async {
    expect(await container.read(enableBankingSettingsProvider.notifier).hasCredentials(), isFalse);
    await seedCredentials();
    container.invalidate(enableBankingSettingsProvider);
    expect((await container.read(enableBankingSettingsProvider.future))?.appId, 'old-app');
    expect(await container.read(enableBankingSettingsProvider.notifier).hasCredentials(), isTrue);
  });

  test('verified save invalidates only other applications of the selected provider', () async {
    await seedCredentials();
    final old = await seedConnection('old-app');
    final same = await seedConnection('new-app');
    final otherProvider = await seedConnection('old-app', providerId: 'alternative');
    await save();
    expect(api.calls, 1);
    final saved = container.read(enableBankingSettingsProvider).requireValue!;
    expect(saved.appId, 'new-app');
    expect(saved.defaultCountry, 'IT');
    expect(saved.supportedCountries, ['IT']);
    expect((await store.readCredentials())?.privateKeyPem, 'new-synthetic-key');
    expect((await connections.selectById(old.id!)).status, BankConnectionStatus.reauthRequired);
    expect((await connections.selectById(same.id!)).status, BankConnectionStatus.active);
    expect((await connections.selectById(otherProvider.id!)).status, BankConnectionStatus.active);
  });

  test('database failure restores the complete previous credential set', () async {
    await seedCredentials();
    final previous = await store.readCredentials();
    connections.failWrites = true;
    await save();
    expect(container.read(enableBankingSettingsProvider).error, isA<StateError>());
    final restored = await store.readCredentials();
    expect(restored?.config.toJson(), previous!.config.toJson());
    expect(restored?.privateKeyPem, previous.privateKeyPem);
  });

  test('failed first save removes the new credentials when there was no previous set', () async {
    connections.failWrites = true;
    await save();
    expect(container.read(enableBankingSettingsProvider).hasError, isTrue);
    expect(await store.readCredentials(), isNull);
  });

  test('verification failure leaves credentials and consent state unchanged', () async {
    await seedCredentials();
    final connection = await seedConnection('old-app');
    api.failure = StateError('Synthetic verification failure');
    await save();
    expect(container.read(enableBankingSettingsProvider).hasError, isTrue);
    expect((await store.readCredentials())?.config.appId, 'old-app');
    expect((await connections.selectById(connection.id!)).status, BankConnectionStatus.active);
  });

  test('clear invalidates only the selected provider before removing its credentials', () async {
    await seedCredentials();
    final connection = await seedConnection('old-app');
    final otherProvider = await seedConnection('old-app', providerId: 'alternative');
    await container.read(enableBankingSettingsProvider.notifier).clear();
    expect(container.read(enableBankingSettingsProvider).requireValue, isNull);
    expect(await store.readCredentials(), isNull);
    expect((await connections.selectById(connection.id!)).status, BankConnectionStatus.reauthRequired);
    expect((await connections.selectById(otherProvider.id!)).status, BankConnectionStatus.active);
  });

  test('clear preserves credentials when invalidating consents fails', () async {
    await seedCredentials();
    connections.failWrites = true;
    await container.read(enableBankingSettingsProvider.notifier).clear();
    expect(container.read(enableBankingSettingsProvider).hasError, isTrue);
    expect((await store.readCredentials())?.config.appId, 'old-app');
  });
}
