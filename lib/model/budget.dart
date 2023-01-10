import '../database/sossoldi_database.dart';
import 'base_entity.dart';

const String budgetTable = 'budget';

class BudgetFields extends BaseEntityFields {
  static String id = 'id';
  static String name = 'name';
  static String amountLimit = 'amountLimit';
  static String createdAt = 'createdAt';
  static String updatedAt = 'updatedAt';

  static final List<String> allFields = [
    BaseEntityFields.id,
    name,
    amountLimit,
    BaseEntityFields.createdAt,
    BaseEntityFields.updatedAt
  ];
}

class Budget extends BaseEntity {
  final String name;
  final num amountLimit;

  const Budget(
      {int? id,
      required this.name,
      required this.amountLimit,
      DateTime? createdAt,
      DateTime? updatedAt})
      : super(id: id, createdAt: createdAt, updatedAt: updatedAt);

  Budget copy(
          {int? id,
          String? name,
          num? amountLimit,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Budget(
          id: id ?? this.id,
          name: name ?? this.name,
          amountLimit: amountLimit ?? this.amountLimit,
          createdAt: createdAt ?? this.createdAt,
          updatedAt: updatedAt ?? this.updatedAt);

  static Budget fromJson(Map<String, Object?> json) => Budget(
      id: json[BaseEntityFields.id] as int?,
      name: json[BudgetFields.name] as String,
      amountLimit: json[BudgetFields.amountLimit] as num,
      createdAt: DateTime.parse(json[BaseEntityFields.createdAt] as String),
      updatedAt: DateTime.parse(json[BaseEntityFields.updatedAt] as String));

  Map<String, Object?> toJson() => {
        BaseEntityFields.id: id,
        BudgetFields.name: name,
        BudgetFields.amountLimit: amountLimit,
        BaseEntityFields.createdAt: createdAt?.toIso8601String(),
        BaseEntityFields.updatedAt: updatedAt?.toIso8601String(),
      };
}

class BudgetMethods extends SossoldiDatabase {
  Future<Budget> insert(Budget item) async {
    final database = await SossoldiDatabase.instance.database;
    final id = await database.insert(budgetTable, item.toJson());
    return item.copy(id: id);
  }


  Future<Budget> selectById(int id) async {
    final database = await SossoldiDatabase.instance.database;

    final maps = await database.query(
      budgetTable,
      columns: BudgetFields.allFields,
      where: '${BudgetFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Budget.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
      // reutrn null;
    }
  }

  Future<List<Budget>> selectAll() async {
    final database = await SossoldiDatabase.instance.database;

    final orderByASC = '${BudgetFields.createdAt} ASC';

    // final result = await database.rawQuery('SELECT * FROM $tableExample ORDER BY $orderByASC')
    final result = await database.query(budgetTable, orderBy: orderByASC);

    return result.map((json) => Budget.fromJson(json)).toList();
  }

  Future<int> updateItem(Budget item) async {
    final database = await SossoldiDatabase.instance.database;

    // You can use `rawUpdate` to write the query in SQL
    return database.update(
      budgetTable,
      item.toJson(),
      where:
      '${BudgetFields.id} = ?', // Use `:` if you will not use `sqflite_common_ffi`
      whereArgs: [item.id],
    );
  }

  Future<int> deleteById(int id) async {
    final database = await SossoldiDatabase.instance.database;

    return await database.delete(budgetTable,
        where:
        '${BudgetFields.id} = ?', // Use `:` if you will not use `sqflite_common_ffi`
        whereArgs: [id]);
  }

}