import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/budget.dart';

class AsyncBudgetsNotifier extends AsyncNotifier<List<Budget>> {
  @override
  Future<List<Budget>> build() async {
    return _getBudgets();
  }

  Future<List<Budget>> _getBudgets() async {
    final account = await BudgetMethods().selectAllActive();
    return account;
  }

  Future<void> addAccount(Budget account) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await BudgetMethods().insert(account);
      return _getBudgets();
    });
  }

  Future<void> updateAccount(Budget account) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await BudgetMethods().updateItem(account);
      return _getBudgets();
    });
  }

  Future<void> removeAccount(int accountId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await BudgetMethods().deleteById(accountId);
      return _getBudgets();
    });
  }
}

final budgetsProvider =
    AsyncNotifierProvider<AsyncBudgetsNotifier, List<Budget>>(() {
  return AsyncBudgetsNotifier();
});
