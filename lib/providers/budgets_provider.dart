import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/budget.dart';

final selectedBudgetProvider = StateProvider<Budget?>((ref) => null);
final budgetCategoryIdProvider = StateProvider<int>((ref) => 0);
final budgetNameProvider = StateProvider<String?>((ref) => null);
final budgetAmountLimitProvider = StateProvider<num>((ref) => 0);
final budgetActiveProvider = StateProvider<bool>((ref) => false);

class AsyncBudgetsNotifier extends AsyncNotifier<List<Budget>> {
  @override
  Future<List<Budget>> build() async {
    return _getBudgets();
  }

  Future<List<Budget>> _getBudgets() async {
    final account = await BudgetMethods().selectAllActive();
    return account;
  }

  Future<void> addBudget() async {
    state = const AsyncValue.loading();

    Budget budget = Budget(
      idCategory: ref.read(budgetCategoryIdProvider),
      amountLimit: ref.read(budgetAmountLimitProvider),
      active: ref.read(budgetActiveProvider),
    );

    state = await AsyncValue.guard(() async {
      await BudgetMethods().insert(budget);
      return _getBudgets();
    });
  }

  Future<void> updateBudget(Budget budget) async {
    Budget editBudget = budget.copy(
      idCategory: ref.read(budgetCategoryIdProvider),
      amountLimit: ref.read(budgetAmountLimitProvider),
      active: ref.read(budgetActiveProvider),
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await BudgetMethods().updateItem(editBudget);
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
