import '../database/sossoldi_database.dart';
import 'bank_account.dart';
import 'base_entity.dart';
import 'category_transaction.dart';

const String transactionTable = 'transaction';

class TransactionFields extends BaseEntityFields {
  static String id = BaseEntityFields.getId;
  static String date = 'date';
  static String amount = 'amount';
  static String type = 'type';
  static String note = 'note';
  static String idCategory = 'idCategory'; // FK
  static String categoryName = 'categoryName';
  static String categoryColor = 'categoryColor';
  static String categorySymbol = 'categorySymbol';
  static String idBankAccount = 'idBankAccount'; // FK
  static String bankAccountName = 'bankAccountName';
  static String idBankAccountTransfer = 'idBankAccountTransfer';
  static String bankAccountTransferName = 'bankAccountTransferName';
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

enum TransactionType { income, expense, transfer }

enum Recurrence { daily, weekly, monthly, bimonthly, quarterly, semester, annual }

Map<String, TransactionType> typeMap = {
  "IN": TransactionType.income,
  "OUT": TransactionType.expense,
  "TRSF": TransactionType.transfer,
};
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
  final TransactionType type;
  final String? note;
  final int? idCategory;
  final String? categoryName;
  final int? categoryColor;
  final String? categorySymbol;
  final int idBankAccount;
  final String? bankAccountName;
  final int? idBankAccountTransfer;
  final String? bankAccountTransferName;
  final bool recurring;
  final String? recurrencyType;
  final int? recurrencyPayDay;
  final DateTime? recurrencyFrom;
  final DateTime? recurrencyTo;

  const Transaction(
      {super.id,
      required this.date,
      required this.amount,
      required this.type,
      this.note,
      this.idCategory,
      this.categoryName,
      this.categoryColor,
      this.categorySymbol,
      required this.idBankAccount,
      this.bankAccountName,
      this.idBankAccountTransfer,
      this.bankAccountTransferName,
      required this.recurring,
      this.recurrencyType,
      this.recurrencyPayDay,
      this.recurrencyFrom,
      this.recurrencyTo,
      super.createdAt,
      super.updatedAt});

  Transaction copy(
          {int? id,
          DateTime? date,
          num? amount,
          TransactionType? type,
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
          updatedAt: updatedAt ?? this.updatedAt);

  static Transaction fromJson(Map<String, Object?> json) => Transaction(
      id: json[BaseEntityFields.id] as int?,
      date: DateTime.parse(json[TransactionFields.date] as String),
      amount: json[TransactionFields.amount] as num,
      type: typeMap[json[TransactionFields.type] as String]!,
      note: json[TransactionFields.note] as String?,
      idCategory: json[TransactionFields.idCategory] as int?,
      categoryName: json[TransactionFields.categoryName] as String?,
      categoryColor: json[TransactionFields.categoryColor] as int?,
      categorySymbol: json[TransactionFields.categorySymbol] as String?,
      idBankAccount: json[TransactionFields.idBankAccount] as int,
      bankAccountName: json[TransactionFields.bankAccountName] as String?,
      idBankAccountTransfer: json[TransactionFields.idBankAccountTransfer] as int?,
      bankAccountTransferName: json[TransactionFields.bankAccountTransferName] as String?,
      recurring: json[TransactionFields.recurring] == 1 ? true : false,
      recurrencyType: json[TransactionFields.recurrencyType] as String?,
      recurrencyPayDay: json[TransactionFields.recurrencyPayDay] as int?,
      recurrencyFrom: json[TransactionFields.recurrencyFrom] != null
          ? DateTime.parse(TransactionFields.recurrencyFrom)
          : null,
      recurrencyTo: json[TransactionFields.recurrencyTo] != null
          ? DateTime.parse(TransactionFields.recurrencyTo)
          : null,
      createdAt: DateTime.parse(json[BaseEntityFields.createdAt] as String),
      updatedAt: DateTime.parse(json[BaseEntityFields.updatedAt] as String));

  Map<String, Object?> toJson({bool update = false}) => {
        TransactionFields.id: id,
        TransactionFields.date: date.toIso8601String(),
        TransactionFields.amount: amount,
        TransactionFields.type: typeMap.keys.firstWhere((k) => typeMap[k] == type),
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
    final maps = await db.rawQuery('SELECT t.*, c.${CategoryTransactionFields.name} as ${TransactionFields.categoryName}, c.${CategoryTransactionFields.color} as ${TransactionFields.categoryColor}, c.${CategoryTransactionFields.symbol} as ${TransactionFields.categorySymbol}, b1.${BankAccountFields.name} as ${TransactionFields.bankAccountName}, b2.${BankAccountFields.name} as ${TransactionFields.bankAccountTransferName} FROM $transactionTable as t LEFT JOIN $categoryTransactionTable as c ON t.${TransactionFields.idCategory} = c.${CategoryTransactionFields.id} LEFT JOIN $bankAccountTable as b1 ON t.${TransactionFields.idBankAccount} = b1.${BankAccountFields.id} LEFT JOIN $bankAccountTable as b2 ON t.${TransactionFields.idBankAccountTransfer} = b2.${BankAccountFields.id} WHERE t.${TransactionFields.id} = ?', [id]);

    if (maps.isNotEmpty) {
      return Transaction.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Transaction>> selectAll(
      {int? type,
      DateTime? date,
      DateTime? dateRangeStart,
      DateTime? dateRangeEnd,
      int? limit}) async {
    final db = await database;

    String? where = type != null ? '${TransactionFields.type} = $type' : null; // filter type
    if (date != null) {
      where =
          "${where != null ? '$where and ' : ''}${TransactionFields.date} >= '${date.toIso8601String().substring(0, 10)}T00:00:00' and ${TransactionFields.date} <= '${date.toIso8601String().substring(0, 10)}T23:59:59'";
    } else if (dateRangeStart != null && dateRangeEnd != null) {
      where =
          "${where != null ? '$where and ' : ''}${TransactionFields.date} BETWEEN '${dateRangeStart.toIso8601String().substring(0, 10)}T00:00:00' and '${dateRangeEnd.toIso8601String().substring(0, 10)}T23:59:59'";
    }

    final orderByDESC = '${TransactionFields.date} DESC';

    final result =
        await db.rawQuery('SELECT t.*, c.${CategoryTransactionFields.name} as ${TransactionFields.categoryName}, c.${CategoryTransactionFields.color} as ${TransactionFields.categoryColor}, c.${CategoryTransactionFields.symbol} as ${TransactionFields.categorySymbol}, b1.${BankAccountFields.name} as ${TransactionFields.bankAccountName}, b2.${BankAccountFields.name} as ${TransactionFields.bankAccountTransferName} FROM "$transactionTable" as t LEFT JOIN $categoryTransactionTable as c ON t.${TransactionFields.idCategory} = c.${CategoryTransactionFields.id} LEFT JOIN $bankAccountTable as b1 ON t.${TransactionFields.idBankAccount} = b1.${BankAccountFields.id} LEFT JOIN $bankAccountTable as b2 ON t.${TransactionFields.idBankAccountTransfer} = b2.${BankAccountFields.id} ${where != null ? "WHERE $where" : ""} ORDER BY $orderByDESC ${limit != null ? "LIMIT $limit" : ""}');

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
