import '../services/database/sossoldi_database.dart';
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
  static String idRecurringTransaction = 'idRecurringTransaction';
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
    idRecurringTransaction,
    BaseEntityFields.createdAt,
    BaseEntityFields.updatedAt
  ];
}

Map<String, TransactionType> typeMap = {
  "IN": TransactionType.income,
  "OUT": TransactionType.expense,
  "TRSF": TransactionType.transfer,
};

enum TransactionType {
  income,
  expense,
  transfer;

  String get code => switch (this) {
        TransactionType.income => "IN",
        TransactionType.expense => "OUT",
        TransactionType.transfer => "TRSF",
      };

  String get prefix =>
      switch (this) { TransactionType.expense => "-", _ => "" };

  static TransactionType fromJson(String code) =>
      TransactionType.values.firstWhere((e) => e.code == code);

  String toJson() => code;
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

class RecurrenceData {
  final Recurrence recurrence;
  final String label;
  final int days;

  RecurrenceData({
    required this.recurrence,
    required this.label,
    required this.days,
  });
}

Map<Recurrence, RecurrenceData> recurrenceMap = {
  Recurrence.daily: RecurrenceData(recurrence: Recurrence.daily, label: "Daily", days: 1),
  Recurrence.weekly: RecurrenceData(recurrence: Recurrence.weekly, label: "Weekly", days: 7),
  Recurrence.monthly: RecurrenceData(recurrence: Recurrence.monthly, label: "Monthly", days: 30),
  Recurrence.bimonthly:
      RecurrenceData(recurrence: Recurrence.bimonthly, label: "Bimonthly", days: 60),
  Recurrence.quarterly:
      RecurrenceData(recurrence: Recurrence.quarterly, label: "Quarterly", days: 90),
  Recurrence.semester:
      RecurrenceData(recurrence: Recurrence.semester, label: "Semester", days: 180),
  Recurrence.annual: RecurrenceData(recurrence: Recurrence.annual, label: "Annual", days: 365),
};

Recurrence parseRecurrence(String s) {
  return recurrenceMap.entries
      .firstWhere((entry) => entry.value.label.toLowerCase() == s.toLowerCase())
      .key;
}

class Transaction extends BaseEntity {
  // This is to allow to manually set a null value to id field.
  static const _unset = Object();

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
  final int? idRecurringTransaction;

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
      this.idRecurringTransaction,
      super.createdAt,
      super.updatedAt});

  Transaction copy(
          {Object? id = _unset,
          DateTime? date,
          num? amount,
          TransactionType? type,
          String? note,
          int? idCategory,
          int? idBankAccount,
          int? idBankAccountTransfer,
          bool? recurring,
          int? idRecurringTransaction,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Transaction(
          id: id == _unset ? this.id : (id as int?),
          date: date ?? this.date,
          amount: amount ?? this.amount,
          type: type ?? this.type,
          note: note ?? this.note,
          idCategory: idCategory ?? this.idCategory,
          idBankAccount: idBankAccount ?? this.idBankAccount,
          idBankAccountTransfer: idBankAccountTransfer ?? this.idBankAccountTransfer,
          recurring: recurring ?? this.recurring,
          idRecurringTransaction: idRecurringTransaction ?? this.idRecurringTransaction,
          createdAt: createdAt ?? this.createdAt,
          updatedAt: updatedAt ?? this.updatedAt);

  static Transaction fromJson(Map<String, Object?> json) {
    return Transaction(
      id: json[BaseEntityFields.id] as int?,
      date: DateTime.parse(json[TransactionFields.date] as String),
      amount: json[TransactionFields.amount] as num,
      type: TransactionType.fromJson(json[TransactionFields.type] as String),
      note: json[TransactionFields.note] as String?,
      idCategory: json[TransactionFields.idCategory] as int?,
      categoryName: json[TransactionFields.categoryName] as String?,
      categoryColor: json[TransactionFields.categoryColor] as int?,
      categorySymbol: json[TransactionFields.categorySymbol] as String?,
      idBankAccount: json[TransactionFields.idBankAccount] as int,
      bankAccountName: json[TransactionFields.bankAccountName] as String?,
      idBankAccountTransfer:
          json[TransactionFields.idBankAccountTransfer] as int?,
      bankAccountTransferName:
          json[TransactionFields.bankAccountTransferName] as String?,
      recurring: json[TransactionFields.recurring] == 1,
      idRecurringTransaction:
          json[TransactionFields.idRecurringTransaction] as int?,
      createdAt: DateTime.parse(json[BaseEntityFields.createdAt] as String),
      updatedAt: DateTime.parse(json[BaseEntityFields.updatedAt] as String),
    );
  }

  Map<String, Object?> toJson({bool update = false}) {
    final createdAtDate = update
        ? createdAt?.toIso8601String()
        : DateTime.now().toIso8601String();

    return {
      TransactionFields.id: id,
      TransactionFields.date: date.toIso8601String(),
      TransactionFields.amount: amount,
      TransactionFields.type: type.toJson(),
      TransactionFields.note: note,
      TransactionFields.idCategory: idCategory,
      TransactionFields.idBankAccount: idBankAccount,
      TransactionFields.idBankAccountTransfer: idBankAccountTransfer,
      TransactionFields.recurring: recurring ? 1 : 0,
      TransactionFields.idRecurringTransaction: idRecurringTransaction,
      BaseEntityFields.createdAt: createdAtDate,
      BaseEntityFields.updatedAt: DateTime.now().toIso8601String(),
    };
  }
}

class TransactionMethods extends SossoldiDatabase {
  Future<Transaction> insert(Transaction item) async {
    final db = await database;
    final id = await db.insert(transactionTable, item.toJson());
    return item.copy(id: id);
  }

  Future<Transaction> selectById(int id) async {
    final db = await database;

    final maps = await db.rawQuery('''
      SELECT t.*,
        c.${CategoryTransactionFields.name} as ${TransactionFields.categoryName},
        c.${CategoryTransactionFields.color} as ${TransactionFields.categoryColor},
        c.${CategoryTransactionFields.symbol} as ${TransactionFields.categorySymbol},
        b1.${BankAccountFields.name} as ${TransactionFields.bankAccountName},
        b2.${BankAccountFields.name} as ${TransactionFields.bankAccountTransferName}
      FROM
        '$transactionTable' as t
      LEFT JOIN
        $categoryTransactionTable as c ON t.${TransactionFields.idCategory} = c.${CategoryTransactionFields.id}
      LEFT JOIN
        $bankAccountTable as b1 ON t.${TransactionFields.idBankAccount} = b1.${BankAccountFields.id}
      LEFT JOIN
        $bankAccountTable as b2 ON t.${TransactionFields.idBankAccountTransfer} = b2.${BankAccountFields.id}
      WHERE
        t.${TransactionFields.id} = ?
    ''', [id]);

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
      int? limit,
      List<String>? transactionType,
      String? label,
      Map<int, bool>? bankAccounts}) async {
    final db = await database;

    String? where = type != null ? '${TransactionFields.type} = $type' : null; // filter type
    if (date != null) {
      where =
          "${where != null ? '$where and ' : ''}strftime('%Y-%m-%d', ${TransactionFields.date}) >= '${date.toString().substring(0, 10)}' and ${TransactionFields.date} <= '${date.toIso8601String().substring(0, 10)}'";
    } else if (dateRangeStart != null && dateRangeEnd != null) {
      where =
          "${where != null ? '$where and ' : ''}strftime('%Y-%m-%d', ${TransactionFields.date}) BETWEEN '${dateRangeStart.toString().substring(0, 10)}' and '${dateRangeEnd.toIso8601String().substring(0, 10)}'";
    }

    if (label != null && label.isNotEmpty) {
      where = "${where != null ? '$where and ' : ''}t.note LIKE '%$label%' ";
    }

    if (transactionType != null) {
      final transactionTypeList = transactionType.map((e) => "'$e'").toList();
      where = "${where != null ? '$where and ' : ''}t.type IN (${transactionTypeList.join(',')}) ";
    }

    if (bankAccounts != null && !bankAccounts.entries.every((element) => element.value == false)) {
      final bankAccountIds =
          bankAccounts.entries.where((bankAccount) => bankAccount.value).map((e) => "'${e.key}'");
      where =
          "${where != null ? '$where and ' : ''}t.${TransactionFields.idBankAccount} IN (${bankAccountIds.join(',')}) ";
    }

    final orderByDESC = '${TransactionFields.date} DESC';

    final result = await db.rawQuery(
        'SELECT t.*, c.${CategoryTransactionFields.name} as ${TransactionFields.categoryName}, c.${CategoryTransactionFields.color} as ${TransactionFields.categoryColor}, c.${CategoryTransactionFields.symbol} as ${TransactionFields.categorySymbol}, b1.${BankAccountFields.name} as ${TransactionFields.bankAccountName}, b2.${BankAccountFields.name} as ${TransactionFields.bankAccountTransferName} FROM "$transactionTable" as t LEFT JOIN $categoryTransactionTable as c ON t.${TransactionFields.idCategory} = c.${CategoryTransactionFields.id} LEFT JOIN $bankAccountTable as b1 ON t.${TransactionFields.idBankAccount} = b1.${BankAccountFields.id} LEFT JOIN $bankAccountTable as b2 ON t.${TransactionFields.idBankAccountTransfer} = b2.${BankAccountFields.id} ${where != null ? "WHERE $where" : ""} ORDER BY $orderByDESC ${limit != null ? "LIMIT $limit" : ""}');

    return result.map((json) => Transaction.fromJson(json)).toList();
  }

  Future<List<Transaction>> getRecurrenceTransactionsById({int? id}) async {
    final db = await database;

    final result = await db.rawQuery(
        'SELECT * FROM "$transactionTable" as t WHERE t.${TransactionFields.idRecurringTransaction} = $id ORDER BY ${TransactionFields.date} DESC');

    return result.map((json) => Transaction.fromJson(json)).toList();
  }

  Future<List<String>> getAllLabels({String? label}) async {
    final db = await database;

    String where = "";
    final orderByDESC = '${TransactionFields.date} DESC';

    if (label != null) {
      where = "t.note LIKE '%$label%' ";
    }

    final result = await db.rawQuery(
        'SELECT DISTINCT LOWER(t.note) as note FROM "$transactionTable" as t LEFT JOIN $bankAccountTable as b1 ON t.${TransactionFields.idBankAccount} = b1.${BankAccountFields.id} LEFT JOIN $bankAccountTable as b2 ON t.${TransactionFields.idBankAccountTransfer} = b2.${BankAccountFields.id} ${where.isNotEmpty ? "WHERE $where" : ""} ORDER BY $orderByDESC');

    return (result).map((x) => x["note"] as String).toList();
  }

  Future<List> currentMonthDailyTransactions({int? accountId}) async {
    final today = DateTime.now();
    final currentMonth = today.month;
    final currentYear = today.year;

    final beginningCurrentMonth = DateTime(currentYear, currentMonth, 1);
    final beginningNextMonth = DateTime(currentYear, currentMonth + 1, 1);

    return _transactionByFrequencyAndPeriod(
      accountId: accountId,
      recurrence: Recurrence.daily,
      dateRangeStart: beginningCurrentMonth,
      dateRangeEnd: beginningNextMonth,
    );
  }

  Future<List> lastMonthDailyTransactions() async {
    final today = DateTime.now();
    final currentMonth = today.month;
    final currentYear = today.year;

    final beginningCurrentMonth = DateTime(currentYear, currentMonth, 1);
    final beginningLastMonth = DateTime(currentYear, currentMonth - 1, 1);

    return _transactionByFrequencyAndPeriod(
      recurrence: Recurrence.daily,
      dateRangeStart: beginningLastMonth,
      dateRangeEnd: beginningCurrentMonth,
    );
  }

  Future<List> currentYearMontlyTransactions() async {
    final today = DateTime.now();
    final currentYear = today.year;

    final beginningCurrentYear = DateTime(currentYear, 1, 1);
    final beginningNextMonth = DateTime(currentYear + 1, 1, 1);

    return _transactionByFrequencyAndPeriod(
      recurrence: Recurrence.monthly,
      dateRangeStart: beginningCurrentYear,
      dateRangeEnd: beginningNextMonth,
    );
  }

  Future<List> _transactionByFrequencyAndPeriod({
    int? accountId,
    Recurrence recurrence = Recurrence.daily,
    DateTime? dateRangeStart,
    DateTime? dateRangeEnd,
  }) async {
    final db = await database;

    //TODO: validate parameters

    var freqencyString = "";
    var frequencyDateParser = "";
    switch (recurrence) {
      case Recurrence.daily:
        freqencyString = "day";
        frequencyDateParser = "%Y-%m-%d";
        break;
      case Recurrence.monthly:
        freqencyString = "month";
        frequencyDateParser = "%Y-%m";
        break;
      default:
        throw ArgumentError("Query not implemented for frequency $recurrence");
    }

    final accountFilter =
        accountId != null ? "${TransactionFields.idBankAccount} = $accountId" : "";
    //var periodDateFormatter = "";
    final periodFilterStart = dateRangeStart != null
        ? "strftime('%Y-%m-%d', ${TransactionFields.date}) >= '${dateRangeStart.toString().substring(0, 10)}'"
        : "";
    final periodFilterEnd = dateRangeEnd != null
        ? "strftime('%Y-%m-%d', ${TransactionFields.date}) < '${dateRangeEnd.toString().substring(0, 10)}'"
        : "";
    final filters = [periodFilterStart, periodFilterEnd, accountFilter];
    final sqlFilters = filters.where((filter) => filter != "").join(" AND ");

    final result = await db.rawQuery('''
      SELECT
        strftime('$frequencyDateParser', t.${TransactionFields.date}) as $freqencyString,
        SUM(CASE WHEN t.${TransactionFields.type} = 'IN' THEN t.${TransactionFields.amount} ELSE 0 END) as income,
        SUM(CASE WHEN t.${TransactionFields.type} = 'OUT' THEN t.${TransactionFields.amount} ELSE 0 END) as expense
      FROM "$transactionTable" t
      JOIN $bankAccountTable b ON t.${TransactionFields.idBankAccount} = b.${BankAccountFields.id}
      WHERE $sqlFilters AND b.${BankAccountFields.countNetWorth} = 1 AND b.${BankAccountFields.active} = 1
      GROUP BY $freqencyString
    ''');

    return result;
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
