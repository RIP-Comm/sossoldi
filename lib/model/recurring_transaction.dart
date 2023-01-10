import '../database/sossoldi_database.dart';
import 'base_entity.dart';

const String recurringTransactionTable = 'recurringTransaction';

class RecurringTransactionFields extends BaseEntityFields {
  static String id = BaseEntityFields.getId;
  static String from = 'from';
  static String to = 'to';
  static String payDay = 'payDay';
  static String recurrence = 'recurrence';
  static String idCategoryRecurring = 'idCategoryRecurring'; // FK
  static String createdAt = BaseEntityFields.getCreatedAt;
  static String updatedAt = BaseEntityFields.getUpdatedAt;

  static final List<String> allFields = [
    BaseEntityFields.id,
    from,
    to,
    payDay,
    recurrence,
    idCategoryRecurring,
    BaseEntityFields.createdAt,
    BaseEntityFields.updatedAt
  ];
}

enum Recurrence {
  daily,
  weekly,
  monthly,
  bimonthly,
  quarterly,
  semester,
  annual
}

class RecurringTransaction extends BaseEntity {
  final DateTime from;
  final DateTime to;
  final int payDay;
  final Recurrence recurrence;
  final int? idCategoryRecurring;

  const RecurringTransaction(
      {int? id,
      required this.from,
      required this.to,
      required this.payDay,
      required this.recurrence,
      this.idCategoryRecurring,
      DateTime? createdAt,
      DateTime? updatedAt})
      : super(id: id, createdAt: createdAt, updatedAt: updatedAt);

  RecurringTransaction copy(
          {int? id,
          DateTime? from,
          DateTime? to,
          int? payDay,
          Recurrence? recurrence,
          int? idCategoryRecurring,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      RecurringTransaction(
          id: id ?? this.id,
          from: from ?? this.from,
          to: to ?? this.to,
          payDay: payDay ?? this.payDay,
          recurrence: recurrence ?? this.recurrence,
          idCategoryRecurring: idCategoryRecurring ?? this.idCategoryRecurring,
          createdAt: createdAt ?? this.createdAt,
          updatedAt: updatedAt ?? this.updatedAt);

  static RecurringTransaction fromJson(Map<String, Object?> json) =>
      RecurringTransaction(
          id: json[BaseEntityFields.id] as int?,
          from: DateTime.parse(json[RecurringTransactionFields.from] as String),
          to: DateTime.parse(json[RecurringTransactionFields.to] as String),
          payDay: json[RecurringTransactionFields.payDay] as int,
          recurrence: Recurrence
              .values[json[RecurringTransactionFields.recurrence] as int],
          idCategoryRecurring:
              json[RecurringTransactionFields.idCategoryRecurring] as int?,
          createdAt: DateTime.parse(json[BaseEntityFields.createdAt] as String),
          updatedAt:
              DateTime.parse(json[BaseEntityFields.updatedAt] as String));

  Map<String, Object?> toJson() => {
        BaseEntityFields.id: id,
        RecurringTransactionFields.from: from.toIso8601String(),
        RecurringTransactionFields.to: to.toIso8601String(),
        RecurringTransactionFields.payDay: payDay,
        RecurringTransactionFields.recurrence: recurrence.index,
        RecurringTransactionFields.idCategoryRecurring: idCategoryRecurring,
        BaseEntityFields.createdAt: createdAt?.toIso8601String(),
        BaseEntityFields.updatedAt: updatedAt?.toIso8601String(),
      };
}

class RecurringTransactionMethods extends SossoldiDatabase {
  Future<RecurringTransaction> insert(RecurringTransaction item) async {
    final database = await SossoldiDatabase.instance.database;
    final id = await database.insert(recurringTransactionTable, item.toJson());
    return item.copy(id: id);
  }


  Future<RecurringTransaction> selectById(int id) async {
    final database = await SossoldiDatabase.instance.database;

    final maps = await database.query(
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
    final database = await SossoldiDatabase.instance.database;

    final orderByASC = '${RecurringTransactionFields.createdAt} ASC';

    final result = await database.query(recurringTransactionTable, orderBy: orderByASC);

    return result.map((json) => RecurringTransaction.fromJson(json)).toList();
  }

  Future<int> updateItem(RecurringTransaction item) async {
    final database = await SossoldiDatabase.instance.database;

    // You can use `rawUpdate` to write the query in SQL
    return database.update(
      recurringTransactionTable,
      item.toJson(),
      where:
      '${RecurringTransactionFields.id} = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteById(int id) async {
    final database = await SossoldiDatabase.instance.database;

    return await database.delete(recurringTransactionTable,
        where:
        '${RecurringTransactionFields.id} = ?',
        whereArgs: [id]);
  }

}