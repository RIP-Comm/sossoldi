import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../model/bank_account.dart';
import '../model/transaction.dart';
import 'dashboard_provider.dart';
import 'transactions_provider.dart';

final mainAccountProvider = StateProvider<BankAccount?>((ref) => null);

final selectedAccountProvider =
    StateProvider.autoDispose<BankAccount?>((ref) => null);
final selectedAccountCurrentYearMonthlyBalanceProvider =
    StateProvider<List<FlSpot>>((ref) => const []);
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
    bool countNetWorth = true,
    bool mainAccount = false,
    num startingValue = 0,
  }) async {
    BankAccount account = BankAccount(
      name: name,
      symbol: icon,
      color: color,
      startingValue: startingValue,
      active: active,
      countNetWorth: countNetWorth,
      mainAccount: mainAccount,
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await BankAccountMethods().insert(account);
      return _getAccounts();
    });
  }

  Future<void> updateAccount({
    String? name,
    String? icon,
    int? color,
    num? balance,
    bool? mainAccount,
    bool? countNetWorth,
    bool active = true,
  }) async {
    BankAccount account = ref.read(selectedAccountProvider)!.copy(
          name: name,
          symbol: icon,
          color: color,
          active: active,
          countNetWorth: countNetWorth,
          mainAccount: mainAccount,
        );
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (balance != null && balance != account.total) {
        await _reconcileAccount(account: account, newBalance: balance);
      }
      await BankAccountMethods().updateItem(account);

      if (account.mainAccount) {
        ref.read(mainAccountProvider.notifier).state = account;
      }
      ref.invalidate(dashboardProvider);
      
      return _getAccounts();
    });
  }

Future<void> reconcileAccount({
    required BankAccount account,
    required num newBalance,
  }) async {
    _reconcileAccount(account: account, newBalance: newBalance);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _getAccounts();
    });
  }

  Future<void> _reconcileAccount({
    required BankAccount account,
    required num newBalance,
  }) async {
    final num difference = newBalance - (account.total ?? 0);
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

  Future<void> refreshAccount(BankAccount account) async {
    ref.read(selectedAccountProvider.notifier).state = account;

final currentMonthDailyBalance = await BankAccountMethods()
        .accountMonthlyBalance(account.id!,
            dateRangeStart:
                DateTime(DateTime.now().year, 1, 1), // beginnig of current year
            dateRangeEnd:
                DateTime(DateTime.now().year + 1, 1, 1) // beginnig of next year
            );

    ref.read(selectedAccountCurrentYearMonthlyBalanceProvider.notifier).state =
        currentMonthDailyBalance.map((e) {
      DateTime pointDT = DateTime.parse(e['month'] + "-01");
      return FlSpot(
          pointDT.month - 1, double.parse(e['balance'].toStringAsFixed(2)));
    }).toList();

    ref.read(selectedAccountLastTransactions.notifier).state =
        await BankAccountMethods().getTransactions(account.id!, 50);
  }

  Future<void> removeAccount(BankAccount account) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await BankAccountMethods().deactivateById(account.id!);
      if (account.mainAccount) ref.invalidate(mainAccountProvider);
      return _getAccounts();
    });
  }

  void reset() {
    ref.invalidate(selectedAccountProvider);
    ref.invalidate(selectedAccountCurrentYearMonthlyBalanceProvider);
  }
}

final accountsProvider =
    AsyncNotifierProvider<AsyncAccountsNotifier, List<BankAccount>>(() {
  return AsyncAccountsNotifier();
});
