import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/constants.dart';
import '../model/category_transaction.dart';

final categoryTransactionTypeList = Provider<List<CategoryTransactionType>>(
    (ref) => [CategoryTransactionType.income, CategoryTransactionType.expense]);

final selectedCategoryProvider =
    StateProvider<CategoryTransaction?>((ref) => null);

final categoryTypeProvider = StateProvider<CategoryTransactionType>(
    (ref) => CategoryTransactionType.income); //default as 'Income'

final categoryIconProvider =
    StateProvider<String>((ref) => iconList.keys.first);

final categoryColorProvider = StateProvider<int>((ref) => 0);

class AsyncCategoriesNotifier extends AsyncNotifier<List<CategoryTransaction>> {
  @override
  Future<List<CategoryTransaction>> build() async {
    return _getCategories();
  }

  Future<List<CategoryTransaction>> _getCategories() async {
    final categories = await CategoryTransactionMethods().selectAll();
    return categories;
  }

  Future<void> addCategory(String name) async {
    CategoryTransaction category = CategoryTransaction(
      name: name,
      symbol: ref.read(categoryIconProvider),
      type: ref.read(categoryTypeProvider),
      color: ref.read(categoryColorProvider),
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await CategoryTransactionMethods().insert(category);
      return _getCategories();
    });
  }

  Future<void> updateCategory(String name) async {
    CategoryTransaction category = ref.read(selectedCategoryProvider)!.copy(
          name: name,
          symbol: ref.read(categoryIconProvider),
          type: ref.read(categoryTypeProvider),
          color: ref.read(categoryColorProvider),
        );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await CategoryTransactionMethods().updateItem(category);
      return _getCategories();
    });
  }

  void selectedCategory(CategoryTransaction category) {
    ref.read(selectedCategoryProvider.notifier).state = category;
    ref.read(categoryIconProvider.notifier).state = category.symbol;
    ref.read(categoryTypeProvider.notifier).state = category.type;
    ref.read(categoryColorProvider.notifier).state = category.color;
  }

  Future<void> removeCategory(int categoryId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await CategoryTransactionMethods().deleteById(categoryId);
      return _getCategories();
    });
  }

  void reset() {
    ref.invalidate(selectedCategoryProvider);
    ref.invalidate(categoryIconProvider);
    ref.invalidate(categoryTypeProvider);
    ref.invalidate(categoryColorProvider);
  }

  Future<List<CategoryTransaction>> getCategories() async {
    return _getCategories();
  }
}

class AsyncCategoriesByTypeNotifier extends FamilyAsyncNotifier<
    List<CategoryTransaction>, CategoryTransactionType?> {
  @override
  Future<List<CategoryTransaction>> build(CategoryTransactionType? arg) {
    return _getCategoriesByType(arg!);
  }

  Future<List<CategoryTransaction>> _getCategoriesByType(
      CategoryTransactionType type) async {
    final categories =
        await CategoryTransactionMethods().selectCategoriesByType(type);
    return categories;
  }
}

final categoriesProvider =
    AsyncNotifierProvider<AsyncCategoriesNotifier, List<CategoryTransaction>>(
        () {
  return AsyncCategoriesNotifier();
});

final categoriesByTypeProvider = AsyncNotifierProviderFamily<
    AsyncCategoriesByTypeNotifier,
    List<CategoryTransaction>,
    CategoryTransactionType?>(() {
  return AsyncCategoriesByTypeNotifier();
});

final categoryMapProvider = FutureProvider.family<
    Map<CategoryTransaction, double>,
    CategoryTransactionType>((ref, type) async {
  return CategoryTransactionMethods().mapCategoriesWithAmountByType(type);
});

final categoryAmountProvider =
    FutureProvider.family<double, CategoryTransactionType>((ref, type) async {
  return CategoryTransactionMethods().getTotalAmountByType(type);
});

final selectedCategoryIndexProvider =
    StateProvider.autoDispose<int>((ref) => -1);
