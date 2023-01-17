import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/bank_account.dart';

final mainAccountProvider = StateProvider<BankAccount?>((ref) => null);

class AsyncAccountsNotifier extends AsyncNotifier<List<BankAccount>> {
  @override
  Future<List<BankAccount>> build() async {
    ref.read(mainAccountProvider.notifier).state = await _getMainAccount();
    return _getAccounts();
  }

  Future<List<BankAccount>> _getAccounts() async {
    final account = await BankAccountMethods().selectAll();
    return account;
  }

  // TODO bisognerebbe aggiungere un campo bool 'main_account' o qualcosa di simile, serve per avere l'account già selezionato quando si aggiungono spese
  Future<BankAccount> _getMainAccount() async {
    final account = await BankAccountMethods().selectById(1);
    return account;
  }

  Future<void> addAccount(BankAccount account) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await BankAccountMethods().insert(account);
      return _getAccounts();
    });
  }

  Future<void> updateAccount(BankAccount account) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await BankAccountMethods().updateItem(account);
      return _getAccounts();
    });
  }

  Future<void> removeAccount(int accountId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await BankAccountMethods().deleteById(accountId);
      return _getAccounts();
    });
  }
}

final accountsProvider = AsyncNotifierProvider<AsyncAccountsNotifier, List<BankAccount>>(() {
  return AsyncAccountsNotifier();
});
