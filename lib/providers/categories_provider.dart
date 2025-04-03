import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/category_transaction.dart';
import '../model/recurring_transaction.dart';
import '../model/transaction.dart';
import 'budgets_provider.dart';
import 'transactions_provider.dart';

final categoryTransactionTypeList = Provider<List<CategoryTransactionType>>(
    (ref) => [CategoryTransactionType.income, CategoryTransactionType.expense]);

final selectedCategoryProvider =
    StateProvider.autoDispose<CategoryTransaction?>((ref) => null);

final categoryTypeProvider = StateProvider<CategoryTransactionType>(
    (ref) => CategoryTransactionType.expense); //default as 'Expense'

final selectedCategoryIndexProvider =
    StateProvider.autoDispose<int>((ref) => -1);

class AsyncCategoriesNotifier
    extends FamilyAsyncNotifier<List<CategoryTransaction>, CategoryFilter> {
  @override
  Future<List<CategoryTransaction>> build(CategoryFilter filter) async {
    return _getCategories(filter);
  }

  Future<List<CategoryTransaction>> _getCategories(
      CategoryFilter filter) async {
    final categories =
        await CategoryTransactionMethods().selectCategories(filter);
    return categories;
  }

  Future<void> addCategory({
    required String name,
    required CategoryTransactionType type,
    required String icon,
    required int color,
  }) async {
    CategoryTransaction category = CategoryTransaction(
      name: name,
      symbol: icon,
      type: type,
      color: color,
      markedAsDeleted: false,
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await CategoryTransactionMethods().insert(category);
      ref.invalidate(categoriesByTypeProvider(category.type));
      return _getCategories(arg);
    });
  }

  Future<void> updateCategory({
    required String name,
    required CategoryTransactionType type,
    required String icon,
    required int color,
  }) async {
    CategoryTransaction category = ref.read(selectedCategoryProvider)!.copy(
          name: name,
          type: type,
          symbol: icon,
          color: color,
        );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await CategoryTransactionMethods().updateItem(category);
      return _getCategories(arg);
    });
  }

  Future<void> markAsDeleted(int categoryId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteBudgetsByCategoryProvider)(categoryId);
      await CategoryTransactionMethods().markAsDeleted(categoryId);
      return _getCategories(arg);
    });
  }

  final reassignTransactionsProvider =
      Provider<Future<void> Function(int, CategoryTransactionType)>((ref) {
    return (int categoryId, CategoryTransactionType categoryType) async {
      final defaultCategoryId =
          categoryType == CategoryTransactionType.income ? 0 : 1;

      final transactions = await TransactionMethods().selectAll();
      final affectedTransactions =
          transactions.where((t) => t.idCategory == categoryId).toList();

      for (var transaction in affectedTransactions) {
        final updatedTransaction =
            transaction.copy(idCategory: defaultCategoryId);
        await TransactionMethods().updateItem(updatedTransaction);
      }

      ref.invalidate(transactionsProvider);
    };
  });

  final reassignRecurringTransactionsProvider =
      Provider<Future<void> Function(int, CategoryTransactionType)>((ref) {
    return (int categoryId, CategoryTransactionType categoryType) async {
      final defaultCategoryId =
          categoryType == CategoryTransactionType.income ? 0 : 1;

      final recurringTransactions =
          await RecurringTransactionMethods().selectAll();
      final affectedRecurringTransactions = recurringTransactions
          .where((t) => t.idCategory == categoryId)
          .toList();

      for (var recurringTransaction in affectedRecurringTransactions) {
        final updatedTransaction =
            recurringTransaction.copy(idCategory: defaultCategoryId);
        await RecurringTransactionMethods().updateItem(updatedTransaction);
      }

      ref.invalidate(transactionsProvider);
    };
  });

  //final reassignBudgetsProvider =
  //    Provider<Future<void> Function(int, CategoryTransactionType)>((ref) {
  //  return (int categoryId, CategoryTransactionType categoryType) async {
  //    final defaultCategoryId = 1;
//
  //    final budgets =
  //        await BudgetMethods().selectAll();
  //    final affectedBudgets = budgets
  //        .where((t) => t.idCategory == categoryId)
  //        .toList();
//
  //    for (var budget in affectedBudgets) {
  //      final updatedBudget =
  //          budget.copy(idCategory: defaultCategoryId);
  //      await BudgetMethods().updateItem(updatedBudget);
  //    }
//
  //    ref.invalidate(budgetsProvider);
  //  };
  //});

  Future<void> removeCategory(int categoryId) async {
    final category = await CategoryTransactionMethods().selectById(categoryId);

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(reassignTransactionsProvider)(categoryId, category.type);
      await ref.read(reassignRecurringTransactionsProvider)(
          categoryId, category.type);
      await ref.read(deleteBudgetsByCategoryProvider)(categoryId);

      await CategoryTransactionMethods().deleteById(categoryId);
      return _getCategories(arg);
    });
  }

  Future<List<CategoryTransaction>> getCategories() async {
    return _getCategories(arg);
  }
}

final categoriesProvider = AsyncNotifierProviderFamily<AsyncCategoriesNotifier,
    List<CategoryTransaction>, CategoryFilter>(() => AsyncCategoriesNotifier());

final categoriesByTypeProvider =
    FutureProvider.family<List<CategoryTransaction>, CategoryTransactionType?>(
        (ref, type) async {
  List<CategoryTransaction> categories = [];
  if (type != null) {
    categories =
        await CategoryTransactionMethods().selectCategoriesByType(type);
  }
  return categories;
});

final categoryByIdProvider =
    FutureProvider.family<CategoryTransaction, int>((ref, id) async {
  final category = await CategoryTransactionMethods().selectById(id);
  return category;
});

final categoryMapProvider =
    FutureProvider<Map<CategoryTransaction, double>>((ref) async {
  final categoryType = ref.watch(categoryTypeProvider);
  final dateStart = ref.watch(filterDateStartProvider);
  final dateEnd = ref.watch(filterDateEndProvider);

  Map<CategoryTransaction, double> categoriesMap = {};

  final categories =
      await CategoryTransactionMethods().selectCategoriesByType(categoryType);

  final transactionType =
      CategoryTransactionMethods().categoryToTransactionType(categoryType);

  final transactionTypeList = typeMap.entries
      .where((entry) => entry.value == transactionType)
      .map((entry) => entry.key)
      .toList();

  final transactions = await TransactionMethods().selectAll(
    transactionType: transactionTypeList,
    dateRangeStart: dateStart,
    dateRangeEnd: dateEnd,
  );

  if (transactions.isEmpty) {
    return {};
  }

  for (var category in categories) {
    final sum = transactions
        .where((transaction) => transaction.idCategory == category.id)
        .fold(0.0,
            (previousValue, transaction) => previousValue + transaction.amount);

    categoriesMap[category] = categoryType == CategoryTransactionType.income
        ? double.parse(sum.toStringAsFixed(2))
        : -double.parse(sum.toStringAsFixed(2));
  }

  return categoriesMap;
});

final categoryTotalAmountProvider = FutureProvider<double>((ref) async {
  final categoryType = ref.watch(categoryTypeProvider);
  final dateStart = ref.watch(filterDateStartProvider);
  final dateEnd = ref.watch(filterDateEndProvider);
  final transactionType =
      CategoryTransactionMethods().categoryToTransactionType(categoryType);

  List<String> transactionTypeList = typeMap.entries
      .where((entry) => entry.value == transactionType)
      .map((entry) => entry.key)
      .toList();

  final transactions = await TransactionMethods().selectAll(
      transactionType: transactionTypeList,
      dateRangeStart: dateStart,
      dateRangeEnd: dateEnd);

  final totalAmount = transactions.fold<double>(
    0,
    (previousValue, transaction) => previousValue + transaction.amount,
  );

  return categoryType == CategoryTransactionType.income
      ? totalAmount
      : -totalAmount;
});

final transactionToCategoryProvider =
    Provider.family<CategoryTransactionType?, TransactionType>((ref, type) {
  return CategoryTransactionMethods().transactionToCategoryType(type);
});

final categoryToTransactionProvider =
    Provider.family<TransactionType?, CategoryTransactionType>((ref, type) {
  return CategoryTransactionMethods().categoryToTransactionType(type);
});

final monthlyTotalsProvider = FutureProvider<List<double>>((ref) async {
  final categoryType = ref.watch(categoryTypeProvider);
  final dateStart = ref.watch(filterDateStartProvider);
  //final dateEnd = ref.watch(filterDateEndProvider);

  List<double> monthlyTotals = List.generate(12, (_) => 0.0);

  final startOfYear = DateTime(dateStart.year, 1, 1);
  final endOfYear = DateTime(dateStart.year, 12, 31);

  final transactionType =
      CategoryTransactionMethods().categoryToTransactionType(categoryType);

  List<String> transactionTypeList = typeMap.entries
      .where((entry) => entry.value == transactionType)
      .map((entry) => entry.key)
      .toList();
  final transactions = await TransactionMethods().selectAll(
    transactionType: transactionTypeList,
    dateRangeStart: startOfYear,
    dateRangeEnd: endOfYear,
  );

  for (var transaction in transactions) {
    int month = transaction.date.month - 1;
    monthlyTotals[month] += transaction.amount.abs();
  }
  return monthlyTotals;
});
