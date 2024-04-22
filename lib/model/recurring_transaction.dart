import '../database/sossoldi_database.dart';
import 'base_entity.dart';

const String recurringTransactionTable = 'recurringTransaction';

class RecurringTransactionFields extends BaseEntityFields {
  static String id = BaseEntityFields.getId;
  static String from = 'from';
  static String to = 'to';
  static String amount = 'amount';
  static String lastInsertion = 'lastInsertion';
  static String createdAt = BaseEntityFields.getCreatedAt;
  static String updatedAt = BaseEntityFields.getUpdatedAt;

  static final List<String> allFields = [
    BaseEntityFields.id,
    from,
    to,
    amount,
    lastInsertion,
    BaseEntityFields.createdAt,
    BaseEntityFields.updatedAt
  ];
}

class RecurringTransaction extends BaseEntity {
  final DateTime from;
  final DateTime to;
  final num amount;
  final DateTime? lastInsertion;

  const RecurringTransaction(
      {int? id,
      required this.from,
      required this.to,
      required this.amount,
      this.lastInsertion,
      DateTime? createdAt,
      DateTime? updatedAt})
      : super(id: id, createdAt: createdAt, updatedAt: updatedAt);

  RecurringTransaction copy(
          {int? id,
          DateTime? from,
          DateTime? to,
          num? amount,
          DateTime? lastInsertion,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      RecurringTransaction(
          id: id ?? this.id,
          from: from ?? this.from,
          to: to ?? this.to,
          amount: amount ?? this.amount,
          lastInsertion: lastInsertion ?? this.lastInsertion,
          createdAt: createdAt ?? this.createdAt,
          updatedAt: updatedAt ?? this.updatedAt);

  static RecurringTransaction fromJson(Map<String, Object?> json) =>
      RecurringTransaction(
          id: json[BaseEntityFields.id] as int?,
          from: DateTime.parse(
              json[RecurringTransactionFields.from] as String),
          to: DateTime.parse(
              json[RecurringTransactionFields.to] as String),
          amount: json[RecurringTransactionFields.amount] as num,
          lastInsertion:
              json[RecurringTransactionFields.lastInsertion]
                  as DateTime,
          createdAt: DateTime.parse(json[BaseEntityFields.createdAt] as String),
          updatedAt:
              DateTime.parse(json[BaseEntityFields.updatedAt] as String));

  Map<String, Object?> toJson() => {
        BaseEntityFields.id: id,
        RecurringTransactionFields.from: from.toIso8601String(),
        RecurringTransactionFields.to: to.toIso8601String(),
        RecurringTransactionFields.amount: amount,
        RecurringTransactionFields.lastInsertion: lastInsertion?.toIso8601String(),
        BaseEntityFields.createdAt: createdAt?.toIso8601String(),
        BaseEntityFields.updatedAt: updatedAt?.toIso8601String(),
      };
}

class RecurringTransactionMethods extends SossoldiDatabase {
  Future<RecurringTransaction> insert(RecurringTransaction item) async {
    final db = await database;
    final id = await db.insert(recurringTransactionTable, item.toJson());
    return item.copy(id: id);
  }


  Future<RecurringTransaction> selectById(int id) async {
    final db = await database;

    final maps = await db.query(
      recurringTransactionTable,
      columns: RecurringTransactionFields.allFields,
      where: '${RecurringTransactionFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return RecurringTransaction.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<RecurringTransaction>> selectAll() async {
    final db = await database;

    final orderByASC = '${RecurringTransactionFields.createdAt} ASC';

    final result = await db.query(recurringTransactionTable, orderBy: orderByASC);

    return result.map((json) => RecurringTransaction.fromJson(json)).toList();
  }

  Future<int> updateItem(RecurringTransaction item) async {
    final db = await database;

    // You can use `rawUpdate` to write the query in SQL
    return db.update(
      recurringTransactionTable,
      item.toJson(),
      where:
      '${RecurringTransactionFields.id} = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteById(int id) async {
    final db = await database;

    return await db.delete(recurringTransactionTable,
        where:
        '${RecurringTransactionFields.id} = ?',
        whereArgs: [id]);
  }

}