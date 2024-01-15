import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/constants.dart';
import '../model/bank_account.dart';
import 'package:fl_chart/fl_chart.dart';

final mainAccountProvider = StateProvider<BankAccount?>((ref) => null);

final selectedAccountProvider = StateProvider<BankAccount?>((ref) => null);
final accountIconProvider = StateProvider<String>((ref) => accountIconList.keys.first);
final accountColorProvider = StateProvider<int>((ref) => 0);
final accountMainSwitchProvider = StateProvider<bool>((ref) => false);
final countNetWorthSwitchProvider = StateProvider<bool>((ref) => true);
final selectedAccountCurrentMonthDailyBalanceProvider = StateProvider<List<FlSpot>>((ref) => const []);

class AsyncAccountsNotifier extends AsyncNotifier<List<BankAccount>> {
  @override
  Future<List<BankAccount>> build() async {
    ref.watch(mainAccountProvider.notifier).state = await _getMainAccount();
    return _getAccounts();
  }

  Future<List<BankAccount>> _getAccounts() async {
    final accounts = await BankAccountMethods().selectAll();
    return accounts;
  }

  Future<BankAccount?> _getMainAccount() async {
    final account = await BankAccountMethods().selectMain();
    return account;
  }

  Future<void> addAccount(String name, num? startingValue) async {
    BankAccount account = BankAccount(
      name: name,
      symbol: ref.read(accountIconProvider),
      color: ref.read(accountColorProvider),
      startingValue: startingValue ?? 0,
      active: ref.read(countNetWorthSwitchProvider),
      mainAccount: ref.read(accountMainSwitchProvider),
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await BankAccountMethods().insert(account);
      return _getAccounts();
    });
  }

  Future<void> updateAccount(String name) async {
    BankAccount account = ref.read(selectedAccountProvider)!.copy(
      name: name,
      symbol: ref.read(accountIconProvider),
      color: ref.read(accountColorProvider),
      active: ref.read(countNetWorthSwitchProvider),
      mainAccount: ref.read(accountMainSwitchProvider),
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await BankAccountMethods().updateItem(account);
      if(account.mainAccount) {
        ref.read(mainAccountProvider.notifier).state = account;
      }
      return _getAccounts();
    });
  }

  Future<void> selectedAccount(BankAccount account) async {
    ref.read(selectedAccountProvider.notifier).state = account;
    ref.read(accountIconProvider.notifier).state = account.symbol;
    ref.read(accountColorProvider.notifier).state = account.color;
    ref.read(accountMainSwitchProvider.notifier).state = account.mainAccount;

    final currentMonthDailyBalance = await BankAccountMethods()
        .accountDailyBalance(
          account.id!,
          dateRangeStart: DateTime(DateTime.now().year, DateTime.now().month, 1), // beginnig of current month
          dateRangeEnd: DateTime(DateTime.now().year, DateTime.now().month + 1, 1) // beginnig of next month
        ); 

    ref.read(selectedAccountCurrentMonthDailyBalanceProvider.notifier).state =
        currentMonthDailyBalance.map((e) {
      return FlSpot(double.parse(e['day'].substring(8)) - 1,
          double.parse(e['balance'].toStringAsFixed(2)));
    }).toList();
  }

  Future<void> removeAccount(int accountId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await BankAccountMethods().deactivateById(accountId);
      return _getAccounts();
    });
  }

  void reset() {
    ref.invalidate(selectedAccountProvider);
    ref.invalidate(selectedAccountCurrentMonthDailyBalanceProvider);
    ref.invalidate(accountIconProvider);
    ref.invalidate(accountColorProvider);
    ref.invalidate(accountMainSwitchProvider);
    ref.invalidate(countNetWorthSwitchProvider);
  }
}

final accountsProvider = AsyncNotifierProvider<AsyncAccountsNotifier, List<BankAccount>>(() {
  return AsyncAccountsNotifier();
});
