import '../database/sossoldi_database.dart';
import 'base_entity.dart';

const String recurringTransactionAmountTable = 'recurringTransactionAmount';

class RecurringTransactionAmountFields extends BaseEntityFields {
  static String id = BaseEntityFields.getId;
  static String from = 'from';
  static String to = 'to';
  static String amount = 'amount';
  static String idRecurringTransaction = 'idRecurringTransaction'; // FK
  static String createdAt = BaseEntityFields.getCreatedAt;
  static String updatedAt = BaseEntityFields.getUpdatedAt;

  static final List<String> allFields = [
    BaseEntityFields.id,
    from,
    to,
    amount,
    idRecurringTransaction,
    BaseEntityFields.createdAt,
    BaseEntityFields.updatedAt
  ];
}

class RecurringTransactionAmount extends BaseEntity {
  final DateTime from;
  final DateTime to;
  final num amount;
  final int? idRecurringTransaction;

  const RecurringTransactionAmount(
      {int? id,
      required this.from,
      required this.to,
      required this.amount,
      required this.idRecurringTransaction,
      DateTime? createdAt,
      DateTime? updatedAt})
      : super(id: id, createdAt: createdAt, updatedAt: updatedAt);

  RecurringTransactionAmount copy(
          {int? id,
          DateTime? from,
          DateTime? to,
          num? amount,
          int? idRecurringTransaction,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      RecurringTransactionAmount(
          id: id ?? this.id,
          from: from ?? this.from,
          to: to ?? this.to,
          amount: amount ?? this.amount,
          idRecurringTransaction:
              idRecurringTransaction ?? this.idRecurringTransaction,
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
          idRecurringTransaction:
              json[RecurringTransactionAmountFields.idRecurringTransaction]
                  as int,
          createdAt: DateTime.parse(json[BaseEntityFields.createdAt] as String),
          updatedAt:
              DateTime.parse(json[BaseEntityFields.updatedAt] as String));

  Map<String, Object?> toJson() => {
        BaseEntityFields.id: id,
        RecurringTransactionAmountFields.from: from.toIso8601String(),
        RecurringTransactionAmountFields.to: to.toIso8601String(),
        RecurringTransactionAmountFields.amount: amount,
        RecurringTransactionAmountFields.idRecurringTransaction:
            idRecurringTransaction,
        BaseEntityFields.createdAt: createdAt?.toIso8601String(),
        BaseEntityFields.updatedAt: updatedAt?.toIso8601String(),
      };
}

class RecurringTransactionMethods extends SossoldiDatabase {
  Future<RecurringTransactionAmount> insert(RecurringTransactionAmount item) async {
    final database = await SossoldiDatabase.instance.database;
    final id = await database.insert(recurringTransactionAmountTable, item.toJson());
    return item.copy(id: id);
  }


  Future<RecurringTransactionAmount> selectById(int id) async {
    final database = await SossoldiDatabase.instance.database;

    final maps = await database.query(
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
    final database = await SossoldiDatabase.instance.database;

    final orderByASC = '${RecurringTransactionAmountFields.createdAt} ASC';

    final result = await database.query(recurringTransactionAmountTable, orderBy: orderByASC);

    return result.map((json) => RecurringTransactionAmount.fromJson(json)).toList();
  }

  Future<int> updateItem(RecurringTransactionAmount item) async {
    final database = await SossoldiDatabase.instance.database;

    // You can use `rawUpdate` to write the query in SQL
    return database.update(
      recurringTransactionAmountTable,
      item.toJson(),
      where:
      '${RecurringTransactionAmountFields.id} = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteById(int id) async {
    final database = await SossoldiDatabase.instance.database;

    return await database.delete(recurringTransactionAmountTable,
        where:
        '${RecurringTransactionAmountFields.id} = ?',
        whereArgs: [id]);
  }

}