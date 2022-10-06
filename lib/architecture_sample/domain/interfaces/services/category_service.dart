import '../../entities/category.dart';

// referenced in Presentation Layer
abstract class CategoryService {
  Future<Iterable<Category>> GetAllCategories();
  Future<int> CreateCategory(Category category);
}
