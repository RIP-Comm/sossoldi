import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../model/category_transaction.dart';
import '../sossoldi_database.dart';

part 'category_repository.g.dart';

@riverpod
CategoryRepository categoryRepository(Ref ref) {
  return CategoryRepository(database: ref.watch(databaseProvider));
}

class CategoryRepository {
  CategoryRepository({required SossoldiDatabase database})
    : _sossoldiDB = database;

  final SossoldiDatabase _sossoldiDB;

  final orderByASC = '"${CategoryTransactionFields.order}" ASC';

  Future<CategoryTransaction> insert(CategoryTransaction item) async {
    final db = await _sossoldiDB.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM $categoryTransactionTable',
    );
    final nextOrder = result.first['count'] as int;

    final newItem = item.copy(order: nextOrder);

    final id = await db.insert(categoryTransactionTable, newItem.toJson());
    return newItem.copy(id: id);
  }

  Future<CategoryTransaction> selectById(int id) async {
    final db = await _sossoldiDB.database;

    final maps = await db.query(
      categoryTransactionTable,
      columns: CategoryTransactionFields.allFields,
      where: '${CategoryTransactionFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return CategoryTransaction.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<CategoryTransaction>> selectAll() async {
    final db = await _sossoldiDB.database;

    final result = await db.query(
      categoryTransactionTable,
      orderBy: orderByASC,
    );

    return result.map((json) => CategoryTransaction.fromJson(json)).toList();
  }

  Future<List<CategoryTransaction>> selectCategoriesByType(
    CategoryTransactionType type,
  ) async {
    final db = await _sossoldiDB.database;

    final result = await db.query(
      categoryTransactionTable,
      columns: CategoryTransactionFields.allFields,
      where: '${CategoryTransactionFields.type} = ?',
      whereArgs: [type.code],
      orderBy: orderByASC,
    );

    if (result.isNotEmpty) {
      return result.map((json) => CategoryTransaction.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  Future<int> updateItem(CategoryTransaction item) async {
    final db = await _sossoldiDB.database;

    // You can use `rawUpdate` to write the query in SQL
    return db.update(
      categoryTransactionTable,
      item.toJson(update: true),
      where: '${CategoryTransactionFields.id} = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteById(int id) async {
    final db = await _sossoldiDB.database;

    final rows = await db.delete(
      categoryTransactionTable,
      where: '${CategoryTransactionFields.id} = ?',
      whereArgs: [id],
    );
    await normalizeOrders();
    return rows;
  }

  Future<void> updateOrders(List<CategoryTransaction> items) async {
    final db = await _sossoldiDB.database;

    await db.transaction((txn) async {
      for (int i = 0; i < items.length; i++) {
        await txn.update(
          categoryTransactionTable,
          {CategoryTransactionFields.order: i},
          where: '${CategoryTransactionFields.id} = ?',
          whereArgs: [items[i].id],
        );
      }
    });
  }

  Future<void> normalizeOrders() async {
    final db = await _sossoldiDB.database;

    final result = await db.query(
      categoryTransactionTable,
      columns: [CategoryTransactionFields.id],
      orderBy: orderByASC,
    );

    for (int i = 0; i < result.length; i++) {
      await db.update(
        categoryTransactionTable,
        {CategoryTransactionFields.order: i},
        where: '${CategoryTransactionFields.id} = ?',
        whereArgs: [result[i][CategoryTransactionFields.id]],
      );
    }
  }
}
