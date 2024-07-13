import '../model/transaction.dart';
import '../database/sossoldi_database.dart';
import '../model/category_transaction.dart';
import 'base_entity.dart';

const String budgetTable = 'budget';

class BudgetFields extends BaseEntityFields {
  static String id = BaseEntityFields.getId;
  static String name = 'name';
  static String idCategory = 'idCategory'; // FK
  static String amountLimit = 'amountLimit';
  static String active = 'active';
  static String createdAt = BaseEntityFields.getCreatedAt;
  static String updatedAt = BaseEntityFields.getUpdatedAt;

  static final List<String> allFields = [
    BaseEntityFields.id,
    idCategory,
    name,
    amountLimit,
    active,
    BaseEntityFields.createdAt,
    BaseEntityFields.updatedAt
  ];
}

class Budget extends BaseEntity {
  final int idCategory;
  final String? name;
  final num amountLimit;
  final bool active;

  const Budget(
      {int? id,
      required this.idCategory,
      this.name,
      required this.amountLimit,
      required this.active,
      DateTime? createdAt,
      DateTime? updatedAt})
      : super(id: id, createdAt: createdAt, updatedAt: updatedAt);

  Budget copy(
          {int? id,
          int? idCategory,
          String? name,
          num? amountLimit,
          bool? active,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Budget(
          id: id ?? this.id,
          idCategory: idCategory ?? this.idCategory,
          name: name ?? this.name,
          amountLimit: amountLimit ?? this.amountLimit,
          active: active ?? this.active,
          createdAt: createdAt ?? this.createdAt,
          updatedAt: updatedAt ?? this.updatedAt);

  static Budget fromJson(Map<String, Object?> json) => Budget(
      id: json[BaseEntityFields.id] as int,
      idCategory: json[BudgetFields.idCategory] as int,
      name: json[BudgetFields.name] as String?,
      amountLimit: json[BudgetFields.amountLimit] as num,
      active: json[BudgetFields.active] == 1 ? true : false,
      createdAt: DateTime.parse(json[BaseEntityFields.createdAt] as String),
      updatedAt: DateTime.parse(json[BaseEntityFields.updatedAt] as String));

  Map<String, Object?> toJson({bool update = false}) => {
        BaseEntityFields.id: id,
        BudgetFields.idCategory: idCategory,
        BudgetFields.name: name,
        BudgetFields.amountLimit: amountLimit,
        BudgetFields.active: active ? 1 : 0,
        BaseEntityFields.createdAt:
            update ? createdAt?.toIso8601String() : DateTime.now().toIso8601String(),
        BaseEntityFields.updatedAt: DateTime.now().toIso8601String(),
      };
}

class BudgetStats extends BaseEntity {
  final int idCategory;
  final String? name;
  final num amountLimit;
  final num spent;

  BudgetStats({required this.idCategory, required this.name, required this.amountLimit, required this.spent});

  static BudgetStats fromJson(Map<String, Object?> json) => BudgetStats(
      idCategory: json[BudgetFields.idCategory] as int,
      name: json[BudgetFields.name] as String?,
      amountLimit: json[BudgetFields.amountLimit] as num, 
      spent: json['spent'] as num);

  Map<String, Object?> toJson() => {
        BudgetFields.idCategory: idCategory,
        BudgetFields.name: name,
        BudgetFields.amountLimit: amountLimit,
        'spent': spent
      };
}

class BudgetMethods extends SossoldiDatabase {
  Future<Budget> insert(Budget item) async {
    final db = await database;
    final id = await db.insert(budgetTable, item.toJson());
    return item.copy(id: id);
  }

  Future<Budget> insertOrUpdate(Budget item) async {
    final db = await database;

    final exists = await checkIfExists(item);
    if (exists) {
      await db.rawQuery("UPDATE $budgetTable SET amountLimit = ${item.amountLimit} WHERE idCategory = ${item.idCategory}");
    } else {
      await db.insert(budgetTable, item.toJson());
    }

    return item.copy(id: item.id);
  }

  Future<bool> checkIfExists(Budget item) async {
    final db = await database;

    try {
      final exists = await db.rawQuery("SELECT * FROM ${budgetTable} WHERE ${item.idCategory} = idCategory");
      if(exists.isNotEmpty) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Budget> selectById(int id) async {
    final db = await database;

    final maps = await db.query(
      budgetTable,
      columns: BudgetFields.allFields,
      where: '${BudgetFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Budget.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Budget>> selectAll() async {
    final db = await database;
    final orderByASC = '${BudgetFields.createdAt} ASC';
    final result = await db.rawQuery(
        'SELECT bt.*, ct.name FROM $budgetTable as bt LEFT JOIN $categoryTransactionTable as ct ON bt.${BudgetFields.idCategory} = ct.${CategoryTransactionFields.id} ORDER BY $orderByASC');
    return result.map((json) => Budget.fromJson(json)).toList();
  }

  Future<List<Budget>> selectAllActive() async {
    final db = await database;
    final orderByASC = '${BudgetFields.createdAt} ASC';
    final result = await db.rawQuery(
        'SELECT bt.*, ct.name FROM $budgetTable as bt LEFT JOIN $categoryTransactionTable as ct ON bt.${BudgetFields.idCategory} = ct.${CategoryTransactionFields.id} WHERE bt.active = 1 ORDER BY $orderByASC');
    return result.map((json) => Budget.fromJson(json)).toList();
  }

  Future<List<BudgetStats>> selectMonthlyBudgetsStats() async {
    final db = await database;
    var query = "SELECT bt.*, SUM(t.amount) as spent FROM $budgetTable as bt "
      " LEFT JOIN $categoryTransactionTable as ct ON bt.${BudgetFields.idCategory} = ct.${CategoryTransactionFields.id} "
      " LEFT JOIN '$transactionTable' as t ON t.${TransactionFields.idCategory} = ct.${CategoryTransactionFields.id} " 
      " WHERE bt.active = 1 AND strftime('%m', t.date) = strftime('%m', 'now') AND strftime('%Y', t.date) = strftime('%Y', 'now') "
      " GROUP BY bt.${BudgetFields.idCategory};";
    final result = await db.rawQuery(query);
    return result.map((json) => BudgetStats.fromJson(json)).toList();
  }

  Future<int> updateItem(Budget item) async {
    final db = await database;

    // You can use `rawUpdate` to write the query in SQL
    return db.update(
      budgetTable,
      item.toJson(update: true),
      where: '${BudgetFields.id} = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteById(int id) async {
    final db = await database;

    return await db.delete(budgetTable, where: '${BudgetFields.id} = ?', whereArgs: [id]);
  }

  Future<int> deleteByCategory(int id) async {
    final db = await database;

    return await db.delete(budgetTable, where: '${BudgetFields.idCategory} = ?', whereArgs: [id]);
  }
}
