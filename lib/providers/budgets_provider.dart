import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/budget.dart';
import '../services/database/repositories/budget_repository.dart';

part 'budgets_provider.g.dart';

@Riverpod(keepAlive: true)
Future<List<BudgetStats>> monthlyBudgetsStats(Ref ref) async {
  final budgets = await ref
      .read(budgetRepositoryProvider)
      .selectMonthlyBudgetsStats();
  return budgets;
}

@Riverpod(keepAlive: true)
class Budgets extends _$Budgets {
  @override
  Future<List<Budget>> build() async {
    return _getBudgets();
  }

  Future<List<Budget>> getBudgets() async {
    final budgets = await ref.read(budgetRepositoryProvider).selectAllActive();
    return budgets;
  }

  Future<List<Budget>> _getBudgets() async {
    final budgets = await ref.read(budgetRepositoryProvider).selectAllActive();
    return budgets;
  }

  Future<void> addBudget(Budget budget) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(budgetRepositoryProvider).insertOrUpdate(budget);
      return _getBudgets();
    });
  }

  Future<void> updateBudget(Budget budget) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(budgetRepositoryProvider).updateItem(budget);
      return _getBudgets();
    });
  }

  Future<void> removeBudget(int budgetId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(budgetRepositoryProvider).deleteById(budgetId);
      return _getBudgets();
    });
  }

  Future<void> refreshBudgets() async {
    ref.invalidateSelf();
  }
}
