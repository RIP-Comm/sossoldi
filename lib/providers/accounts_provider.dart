import 'package:fl_chart/fl_chart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/bank_account.dart';
import '../model/transaction.dart';
import '../services/database/repositories/account_repository.dart';
import 'dashboard_provider.dart';
import 'recurring_transactions_provider.dart';
import 'transactions_provider.dart';

part 'accounts_provider.g.dart';

@Riverpod(keepAlive: true)
class MainAccount extends _$MainAccount {
  @override
  BankAccount? build() => null;

  void setAccount(BankAccount? account) => state = account;
}

@riverpod
class SelectedAccount extends _$SelectedAccount {
  @override
  BankAccount? build() => null;

  void setAccount(BankAccount? account) => state = account;
}

@Riverpod(keepAlive: true)
class SelectedAccountCurrentYearMonthlyBalance
    extends _$SelectedAccountCurrentYearMonthlyBalance {
  @override
  List<FlSpot> build() => [];

  void setBalanceList(List<FlSpot> balanceList) => state = balanceList;
}

@Riverpod(keepAlive: true)
class SelectedAccountLastTransactions
    extends _$SelectedAccountLastTransactions {
  @override
  List build() => [];

  void setTransactions(List lastTransactions) => state = lastTransactions;
}

@Riverpod(keepAlive: true)
class FilterAccount extends _$FilterAccount {
  @override
  Map<int, bool> build() => {};

  void setAccounts(Map<int, bool> accountsFilter) => state = accountsFilter;
}

@Riverpod(keepAlive: true)
class Accounts extends _$Accounts {
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
    final accounts = await ref.read(accountRepositoryProvider).selectAll();
    return accounts;
  }

  Future<BankAccount?> _getMainAccount() async {
    final account = await ref.read(accountRepositoryProvider).selectMain();
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
      order: 0,
    );

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(accountRepositoryProvider).insert(account);
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
    BankAccount account = ref
        .read(selectedAccountProvider)!
        .copy(
          name: name,
          symbol: icon,
          color: color,
          active: active,
          countNetWorth: countNetWorth,
          mainAccount: mainAccount,
        );
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (balance != null && balance != account.total) {
        await _reconcileAccount(account: account, newBalance: balance);
      }
      await ref.read(accountRepositoryProvider).updateItem(account);

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
    state = const AsyncLoading();
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
      await ref
          .read(transactionsProvider.notifier)
          .create(
            difference.abs(),
            'Reconciliation',
            account: account,
            type: difference > 0
                ? TransactionType.income
                : TransactionType.expense,
            date: DateTime.now(),
          );
    }
  }

  Future<void> refreshAccount(BankAccount account) async {
    ref.invalidate(transactionsProvider);
    ref.invalidate(recurringTransactionsProvider);
    ref.read(selectedAccountProvider.notifier).state = account;

    final currentMonthDailyBalance = await ref
        .read(accountRepositoryProvider)
        .accountMonthlyBalance(
          account.id!,
          dateRangeStart: DateTime(
            DateTime.now().year,
            1,
            1,
          ), // beginnig of current year
          dateRangeEnd: DateTime(
            DateTime.now().year + 1,
            1,
            1,
          ), // beginnig of next year
        );

    ref
        .read(selectedAccountCurrentYearMonthlyBalanceProvider.notifier)
        .state = currentMonthDailyBalance.map((e) {
      DateTime pointDT = DateTime.parse(e['month'] + "-01");
      return FlSpot(
        pointDT.month - 1,
        double.parse(e['balance'].toStringAsFixed(2)),
      );
    }).toList();

    ref
        .read(selectedAccountLastTransactionsProvider.notifier)
        .setTransactions(
          await ref
              .read(accountRepositoryProvider)
              .getTransactions(account.id!, 50),
        );
  }

  Future<void> removeAccount(BankAccount account) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(accountRepositoryProvider).deactivateById(account.id!);
      if (account.mainAccount) ref.invalidate(mainAccountProvider);
      return _getAccounts();
    });
  }

  Future<void> reorderAccounts(int oldIndex, int newIndex) async {
    final currentList = state.value;
    if (currentList == null) return;

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final newList = List<BankAccount>.from(currentList);
    final item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);

    state = AsyncData(newList);

    await AsyncValue.guard(() async {
      await ref.read(accountRepositoryProvider).updateOrders(newList);
    });
  }

  void reset() {
    ref.invalidate(selectedAccountProvider);
    ref.invalidate(selectedAccountCurrentYearMonthlyBalanceProvider);
  }
}
