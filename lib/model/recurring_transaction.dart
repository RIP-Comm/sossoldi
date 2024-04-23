import '../database/sossoldi_database.dart';
import 'base_entity.dart';

const String recurringTransactionTable = 'recurringTransaction';

class RecurringTransactionFields extends BaseEntityFields {
  static String id = BaseEntityFields.getId;
  static String fromDate = 'fromDate';
  static String toDate = 'toDate';
  static String amount = 'amount';
  static String note = 'note';
  static String recurrency = 'recurrency';
  static String idCategory = 'idCategory';
  static String lastInsertion = 'lastInsertion';
  static String createdAt = BaseEntityFields.getCreatedAt;
  static String updatedAt = BaseEntityFields.getUpdatedAt;

  static final List<String> allFields = [
    BaseEntityFields.id,
    fromDate,
    toDate,
    amount,
    note,
    recurrency,
    idCategory,
    lastInsertion,
    BaseEntityFields.createdAt,
    BaseEntityFields.updatedAt
  ];
}

class RecurringTransaction extends BaseEntity {
  final DateTime fromDate;
  final DateTime? toDate;
  final num amount;
  final String note;
  final String recurrency;
  final num idCategory;
  final DateTime? lastInsertion;

  const RecurringTransaction(
      {int? id,
      required this.fromDate,
      this.toDate,
      required this.amount,
      required this.note,
      required this.recurrency,
      required this.idCategory,
      this.lastInsertion,
      DateTime? createdAt,
      DateTime? updatedAt})
      : super(id: id, createdAt: createdAt, updatedAt: updatedAt);

  RecurringTransaction copy(
          {int? id,
          DateTime? fromDate,
          DateTime? toDate,
          num? amount,
          String? note,
          String? recurrency,
          num? idCategory,
          DateTime? lastInsertion,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      RecurringTransaction(
          id: id ?? this.id,
          fromDate: fromDate ?? this.fromDate,
          toDate: toDate ?? this.toDate,
          amount: amount ?? this.amount,
          note: note ?? this.note,
          recurrency: recurrency ?? this.recurrency,
          idCategory: idCategory ?? this.idCategory,
          lastInsertion: lastInsertion ?? this.lastInsertion,
          createdAt: createdAt ?? this.createdAt,
          updatedAt: updatedAt ?? this.updatedAt);

  static RecurringTransaction fromJson(Map<String, Object?> json) =>
      RecurringTransaction(
          id: json[BaseEntityFields.id] as int?,
          fromDate: DateTime.parse(
              json[RecurringTransactionFields.fromDate] as String),
          toDate: json[RecurringTransactionFields.toDate] != null
              ? DateTime.parse(json[RecurringTransactionFields.toDate] as String)
              : null,
          amount: json[RecurringTransactionFields.amount] as num,
          note: json[RecurringTransactionFields.note] as String,
          recurrency: json[RecurringTransactionFields.recurrency] as String,
          idCategory: json[RecurringTransactionFields.idCategory] as num,
          lastInsertion: json[RecurringTransactionFields.lastInsertion] != null
              ? DateTime.parse(json[RecurringTransactionFields.lastInsertion] as String)
              : null,
          createdAt: DateTime.parse(json[BaseEntityFields.createdAt] as String),
          updatedAt:
              DateTime.parse(json[BaseEntityFields.updatedAt] as String));

  Map<String, Object?> toJson() => {
        BaseEntityFields.id: id,
        RecurringTransactionFields.fromDate: fromDate.toIso8601String(),
        RecurringTransactionFields.toDate: toDate?.toIso8601String(),
        RecurringTransactionFields.amount: amount,
        RecurringTransactionFields.note: note,
        RecurringTransactionFields.recurrency: recurrency,
        RecurringTransactionFields.idCategory: idCategory,
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