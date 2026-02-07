import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/category_transaction.dart';
import '../model/transaction.dart';
import '../services/database/repositories/category_repository.dart';
import '../services/database/repositories/transactions_repository.dart';
import 'transactions_provider.dart';

part 'categories_provider.g.dart';

@Riverpod(keepAlive: true)
class SelectedCategory extends _$SelectedCategory {
  @override
  CategoryTransaction? build() => null;

  void setCategory(CategoryTransaction? category) => state = category;
}

@Riverpod(keepAlive: true)
class SelectedSubcategory extends _$SelectedSubcategory {
  @override
  CategoryTransaction? build() => null;

  void setCategory(CategoryTransaction? category) => state = category;
}

@Riverpod(keepAlive: true)
class CategoryType extends _$CategoryType {
  @override
  CategoryTransactionType build() => CategoryTransactionType.expense;

  void setType(CategoryTransactionType type) => state = type;
}

@Riverpod(keepAlive: true)
class Categories extends _$Categories {
  @override
  Future<List<CategoryTransaction>> build() async {
    return _getCategories();
  }

  Future<List<CategoryTransaction>> _getCategories() async {
    final categories = await ref.read(categoryRepositoryProvider).selectAll();
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

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(categoryRepositoryProvider).insert(category);
      ref.invalidate(selectedCategoryProvider);
      ref.invalidate(categoryMapProvider);
      ref.invalidate(categoriesByTypeProvider(category.type));
      return _getCategories();
    });
  }

  Future<void> addSubcategory({
    required String name,
    required String icon,
  }) async {
    final parentCategory = ref.read(selectedCategoryProvider)!;
    CategoryTransaction category = CategoryTransaction(
      name: name,
      symbol: icon,
      type: parentCategory.type,
      color: parentCategory.color,
      order: 0,
      parent: parentCategory.id,
    );

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(categoryRepositoryProvider).insert(category);
      ref.invalidate(selectedSubcategoryProvider);
      ref.invalidate(categoryMapProvider);
      ref.invalidate(categoriesByTypeProvider(category.type));
      ref.invalidate(subcategoriesProvider(parentCategory.id!));
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

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(categoryRepositoryProvider).updateItem(category);
      ref.invalidate(selectedCategoryProvider);
      ref.invalidate(categoryMapProvider);
      return _getCategories();
    });
  }

  Future<void> updateSubcategory({
    required String name,
    required String icon,
  }) async {
    CategoryTransaction category = ref
        .read(selectedSubcategoryProvider)!
        .copy(name: name, symbol: icon);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(categoryRepositoryProvider).updateItem(category);
      ref.invalidate(selectedSubcategoryProvider);
      ref.invalidate(categoryMapProvider);
      ref.invalidate(
        subcategoriesProvider(ref.read(selectedCategoryProvider)!.id!),
      );
      return _getCategories();
    });
  }

  Future<void> removeCategory(int categoryId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(categoryRepositoryProvider).deleteById(categoryId);
      ref.invalidate(selectedSubcategoryProvider);
      ref.invalidate(categoryMapProvider);
      ref.invalidate(
        subcategoriesProvider(ref.read(selectedCategoryProvider)!.id!),
      );
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
      await ref.read(categoryRepositoryProvider).updateOrders(newList);
    });
  }
}

@Riverpod(keepAlive: true)
Future<List<CategoryTransaction>> allParentCategories(Ref ref) async {
  final categories =
      ref
          .watch(categoriesProvider)
          .value
          ?.where((category) => category.parent == null)
          .toList() ??
      [];
  return categories;
}

@Riverpod(keepAlive: true)
Future<List<CategoryTransaction>> categoriesByType(
  Ref ref,
  CategoryTransactionType? type, {
  bool includeSubcategories = false,
}) async {
  List<CategoryTransaction> categories = [];
  if (type != null) {
    categories = await ref
        .read(categoryRepositoryProvider)
        .selectCategoriesByType(
          type,
          includeSubcategories: includeSubcategories,
        );
  }
  return categories;
}

@riverpod
Future<List<CategoryTransaction>> subcategories(Ref ref, int categoryId) async {
  List<CategoryTransaction> categories = [];
  categories = await ref
      .read(categoryRepositoryProvider)
      .selectSubCategory(categoryId);
  return categories;
}

@Riverpod(keepAlive: true)
Future<Map<CategoryTransaction, double>> categoryMap(Ref ref) async {
  final categoryType = ref.watch(categoryTypeProvider);
  final dateStart = ref.watch(filterDateStartProvider);
  final dateEnd = ref.watch(filterDateEndProvider);

  Map<CategoryTransaction, double> categoriesMap = {};

  final categories = await ref
      .read(categoryRepositoryProvider)
      .selectCategoriesByType(categoryType);

  final transactions = await ref
      .read(transactionsRepositoryProvider)
      .selectAll(
        transactionType: [categoryType.transactionType.code],
        dateRangeStart: dateStart,
        dateRangeEnd: dateEnd,
      );

  if (transactions.isEmpty) {
    return {};
  }

  for (var category in categories) {
    final sum = transactions
        .where(
          (transaction) =>
              transaction.idCategory == category.id ||
              transaction.categoryParent == category.id,
        )
        .fold(
          0.0,
          (previousValue, transaction) => previousValue + transaction.amount,
        );

    categoriesMap[category] = categoryType == CategoryTransactionType.income
        ? double.parse(sum.toStringAsFixed(2))
        : -double.parse(sum.toStringAsFixed(2));
  }

  return categoriesMap;
}

@Riverpod(keepAlive: true)
Future<double> categoryTotalAmount(Ref ref) async {
  final categoryType = ref.watch(categoryTypeProvider);
  final dateStart = ref.watch(filterDateStartProvider);
  final dateEnd = ref.watch(filterDateEndProvider);

  final transactions = await ref
      .read(transactionsRepositoryProvider)
      .selectAll(
        transactionType: [categoryType.transactionType.code],
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
}

@Riverpod(keepAlive: true)
Future<List<double>> monthlyTotals(Ref ref) async {
  final categoryType = ref.watch(categoryTypeProvider);
  final dateStart = ref.watch(filterDateStartProvider);
  //final dateEnd = ref.watch(filterDateEndProvider);

  List<double> monthlyTotals = List.generate(12, (_) => 0.0);

  final startOfYear = DateTime(dateStart.year, 1, 1);
  final endOfYear = DateTime(dateStart.year, 12, 31);

  final transactions = await ref
      .read(transactionsRepositoryProvider)
      .selectAll(
        transactionType: [categoryType.transactionType.code],
        dateRangeStart: startOfYear,
        dateRangeEnd: endOfYear,
      );

  for (var transaction in transactions) {
    int month = transaction.date.month - 1;
    monthlyTotals[month] += transaction.amount.abs();
  }
  return monthlyTotals;
}

class ParentCategoryWithSubcategoriesData {
  final CategoryTransaction parentCategory;
  final Map<CategoryTransaction, num> subcategories;
  final List<Transaction> transactions;
  final num total;

  ParentCategoryWithSubcategoriesData({
    required this.parentCategory,
    required this.subcategories,
    required this.transactions,
    required this.total,
  });
}

@Riverpod(keepAlive: true)
Future<List<ParentCategoryWithSubcategoriesData>> categoryWithSubcategoriesData(
  Ref ref,
) async {
  final trnscType = ref.watch(selectedTransactionTypeProvider);
  final categories = ref.watch(categoriesProvider).value ?? [];
  final parentCategories = ref.watch(allParentCategoriesProvider).value ?? [];
  final transactions = ref.watch(transactionsProvider).value ?? [];
  final parentCategoriesByType = parentCategories.where(
    (cat) => cat.type.transactionType == trnscType,
  );

  List<ParentCategoryWithSubcategoriesData> result = [];
  for (var parentCategory in parentCategoriesByType) {
    Map<CategoryTransaction, num> subcategoryMap = {};
    num total = 0;
    List<Transaction> categoryTransactions = [];
    final parentTransactions = transactions.where(
      (trnsc) => trnsc.idCategory == parentCategory.id,
    );
    categoryTransactions.addAll(parentTransactions);
    total += parentTransactions.fold(
      0,
      (previousValue, trnsc) => previousValue + trnsc.amount,
    );
    final subcategories = categories.where(
      (cat) => cat.parent == parentCategory.id,
    );
    for (var subcategory in subcategories) {
      final subcategoryTransactions = transactions.where(
        (trnsc) => trnsc.idCategory == subcategory.id,
      );
      num subcategoryTotal = subcategoryTransactions.fold(
        0,
        (previousValue, trnsc) => previousValue + trnsc.amount,
      );
      if (subcategoryTotal != 0) {
        subcategoryMap[subcategory] = trnscType == TransactionType.expense
            ? -subcategoryTotal
            : subcategoryTotal;
        total += subcategoryTotal;
        categoryTransactions.addAll(subcategoryTransactions);
      }
    }
    if (total != 0) {
      result.add(
        ParentCategoryWithSubcategoriesData(
          parentCategory: parentCategory,
          subcategories: subcategoryMap,
          transactions: categoryTransactions,
          total: trnscType == TransactionType.expense ? -total : total,
        ),
      );
    }
  }

  return result;
}
