// dart format width=400

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../bank_authorization_context.dart';
import '../banking_exception.dart';
import 'enable_banking_api.dart';
import 'enable_banking_auth.dart';
import 'enable_banking_config.dart';
import 'enable_banking_credentials_service.dart';
import 'enable_banking_credentials_store.dart';
import 'enable_banking_errors.dart';

part 'enable_banking_dependencies.g.dart';

@Riverpod(keepAlive: true)
EnableBankingCredentialsStore enableBankingCredentialsStore(Ref ref) => const EnableBankingCredentialsStore();

@Riverpod(keepAlive: true)
EnableBankingAuth enableBankingAuth(Ref ref) => EnableBankingAuth();

@Riverpod(keepAlive: true)
EnableBankingApi enableBankingApi(Ref ref) => EnableBankingApi(auth: ref.watch(enableBankingAuthProvider), store: ref.watch(enableBankingCredentialsStoreProvider));

@Riverpod(keepAlive: true)
EnableBankingCredentialsService enableBankingCredentialsService(Ref ref) => EnableBankingCredentialsService(api: ref.watch(enableBankingApiProvider), store: ref.watch(enableBankingCredentialsStoreProvider));

Future<BankAuthorizationContext> readEnableBankingAuthorizationContext(EnableBankingCredentialsStore store) => withEnableBankingErrors(() async {
  final credentials = await store.readCredentials();
  if (credentials == null) throw const BankingException(providerId: enableBankingId, failure: BankingFailure.authentication);
  final config = credentials.config;
  validateEnableBankingRedirect(config.redirectUri, registeredRedirects: config.redirectUrls);
  return BankAuthorizationContext(providerId: enableBankingId, applicationId: config.appId, redirectUri: config.redirectUri);
});
