import '../database/sossoldi_database.dart';
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
  static String markedAsDeleted = 'markedAsDeleted';
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
    markedAsDeleted,
    BaseEntityFields.createdAt,
    BaseEntityFields.updatedAt
  ];
}

class CategoryFilter {
  final bool showSystemCategories;
  final bool showDeletedCategories;

  const CategoryFilter({
    this.showSystemCategories = false,
    this.showDeletedCategories = false,
  });

  //Avoid useless Riverpod recostructions
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryFilter &&
        other.showSystemCategories == showSystemCategories &&
        other.showDeletedCategories == showDeletedCategories;
  }

  @override
  int get hashCode =>
      showSystemCategories.hashCode ^ showDeletedCategories.hashCode;
}

const userCategoriesFilter = CategoryFilter(
  showSystemCategories: false,
  showDeletedCategories: false,
);

const availableCategoriesFilter = CategoryFilter(
  showSystemCategories: true,
  showDeletedCategories: false,
);
const allCategoriesFilter = CategoryFilter(
  showSystemCategories: true,
  showDeletedCategories: true,
);

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
  final bool markedAsDeleted;

  const CategoryTransaction({
    super.id,
    required this.name,
    required this.type,
    required this.symbol,
    required this.color,
    this.note,
    this.parent,
    required this.markedAsDeleted,
    super.createdAt,
    super.updatedAt,
  });

  CategoryTransaction copy(
          {int? id,
          String? name,
          CategoryTransactionType? type,
          String? symbol,
          int? color,
          String? note,
          int? parent,
          bool? markedAsDeleted,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      CategoryTransaction(
          id: id ?? this.id,
          name: name ?? this.name,
          type: type ?? this.type,
          symbol: symbol ?? this.symbol,
          color: color ?? this.color,
          note: note ?? this.note,
          parent: parent ?? this.parent,
          markedAsDeleted: markedAsDeleted ?? this.markedAsDeleted,
          createdAt: createdAt ?? this.createdAt,
          updatedAt: updatedAt ?? this.updatedAt);

  static CategoryTransaction fromJson(Map<String, Object?> json) =>
      CategoryTransaction(
          id: json[BaseEntityFields.id] as int?,
          name: json[CategoryTransactionFields.name] as String,
          type:
              categoryTypeMap[json[CategoryTransactionFields.type] as String]!,
          symbol: json[CategoryTransactionFields.symbol] as String,
          color: json[CategoryTransactionFields.color] as int,
          note: json[CategoryTransactionFields.note] as String?,
          parent: json[CategoryTransactionFields.parent] as int?,
          markedAsDeleted: json[CategoryTransactionFields.markedAsDeleted] == 1
              ? true
              : false,
          createdAt: DateTime.parse(json[BaseEntityFields.createdAt] as String),
          updatedAt:
              DateTime.parse(json[BaseEntityFields.updatedAt] as String));

  Map<String, Object?> toJson({bool update = false}) => {
        BaseEntityFields.id: id,
        CategoryTransactionFields.name: name,
        CategoryTransactionFields.type:
            categoryTypeMap.keys.firstWhere((k) => categoryTypeMap[k] == type),
        CategoryTransactionFields.symbol: symbol,
        CategoryTransactionFields.color: color,
        CategoryTransactionFields.note: note,
        CategoryTransactionFields.parent: parent,
        CategoryTransactionFields.markedAsDeleted: markedAsDeleted ? 1 : 0,
        BaseEntityFields.createdAt: update
            ? createdAt?.toIso8601String()
            : DateTime.now().toIso8601String(),
        BaseEntityFields.updatedAt: DateTime.now().toIso8601String(),
      };
}

class CategoryTransactionMethods extends SossoldiDatabase {
  final orderByASC = '${CategoryTransactionFields.createdAt} ASC';

  Future<CategoryTransaction> insert(CategoryTransaction item) async {
    final db = await database;
    final id = await db.insert(categoryTransactionTable, item.toJson());
    return item.copy(id: id);
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

    final result =
        await db.query(categoryTransactionTable, orderBy: orderByASC);

    return result.map((json) => CategoryTransaction.fromJson(json)).toList();
  }

  Future<List<CategoryTransaction>> selectCategories(
      CategoryFilter filter) async {
    final db = await database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    // showSystemCategories == false => no uncategorized
    if (!filter.showSystemCategories) {
      whereClause =
          '${CategoryTransactionFields.id} != ? AND ${CategoryTransactionFields.id} != ?';
      whereArgs = [0, 1];
    }

    // showDeletedCategories == false => no markedAsDeleted
    if (!filter.showDeletedCategories) {
      if (whereClause.isNotEmpty) {
        whereClause += ' AND ';
      }
      whereClause += '${CategoryTransactionFields.markedAsDeleted} = ?';
      whereArgs.add(0);
    }

    final result = await db.query(
      categoryTransactionTable,
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: orderByASC,
    );

    return result.map((json) => CategoryTransaction.fromJson(json)).toList();
  }

  Future<List<CategoryTransaction>> selectCategoriesByType(
      CategoryTransactionType type) async {
    final db = await database;

    var key =
        categoryTypeMap.entries.firstWhere((entry) => entry.value == type).key;

    final result = await db.query(categoryTransactionTable,
        columns: CategoryTransactionFields.allFields,
        where: '${CategoryTransactionFields.type} = ?',
        whereArgs: [key],
        orderBy: orderByASC);

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

  Future<int> markAsDeleted(int id) async {
    final db = await database;

    return await db.update(
      categoryTransactionTable,
      {CategoryTransactionFields.markedAsDeleted: 1},
      where: '${CategoryTransactionFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteById(int id) async {
    final db = await database;

    return await db.delete(categoryTransactionTable,
        where: '${CategoryTransactionFields.id} = ?', whereArgs: [id]);
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
}
