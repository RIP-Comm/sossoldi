import '../database/sossoldi_database.dart';
import 'base_entity.dart';

const String categoryRecurringTransactionTable = 'categoryRecurringTransaction';

class CategoryRecurringTransactionFields extends BaseEntityFields {
  static String id = 'id';
  static String name = 'name';
  static String symbol = 'symbol'; // Short name
  static String note = 'note';
  static String createdAt = 'createdAt';
  static String updatedAt = 'updatedAt';

  static final List<String> allFields = [
    BaseEntityFields.id,
    name,
    symbol,
    note,
    BaseEntityFields.createdAt,
    BaseEntityFields.updatedAt
  ];
}

class CategoryRecurringTransaction extends BaseEntity {
  final String name;
  final String? symbol;
  final String? note;

  const CategoryRecurringTransaction(
      {int? id,
      required this.name,
      this.symbol,
      this.note,
      DateTime? createdAt,
      DateTime? updatedAt})
      : super(id: id, createdAt: createdAt, updatedAt: updatedAt);

  CategoryRecurringTransaction copy(
          {int? id,
          String? name,
          String? symbol,
          String? note,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      CategoryRecurringTransaction(
          id: id ?? this.id,
          name: name ?? this.name,
          symbol: symbol ?? this.symbol,
          note: note ?? this.note,
          createdAt: createdAt ?? this.createdAt,
          updatedAt: updatedAt ?? this.updatedAt);

  static CategoryRecurringTransaction fromJson(Map<String, Object?> json) =>
      CategoryRecurringTransaction(
          id: json[BaseEntityFields.id] as int?,
          name: json[CategoryRecurringTransactionFields.name] as String,
          symbol: json[CategoryRecurringTransactionFields.symbol] as String,
          note: json[CategoryRecurringTransactionFields.note] as String,
          createdAt: DateTime.parse(json[BaseEntityFields.createdAt] as String),
          updatedAt:
              DateTime.parse(json[BaseEntityFields.updatedAt] as String));

  Map<String, Object?> toJson() => {
        BaseEntityFields.id: id,
        CategoryRecurringTransactionFields.name: name,
        CategoryRecurringTransactionFields.symbol: symbol,
        CategoryRecurringTransactionFields.note: note,
        BaseEntityFields.createdAt: createdAt?.toIso8601String(),
        BaseEntityFields.updatedAt: updatedAt?.toIso8601String(),
      };
}

class CategoryRecurringTransactionMethods extends SossoldiDatabase {
  Future<CategoryRecurringTransaction> insert(CategoryRecurringTransaction item) async {
    final database = await SossoldiDatabase.instance.database;
    final id = await database.insert(categoryRecurringTransactionTable, item.toJson());
    return item.copy(id: id);
  }


  Future<CategoryRecurringTransaction> selectById(int id) async {
    final database = await SossoldiDatabase.instance.database;

    final maps = await database.query(
      categoryRecurringTransactionTable,
      columns: CategoryRecurringTransactionFields.allFields,
      where: '${CategoryRecurringTransactionFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return CategoryRecurringTransaction.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<CategoryRecurringTransaction>> selectAll() async {
    final database = await SossoldiDatabase.instance.database;

    final orderByASC = '${CategoryRecurringTransactionFields.createdAt} ASC';

    // final result = await database.rawQuery('SELECT * FROM $tableExample ORDER BY $orderByASC')
    final result = await database.query(categoryRecurringTransactionTable, orderBy: orderByASC);

    return result.map((json) => CategoryRecurringTransaction.fromJson(json)).toList();
  }

  Future<int> updateItem(CategoryRecurringTransaction item) async {
    final database = await SossoldiDatabase.instance.database;

    // You can use `rawUpdate` to write the query in SQL
    return database.update(
      categoryRecurringTransactionTable,
      item.toJson(),
      where:
      '${CategoryRecurringTransactionFields.id} = ?', // Use `:` if you will not use `sqflite_common_ffi`
      whereArgs: [item.id],
    );
  }

  Future<int> deleteById(int id) async {
    final database = await SossoldiDatabase.instance.database;

    return await database.delete(categoryRecurringTransactionTable,
        where:
        '${CategoryRecurringTransactionFields.id} = ?', // Use `:` if you will not use `sqflite_common_ffi`
        whereArgs: [id]);
  }

}