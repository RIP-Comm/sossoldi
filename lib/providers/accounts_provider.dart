import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../model/bank_account.dart';
import '../model/transaction.dart';
import 'transactions_provider.dart';

final mainAccountProvider = StateProvider<BankAccount?>((ref) => null);

final selectedAccountProvider = StateProvider.autoDispose<BankAccount?>((ref) => null);
final selectedAccountCurrentMonthDailyBalanceProvider = StateProvider<List<FlSpot>>((ref) => const []);
final selectedAccountLastTransactions = StateProvider<List>((ref) => const []);
final filterAccountProvider = StateProvider<Map<int, bool>>((ref) => {});

class AsyncAccountsNotifier extends AsyncNotifier<List<BankAccount>> {
  @override
  Future<List<BankAccount>> build() async {
    ref.watch(mainAccountProvider.notifier).state = await _getMainAccount();
    List<BankAccount> accounts = await _getAccounts();

    for (BankAccount account in accounts) {
      ref.watch(filterAccountProvider.notifier).state[account.id!] = false;
    }

    return accounts;
  }

  Future<List<BankAccount>> _getAccounts() async {
    final accounts = await BankAccountMethods().selectAll();
    return accounts;
  }

  Future<BankAccount?> _getMainAccount() async {
    final account = await BankAccountMethods().selectMain();
    return account;
  }

  Future<void> addAccount({
    required String name,
    required String icon,
    required int color,
    bool active = true,
    bool mainAccount = false,
    num startingValue = 0,
  }) async {
    BankAccount account = BankAccount(
      name: name,
      symbol: icon,
      color: color,
      startingValue: startingValue,
      active: active,
      mainAccount: mainAccount,
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await BankAccountMethods().insert(account);
      return _getAccounts();
    });
  }

  Future<void> updateAccount({
    required String name,
    required String icon,
    required int color,
    num? currentBalance,
    bool active = true,
    bool mainAccount = false,
  }) async {
    BankAccount account = ref.read(selectedAccountProvider)!.copy(
          name: name,
          symbol: icon,
          color: color,
          active: active,
          mainAccount: mainAccount,
        );
    if (currentBalance != null) {
      final num difference = currentBalance - (account.total ?? 0);
      if (difference != 0) {
        final transactionsNotifier = ref.read(transactionsProvider.notifier);
        await transactionsNotifier.addTransaction(
          difference.abs(),
          'Reconciliation',
          account: account,
          type: difference > 0 ? TransactionType.income : TransactionType.expense,
          date: DateTime.now(),
        );
      }
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await BankAccountMethods().updateItem(account);
      if (account.mainAccount) {
        ref.read(mainAccountProvider.notifier).state = account;
      }
      return _getAccounts();
    });
  }

  Future<void> refreshAccount(BankAccount account) async {
    ref.read(selectedAccountProvider.notifier).state = account;

    final currentMonthDailyBalance = await BankAccountMethods().accountDailyBalance(account.id!,
        dateRangeStart: DateTime(DateTime.now().year, DateTime.now().month, 1), // beginnig of current month
        dateRangeEnd: DateTime(DateTime.now().year, DateTime.now().month + 1, 1) // beginnig of next month
        );

    ref.read(selectedAccountCurrentMonthDailyBalanceProvider.notifier).state = currentMonthDailyBalance.map((e) {
      return FlSpot(double.parse(e['day'].substring(8)) - 1, double.parse(e['balance'].toStringAsFixed(2)));
    }).toList();

    ref.read(selectedAccountLastTransactions.notifier).state =
        await BankAccountMethods().getTransactions(account.id!, 50);
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
  }
}

final accountsProvider = AsyncNotifierProvider<AsyncAccountsNotifier, List<BankAccount>>(() {
  return AsyncAccountsNotifier();
});
