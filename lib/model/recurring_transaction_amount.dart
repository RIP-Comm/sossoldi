import '../database/sossoldi_database.dart';
import 'base_entity.dart';

const String recurringTransactionAmountTable = 'recurringTransactionAmount';

class RecurringTransactionAmountFields extends BaseEntityFields {
  static String id = BaseEntityFields.getId;
  static String from = 'from';
  static String to = 'to';
  static String amount = 'amount';
  static String idTransaction = 'idTransaction'; // FK
  static String createdAt = BaseEntityFields.getCreatedAt;
  static String updatedAt = BaseEntityFields.getUpdatedAt;

  static final List<String> allFields = [
    BaseEntityFields.id,
    from,
    to,
    amount,
    idTransaction,
    BaseEntityFields.createdAt,
    BaseEntityFields.updatedAt
  ];
}

class RecurringTransactionAmount extends BaseEntity {
  final DateTime from;
  final DateTime to;
  final num amount;
  final int? idTransaction;

  const RecurringTransactionAmount(
      {int? id,
      required this.from,
      required this.to,
      required this.amount,
      required this.idTransaction,
      DateTime? createdAt,
      DateTime? updatedAt})
      : super(id: id, createdAt: createdAt, updatedAt: updatedAt);

  RecurringTransactionAmount copy(
          {int? id,
          DateTime? from,
          DateTime? to,
          num? amount,
          int? idTransaction,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      RecurringTransactionAmount(
          id: id ?? this.id,
          from: from ?? this.from,
          to: to ?? this.to,
          amount: amount ?? this.amount,
          idTransaction:
              idTransaction ?? this.idTransaction,
          createdAt: createdAt ?? this.createdAt,
          updatedAt: updatedAt ?? this.updatedAt);

  static RecurringTransactionAmount fromJson(Map<String, Object?> json) =>
      RecurringTransactionAmount(
          id: json[BaseEntityFields.id] as int?,
          from: DateTime.parse(
              json[RecurringTransactionAmountFields.from] as String),
          to: DateTime.parse(
              json[RecurringTransactionAmountFields.to] as String),
          amount: json[RecurringTransactionAmountFields.amount] as num,
          idTransaction:
              json[RecurringTransactionAmountFields.idTransaction]
                  as int,
          createdAt: DateTime.parse(json[BaseEntityFields.createdAt] as String),
          updatedAt:
              DateTime.parse(json[BaseEntityFields.updatedAt] as String));

  Map<String, Object?> toJson() => {
        BaseEntityFields.id: id,
        RecurringTransactionAmountFields.from: from.toIso8601String(),
        RecurringTransactionAmountFields.to: to.toIso8601String(),
        RecurringTransactionAmountFields.amount: amount,
        RecurringTransactionAmountFields.idTransaction:
            idTransaction,
        BaseEntityFields.createdAt: createdAt?.toIso8601String(),
        BaseEntityFields.updatedAt: updatedAt?.toIso8601String(),
      };
}

class RecurringTransactionMethods extends SossoldiDatabase {
  Future<RecurringTransactionAmount> insert(RecurringTransactionAmount item) async {
    final db = await database;
    final id = await db.insert(recurringTransactionAmountTable, item.toJson());
    return item.copy(id: id);
  }


  Future<RecurringTransactionAmount> selectById(int id) async {
    final db = await database;

    final maps = await db.query(
      recurringTransactionAmountTable,
      columns: RecurringTransactionAmountFields.allFields,
      where: '${RecurringTransactionAmountFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return RecurringTransactionAmount.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<RecurringTransactionAmount>> selectAll() async {
    final db = await database;

    final orderByASC = '${RecurringTransactionAmountFields.createdAt} ASC';

    final result = await db.query(recurringTransactionAmountTable, orderBy: orderByASC);

    return result.map((json) => RecurringTransactionAmount.fromJson(json)).toList();
  }

  Future<int> updateItem(RecurringTransactionAmount item) async {
    final db = await database;

    // You can use `rawUpdate` to write the query in SQL
    return db.update(
      recurringTransactionAmountTable,
      item.toJson(),
      where:
      '${RecurringTransactionAmountFields.id} = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteById(int id) async {
    final db = await database;

    return await db.delete(recurringTransactionAmountTable,
        where:
        '${RecurringTransactionAmountFields.id} = ?',
        whereArgs: [id]);
  }

}