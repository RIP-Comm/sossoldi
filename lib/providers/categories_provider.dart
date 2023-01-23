import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/category_transaction.dart';


class AsyncCategoriesNotifier extends AsyncNotifier<List<CategoryTransaction>> {
  @override
  Future<List<CategoryTransaction>> build() async {
    return _getCategories();
  }

  Future<List<CategoryTransaction>> _getCategories() async {
    final categories = await CategoryTransactionMethods().selectAll();
    return categories;
  }

  Future<void> addCategory(CategoryTransaction category) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await CategoryTransactionMethods().insert(category);
      return _getCategories();
    });
  }

  Future<void> updateCategory(CategoryTransaction category) async {
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
}

final categoriesProvider = AsyncNotifierProvider<AsyncCategoriesNotifier, List<CategoryTransaction>>(() {
  return AsyncCategoriesNotifier();
});
