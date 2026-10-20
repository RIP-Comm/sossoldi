import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../model/category_transaction.dart';
import '../../../model/transaction.dart';
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

  Future<List<CategoryTransaction>> selectAllParent() async {
    final db = await _sossoldiDB.database;

    final result = await db.query(
      categoryTransactionTable,
      where:
          '${CategoryTransactionFields.parent} IS NULL AND ${CategoryTransactionFields.deletedAt} IS NULL',
      orderBy: orderByASC,
    );

    return result.map((json) => CategoryTransaction.fromJson(json)).toList();
  }

  Future<List<CategoryTransaction>> selectSubCategory(int categoryId) async {
    final db = await _sossoldiDB.database;

    final result = await db.query(
      categoryTransactionTable,
      where:
          '${CategoryTransactionFields.parent} = ? AND ${CategoryTransactionFields.deletedAt} IS NULL',
      whereArgs: [categoryId],
      orderBy: orderByASC,
    );

    return result.map((json) => CategoryTransaction.fromJson(json)).toList();
  }

  Future<List<CategoryTransaction>> selectCategoriesByType(
    CategoryTransactionType type, {
    bool includeSubcategories = false,
  }) async {
    final db = await _sossoldiDB.database;

    final typePlaceholders = List.filled(
      type.selectableCodes.length,
      '?',
    ).join(', ');
    String where =
        '${CategoryTransactionFields.type} IN ($typePlaceholders) AND ${CategoryTransactionFields.deletedAt} IS NULL';
    List<dynamic> args = type.selectableCodes;
    if (!includeSubcategories) {
      where += ' AND ${CategoryTransactionFields.parent} IS NULL';
    }

    final result = await db.query(
      categoryTransactionTable,
      columns: CategoryTransactionFields.allFields,
      where: where,
      whereArgs: args,
      orderBy: orderByASC,
    );

    if (result.isNotEmpty) {
      return result.map((json) => CategoryTransaction.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  Future<List<CategoryTransaction>> selectFrequentCategories(
    CategoryTransactionType type,
  ) async {
    final db = await _sossoldiDB.database;
    final transactionTypeCodes = type.transactionTypes
        .map((transactionType) => transactionType.code)
        .toList();
    final transactionTypePlaceholders = List.filled(
      transactionTypeCodes.length,
      '?',
    ).join(', ');
    final categoryTypePlaceholders = List.filled(
      type.selectableCodes.length,
      '?',
    ).join(', ');
    // Select the last 100 transactions, group by category and return the
    // top 5 most used categories ordered by usage count desc.
    final result = await db.rawQuery(
      '''
        SELECT c.*
        FROM "$categoryTransactionTable" c
        JOIN (
          SELECT * FROM "$transactionTable"
          WHERE "${TransactionFields.type}" IN ($transactionTypePlaceholders)
          ORDER BY "${TransactionFields.date}" DESC
          LIMIT 100
        ) t ON t."${TransactionFields.idCategory}" = c."${CategoryTransactionFields.id}"
        WHERE c."${CategoryTransactionFields.type}" IN ($categoryTypePlaceholders) AND c.${CategoryTransactionFields.deletedAt} IS NULL
        GROUP BY c."${CategoryTransactionFields.id}"
        ORDER BY COUNT(t."${TransactionFields.id}") DESC
        LIMIT 5
      ''',
      [...transactionTypeCodes, ...type.selectableCodes],
    );

    return result.map((json) => CategoryTransaction.fromJson(json)).toList();
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

  Future<void> updateSubcategories(
    int parentId,
    int color,
    CategoryTransactionType type,
  ) async {
    final db = await _sossoldiDB.database;

    await db.update(
      categoryTransactionTable,
      {
        CategoryTransactionFields.color: color,
        CategoryTransactionFields.type: type.code,
      },
      where: '${CategoryTransactionFields.parent} = ?',
      whereArgs: [parentId],
    );
  }

  Future<void> deleteById(CategoryTransaction item) async {
    final db = await _sossoldiDB.database;

    await db.update(
      categoryTransactionTable,
      item.toJson(delete: true),
      where: '${CategoryTransactionFields.id} = ?',
      whereArgs: [item.id],
    );

    if (item.parent == null) {
      await db
          .query(
            categoryTransactionTable,
            where:
                '${CategoryTransactionFields.parent} = ? AND ${CategoryTransactionFields.deletedAt} IS NULL',
            whereArgs: [item.id],
          )
          .then((subcategories) async {
            for (final subcategory in subcategories) {
              await deleteById(CategoryTransaction.fromJson(subcategory));
            }
          });
      await normalizeOrders();
    }
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
      where: '${CategoryTransactionFields.deletedAt} IS NULL',
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
