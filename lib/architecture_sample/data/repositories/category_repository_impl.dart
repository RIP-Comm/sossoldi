import 'package:sossoldi/architecture_sample/data/db/local_db.dart';
import 'package:sossoldi/architecture_sample/domain/entities/category.dart';
import 'package:sossoldi/architecture_sample/domain/interfaces/repositories/category_repository.dart';
import 'package:sqflite/sqlite_api.dart';

import '../models/category_model.dart';

class CategoryRepositoryImpl extends CategoryRepository {
  late LocalDb localDb;

  CategoryRepositoryImpl() {
    localDb = LocalDb.instance;
  }

  @override
  Future<Iterable<Category>> GetAllCategories() async {
    var dbconnection = await localDb.database;
    const orderByASC = '${CategoryFields.name} ASC';

    final result = await dbconnection.query(tableCategory, orderBy: orderByASC);

    var categories = result
        .map((json) => CategoryModel.fromJson(json))
        .map((catModel) => Category(id: catModel.id, name: catModel.name))
        .toList();
    await dbconnection.close();
    return categories;
  }

  @override
  Future<int> CreateCategory(Category category) async {
    var categoryModel = CategoryModel(
        id: category.id ?? 0,
        name: category.name,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now());

    var dbconnection = await localDb.database;
    int id = await dbconnection.insert(tableCategory, categoryModel.toJson());
    await dbconnection.close();
    return id;
  }
}
