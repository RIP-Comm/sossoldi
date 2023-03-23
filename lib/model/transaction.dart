import '../database/sossoldi_database.dart';
import 'base_entity.dart';

const String transactionTable = 'transaction';

class TransactionFields extends BaseEntityFields {
  static String id = BaseEntityFields.getId;
  static String date = 'date';
  static String amount = 'amount';
  static String type = 'type';
  static String note = 'note';
  static String idCategory = 'idCategory'; // FK
  static String idBankAccount = 'idBankAccount'; // FK
  static String idBankAccountTransfer = 'idBankAccountTransfer';
  static String recurring = 'recurring';
  static String recurrencyType = 'recurrencyType';
  static String recurrencyPayDay = 'recurrencyPayDay';
  static String recurrencyFrom = 'recurrencyFrom';
  static String recurrencyTo = 'recurrencyTo';
  static String createdAt = BaseEntityFields.getCreatedAt;
  static String updatedAt = BaseEntityFields.getUpdatedAt;

  static final List<String> allFields = [
    BaseEntityFields.id,
    date,
    amount,
    type,
    note,
    idCategory,
    idBankAccount,
    idBankAccountTransfer,
    recurring,
    recurrencyType,
    recurrencyPayDay,
    recurrencyFrom,
    recurrencyTo,
    BaseEntityFields.createdAt,
    BaseEntityFields.updatedAt
  ];
}

enum Type { income, expense, transfer }
enum Recurrence { daily, weekly, monthly, bimonthly, quarterly, semester, annual }

Map<Recurrence, String> recurrenceMap = {
  Recurrence.daily: "Daily",
  Recurrence.weekly: "Weekly",
  Recurrence.monthly: "Monthly",
  Recurrence.bimonthly: "Bimonthly",
  Recurrence.quarterly: "Quarterly",
  Recurrence.semester: "Semester",
  Recurrence.annual: "Annual",
};

class Transaction extends BaseEntity {
  final DateTime date;
  final num amount;
  final Type type;
  final String? note;
  final int? idCategory;
  final int idBankAccount;
  final int? idBankAccountTransfer;
  final bool recurring;
  final String? recurrencyType;
  final int? recurrencyPayDay;
  final DateTime? recurrencyFrom;
  final DateTime? recurrencyTo;

  const Transaction(
      {int? id,
      required this.date,
      required this.amount,
      required this.type,
      this.note,
      this.idCategory,
      required this.idBankAccount,
      this.idBankAccountTransfer,
      required this.recurring,
      this.recurrencyType,
      this.recurrencyPayDay,
      this.recurrencyFrom,
      this.recurrencyTo,
      DateTime? createdAt,
      DateTime? updatedAt})
      : super(id: id, createdAt: createdAt, updatedAt: updatedAt);

  Transaction copy(
      {int? id,
      DateTime? date,
      num? amount,
      Type? type,
      String? note,
      int? idCategory,
      int? idBankAccount,
      int? idBankAccountTransfer,
      bool? recurring,
      String? recurrencyType,
      int? recurrencyPayDay,
      DateTime? recurrencyFrom,
      DateTime? recurrencyTo,
      DateTime? createdAt,
      DateTime? updatedAt}) =>
        Transaction(
            id: id ?? this.id,
            date: date ?? this.date,
            amount: amount ?? this.amount,
            type: type ?? this.type,
            note: note ?? this.note,
            idCategory: idCategory ?? this.idCategory,
            idBankAccount: idBankAccount ?? this.idBankAccount,
            idBankAccountTransfer: idBankAccountTransfer ?? this.idBankAccountTransfer,
            recurring: recurring ?? this.recurring,
            recurrencyType: recurrencyType ?? this.recurrencyType,
            recurrencyPayDay: recurrencyPayDay ?? this.recurrencyPayDay,
            recurrencyFrom: recurrencyFrom ?? this.recurrencyFrom,
            recurrencyTo: recurrencyTo ?? this.recurrencyTo,
            createdAt: createdAt ?? this.createdAt,
            updatedAt: updatedAt ?? this.updatedAt
        );

  static Transaction fromJson(Map<String, Object?> json) => Transaction(
      id: json[BaseEntityFields.id] as int?,
      date: DateTime.parse(json[TransactionFields.date] as String),
      amount: json[TransactionFields.amount] as num,
      type: Type.values[json[TransactionFields.type] as int],
      note: json[TransactionFields.note] as String?,
      idCategory: json[TransactionFields.idCategory] as int?,
      idBankAccount: json[TransactionFields.idBankAccount] as int,
      idBankAccountTransfer: json[TransactionFields.idBankAccountTransfer] as int?,
      recurring: json[TransactionFields.recurring] == 1 ? true : false,
      recurrencyType: json[TransactionFields.recurrencyType] as String?,
      recurrencyPayDay: json[TransactionFields.recurrencyPayDay] as int?,
      recurrencyFrom: json[TransactionFields.recurrencyFrom] != null ? DateTime.parse(TransactionFields.recurrencyFrom) : null,
      recurrencyTo: json[TransactionFields.recurrencyTo] != null ? DateTime.parse(TransactionFields.recurrencyTo) : null,
      createdAt: DateTime.parse(json[BaseEntityFields.createdAt] as String),
      updatedAt: DateTime.parse(json[BaseEntityFields.updatedAt] as String)
  );

  Map<String, Object?> toJson({bool update = false}) => {
        TransactionFields.id: id,
        TransactionFields.date: date.toIso8601String(),
        TransactionFields.amount: amount,
        TransactionFields.type: type.index,
        TransactionFields.note: note,
        TransactionFields.idCategory: idCategory,
        TransactionFields.idBankAccount: idBankAccount,
        TransactionFields.idBankAccountTransfer: idBankAccountTransfer,
        TransactionFields.recurring: recurring ? 1 : 0,
        TransactionFields.recurrencyType: recurrencyType,
        TransactionFields.recurrencyPayDay: recurrencyPayDay,
        TransactionFields.recurrencyFrom: recurrencyFrom,
        TransactionFields.recurrencyTo: recurrencyTo,
        BaseEntityFields.createdAt:
            update ? createdAt?.toIso8601String() : DateTime.now().toIso8601String(),
        BaseEntityFields.updatedAt: DateTime.now().toIso8601String(),
      };
}

class TransactionMethods extends SossoldiDatabase {
  Future<Transaction> insert(Transaction item) async {
    final db = await database;
    final id = await db.insert(transactionTable, item.toJson());
    return item.copy(id: id);
  }

  Future<Transaction> selectById(int id) async {
    final db = await database;

    final maps = await db.query(
      transactionTable,
      columns: TransactionFields.allFields,
      where: '${TransactionFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Transaction.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Transaction>> selectAll({int? type, DateTime? date, int? limit}) async {
    final db = await database;

    String? where = type != null ? '${TransactionFields.type} = $type' : null; // filter type
    if(date != null) {
      where = where != null ? "$where and ${TransactionFields.date} >= '2021-01-01' and ${TransactionFields.date} <= '2022-10-10'" : "${TransactionFields.date} >= '2021-01-01' and ${TransactionFields.date} <= '2022-10-10'"; // filter date
    }

    final orderByDESC = '${TransactionFields.date} DESC';

    final result = await db.query(transactionTable, where: where, orderBy: orderByDESC, limit: limit);

    return result.map((json) => Transaction.fromJson(json)).toList();
  }

  Future<int> updateItem(Transaction item) async {
    final db = await database;

    // You can use `rawUpdate` to write the query in SQL
    return db.update(
      transactionTable,
      item.toJson(update: true),
      where: '${TransactionFields.id} = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteById(int id) async {
    final db = await database;

    return await db.delete(
      transactionTable,
      where: '${TransactionFields.id} = ?',
      whereArgs: [id],
    );
  }
}
