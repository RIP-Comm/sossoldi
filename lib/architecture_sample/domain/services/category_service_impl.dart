import 'package:sossoldi/architecture_sample/domain/interfaces/repositories/category_repository.dart';

import '../entities/category.dart';
import '../interfaces/services/category_service.dart';

class CategoryServiceImpl extends CategoryService {
  final CategoryRepository _categoryRepo;

  CategoryServiceImpl(this._categoryRepo);

  Future<Iterable<Category>> GetAllCategories() async =>
      _categoryRepo.GetAllCategories();

  @override
  Future<int> CreateCategory(Category category) async {
    return await _categoryRepo.CreateCategory(category);
  }
}
