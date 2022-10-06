import 'package:sossoldi/architecture_sample/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<Iterable<Category>> GetAllCategories();
  Future<int> CreateCategory(Category category);
}
