import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/budget.dart';

class AsyncBudgetsNotifier extends AsyncNotifier<List<Budget>> {
  @override
  Future<List<Budget>> build() async {
    return _getBudgets();
  }

  Future<List<Budget>> getBudgets() async {
    final budgets = await BudgetMethods().selectAllActive();
    return budgets;
  }

  Future<List<Budget>> _getBudgets() async {
    final budgets = await BudgetMethods().selectAllActive();
    return budgets;
  }

  Future<List<BudgetStats>> getMonthlyBudgetsStats() async {
    final budgets = await BudgetMethods().selectMonthlyBudgetsStats();
    return budgets;
  }

  Future<void> addBudget(Budget budget) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await BudgetMethods().insertOrUpdate(budget);
      return _getBudgets();
    });
  }

  Future<void> updateBudget(Budget budget) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await BudgetMethods().updateItem(budget);
      return _getBudgets();
    });
  }

  Future<void> removeBudget(int budgetId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await BudgetMethods().deleteById(budgetId);
      return _getBudgets();
    });
  }
}

final budgetsProvider =
    AsyncNotifierProvider<AsyncBudgetsNotifier, List<Budget>>(() {
  return AsyncBudgetsNotifier();
});
