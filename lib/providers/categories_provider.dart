import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/category_transaction.dart';
import '../model/transaction.dart';
import 'transactions_provider.dart';

final categoryTransactionTypeList = Provider<List<CategoryTransactionType>>(
  (ref) => [CategoryTransactionType.income, CategoryTransactionType.expense],
);

final selectedCategoryProvider =
    StateProvider.autoDispose<CategoryTransaction?>((ref) => null);

final categoryTypeProvider = StateProvider<CategoryTransactionType>(
  (ref) => CategoryTransactionType.expense,
); //default as 'Expense'

class AsyncCategoriesNotifier extends AsyncNotifier<List<CategoryTransaction>> {
  @override
  Future<List<CategoryTransaction>> build() async {
    return _getCategories();
  }

  Future<List<CategoryTransaction>> _getCategories() async {
    final categories = await CategoryTransactionMethods().selectAll();
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
      order: 0,
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await CategoryTransactionMethods().insert(category);
      ref.invalidate(categoriesByTypeProvider(category.type));
      return _getCategories();
    });
  }

  Future<void> updateCategory({
    required String name,
    required CategoryTransactionType type,
    required String icon,
    required int color,
  }) async {
    CategoryTransaction category = ref
        .read(selectedCategoryProvider)!
        .copy(name: name, type: type, symbol: icon, color: color);

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await CategoryTransactionMethods().updateItem(category);
      return _getCategories();
    });
  }

  Future<void> removeCategory(int categoryId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await CategoryTransactionMethods().deleteById(categoryId);
      return _getCategories();
    });
  }

  Future<List<CategoryTransaction>> getCategories() async {
    return _getCategories();
  }

Future<void> reorderCategories(int oldIndex, int newIndex) async {
    final currentList = state.value;
    if (currentList == null) return;

     if (oldIndex < newIndex) {
      newIndex -= 1;
    }

     final newList = List<CategoryTransaction>.from(currentList);
    final item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);

 
    state = AsyncData(newList);

   
    await AsyncValue.guard(() async {
      await CategoryTransactionMethods().updateOrders(newList);
     
    });
  }

}

final categoriesProvider =
    AsyncNotifierProvider<AsyncCategoriesNotifier, List<CategoryTransaction>>(
      () {
        return AsyncCategoriesNotifier();
      },
    );

final categoriesByTypeProvider =
    FutureProvider.family<List<CategoryTransaction>, CategoryTransactionType?>((
      ref,
      type,
    ) async {
      List<CategoryTransaction> categories = [];
      if (type != null) {
        categories = await CategoryTransactionMethods().selectCategoriesByType(
          type,
        );
      }
      return categories;
    });

final categoryMapProvider = FutureProvider<Map<CategoryTransaction, double>>((
  ref,
) async {
  final categoryType = ref.watch(categoryTypeProvider);
  final dateStart = ref.watch(filterDateStartProvider);
  final dateEnd = ref.watch(filterDateEndProvider);

  Map<CategoryTransaction, double> categoriesMap = {};

  final categories = await CategoryTransactionMethods().selectCategoriesByType(
    categoryType,
  );

  final transactionType = CategoryTransactionMethods()
      .categoryToTransactionType(categoryType);

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
        .fold(
          0.0,
          (previousValue, transaction) => previousValue + transaction.amount,
        );

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
  final transactionType = CategoryTransactionMethods()
      .categoryToTransactionType(categoryType);

  List<String> transactionTypeList = typeMap.entries
      .where((entry) => entry.value == transactionType)
      .map((entry) => entry.key)
      .toList();

  final transactions = await TransactionMethods().selectAll(
    transactionType: transactionTypeList,
    dateRangeStart: dateStart,
    dateRangeEnd: dateEnd,
  );

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

  final transactionType = CategoryTransactionMethods()
      .categoryToTransactionType(categoryType);

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
