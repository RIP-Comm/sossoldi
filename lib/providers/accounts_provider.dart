import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/constants.dart';
import '../model/bank_account.dart';

final mainAccountProvider = StateProvider<BankAccount?>((ref) => null);

final selectedAccountProvider = StateProvider<BankAccount?>((ref) => null);
final accountNameProvider = StateProvider<String?>((ref) => null);
final accountIconProvider = StateProvider<String>((ref) => accountIconList.keys.first);
final accountColorProvider = StateProvider<int>((ref) => 0);
final accountMainSwitchProvider = StateProvider<bool>((ref) => false);
final countNetWorthSwitchProvider = StateProvider<bool>((ref) => true);

class AsyncAccountsNotifier extends AsyncNotifier<List<BankAccount>> {
  @override
  Future<List<BankAccount>> build() async {
    ref.watch(mainAccountProvider.notifier).state = await _getMainAccount();
    return _getAccounts();
  }

  Future<List<BankAccount>> _getAccounts() async {
    final account = await BankAccountMethods().selectAll();
    return account;
  }

  Future<BankAccount?> _getMainAccount() async {
    final account = await BankAccountMethods().selectMain();
    return account;
  }

  Future<void> addAccount() async {
    state = const AsyncValue.loading();

    BankAccount account = BankAccount(
      name: ref.read(accountNameProvider)!,
      symbol: ref.read(accountIconProvider),
      color: ref.read(accountColorProvider),
      startingValue: 0,
      active: true,
      mainAccount: ref.read(accountMainSwitchProvider),
    );

    state = await AsyncValue.guard(() async {
      await BankAccountMethods().insert(account);
      return _getAccounts();
    });
  }

  Future<void> updateAccount(BankAccount account) async {
    BankAccount editAccount = account.copy(
      name: ref.read(accountNameProvider)!,
      symbol: ref.read(accountIconProvider),
      color: ref.read(accountColorProvider),
      mainAccount: ref.read(accountMainSwitchProvider),
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await BankAccountMethods().updateItem(editAccount);
      if(editAccount.mainAccount) {
        ref.read(mainAccountProvider.notifier).state = editAccount;
      }
      return _getAccounts();
    });
  }

  Future<void> selectedAccount(BankAccount account) async {
    ref.read(selectedAccountProvider.notifier).state = account;
    ref.read(accountNameProvider.notifier).state = account.name;
    ref.read(accountIconProvider.notifier).state = account.symbol;
    ref.read(accountColorProvider.notifier).state = account.color;
    ref.read(accountMainSwitchProvider.notifier).state = account.mainAccount;
  }

  Future<void> removeAccount(int accountId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await BankAccountMethods().deactivateById(accountId);
      return _getAccounts();
    });
  }
}

final accountsProvider = AsyncNotifierProvider<AsyncAccountsNotifier, List<BankAccount>>(() {
  return AsyncAccountsNotifier();
});
