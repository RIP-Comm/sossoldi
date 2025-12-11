import '../services/database/sossoldi_database.dart';
import 'base_entity.dart';
import 'transaction.dart';

const String categoryTransactionTable = 'categoryTransaction';

class CategoryTransactionFields extends BaseEntityFields {
  static String id = BaseEntityFields.getId;
  static String name = 'name';
  static String type = 'type';
  static String symbol = 'symbol';
  static String color = 'color';
  static String note = 'note';
  static String parent = 'parent';
  static String order = 'position';
  static String createdAt = BaseEntityFields.getCreatedAt;
  static String updatedAt = BaseEntityFields.getUpdatedAt;

  static final List<String> allFields = [
    BaseEntityFields.id,
    name,
    type,
    symbol,
    color,
    note,
    parent,
    order,
    BaseEntityFields.createdAt,
    BaseEntityFields.updatedAt,
  ];
}

enum CategoryTransactionType { income, expense }

Map<String, CategoryTransactionType> categoryTypeMap = {
  "IN": CategoryTransactionType.income,
  "OUT": CategoryTransactionType.expense,
};

class CategoryTransaction extends BaseEntity {
  final String name;
  final CategoryTransactionType type;
  final String symbol;
  final int color;
  final String? note;
  final int? parent;
  final int? order;

  const CategoryTransaction({
    super.id,
    required this.name,
    required this.type,
    required this.symbol,
    required this.color,
    this.note,
    this.parent,
    required this.order,
    super.createdAt,
    super.updatedAt,
  });

  CategoryTransaction copy({
    int? id,
    String? name,
    CategoryTransactionType? type,
    String? symbol,
    int? color,
    String? note,
    int? parent,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CategoryTransaction(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    symbol: symbol ?? this.symbol,
    color: color ?? this.color,
    note: note ?? this.note,
    parent: parent ?? this.parent,
    order: order ?? this.order,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  static CategoryTransaction fromJson(Map<String, Object?> json) =>
      CategoryTransaction(
        id: json[BaseEntityFields.id] as int?,
        name: json[CategoryTransactionFields.name] as String,
        type: categoryTypeMap[json[CategoryTransactionFields.type] as String]!,
        symbol: json[CategoryTransactionFields.symbol] as String,
        color: json[CategoryTransactionFields.color] as int,
        note: json[CategoryTransactionFields.note] as String?,
        parent: json[CategoryTransactionFields.parent] as int?,
        order: json[CategoryTransactionFields.order] as int,
        createdAt: DateTime.parse(json[BaseEntityFields.createdAt] as String),
        updatedAt: DateTime.parse(json[BaseEntityFields.updatedAt] as String),
      );

  Map<String, Object?> toJson({bool update = false}) => {
    BaseEntityFields.id: id,
    CategoryTransactionFields.name: name,
    CategoryTransactionFields.type: categoryTypeMap.keys.firstWhere(
      (k) => categoryTypeMap[k] == type,
    ),
    CategoryTransactionFields.symbol: symbol,
    CategoryTransactionFields.color: color,
    CategoryTransactionFields.note: note,
    CategoryTransactionFields.parent: parent,
    CategoryTransactionFields.order: order,
    BaseEntityFields.createdAt: update
        ? createdAt?.toIso8601String()
        : DateTime.now().toIso8601String(),
    BaseEntityFields.updatedAt: DateTime.now().toIso8601String(),
  };
}

class CategoryTransactionMethods extends SossoldiDatabase {
  final orderByASC = '"${CategoryTransactionFields.order}" ASC';

  Future<CategoryTransaction> insert(CategoryTransaction item) async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM $categoryTransactionTable',
    );
    final nextOrder = result.first['count'] as int;

    final newItem = item.copy(order: nextOrder);

    final id = await db.insert(categoryTransactionTable, newItem.toJson());
    return newItem.copy(id: id);
  }

  Future<CategoryTransaction> selectById(int id) async {
    final db = await database;

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
    final db = await database;

    final result = await db.query(
      categoryTransactionTable,
      orderBy: orderByASC,
    );

    return result.map((json) => CategoryTransaction.fromJson(json)).toList();
  }

  Future<List<CategoryTransaction>> selectCategoriesByType(
    CategoryTransactionType type,
  ) async {
    final db = await database;

    var key = categoryTypeMap.entries
        .firstWhere((entry) => entry.value == type)
        .key;

    final result = await db.query(
      categoryTransactionTable,
      columns: CategoryTransactionFields.allFields,
      where: '${CategoryTransactionFields.type} = ?',
      whereArgs: [key],
      orderBy: orderByASC,
    );

    if (result.isNotEmpty) {
      return result.map((json) => CategoryTransaction.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  Future<int> updateItem(CategoryTransaction item) async {
    final db = await database;

    // You can use `rawUpdate` to write the query in SQL
    return db.update(
      categoryTransactionTable,
      item.toJson(update: true),
      where: '${CategoryTransactionFields.id} = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteById(int id) async {
    final db = await database;

    final rows = await db.delete(
      categoryTransactionTable,
      where: '${CategoryTransactionFields.id} = ?',
      whereArgs: [id],
    );
    await normalizeOrders();
    return rows;
  }

  Future<void> updateOrders(List<CategoryTransaction> items) async {
    final db = await database;

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

  CategoryTransactionType? transactionToCategoryType(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return CategoryTransactionType.income;
      case TransactionType.expense:
        return CategoryTransactionType.expense;
      case TransactionType.transfer:
        return null;
    }
  }

  TransactionType categoryToTransactionType(CategoryTransactionType type) {
    switch (type) {
      case CategoryTransactionType.income:
        return TransactionType.income;
      case CategoryTransactionType.expense:
        return TransactionType.expense;
    }
  }

  Future<void> normalizeOrders() async {
    final db = await database;

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
