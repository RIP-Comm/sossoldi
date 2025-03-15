import 'dart:developer' as dev;

import '../database/sossoldi_database.dart';
import 'transaction.dart';
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
  static String idBankAccount = 'idBankAccount';
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
    idBankAccount,
    lastInsertion,
    BaseEntityFields.createdAt,
    BaseEntityFields.updatedAt
  ];
}

Map<String, dynamic> recurrenciesMap = {
  'DAILY': {
      'label': 'Daily',
      'entity': 'days',
      'amount': 1
    },
  'WEEKLY': {
      'label': 'Weekly',
      'entity': 'days',
      'amount': 7
    },
  'MONTHLY': {
      'label': 'Monthly',
      'entity': 'months',
      'amount': 1
    },
  'BIMONTHLY': {
      'label': 'Bimonthly',
      'entity': 'months',
      'amount': 2
    },
  'QUARTERLY': {
      'label': 'Quarterly',
      'entity': 'months',
      'amount': 3
    },
  'SEMESTER': {
      'label': 'Half Yearly',
      'entity': 'months',
      'amount': 6
    },
  'YEARLY': {
      'label': 'Yearly',
      'entity': 'months',
      'amount': 12
    },
};

class RecurringTransaction extends BaseEntity {
  final DateTime fromDate;
  final DateTime? toDate;
  final num amount;
  final String note;
  final String recurrency;
  final int idCategory;
  final int idBankAccount;
  final DateTime? lastInsertion;

  const RecurringTransaction(
      {super.id,
      required this.fromDate,
      this.toDate,
      required this.amount,
      required this.note,
      required this.recurrency,
      required this.idCategory,
      required this.idBankAccount,
      this.lastInsertion,
      super.createdAt,
      super.updatedAt});

  RecurringTransaction copy(
          {int? id,
          DateTime? fromDate,
          DateTime? toDate,
          num? amount,
          String? note,
          String? recurrency,
          int? idCategory,
          int? idBankAccount,
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
          idBankAccount: idBankAccount ?? this.idBankAccount,
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
          idCategory: json[RecurringTransactionFields.idCategory] as int,
          idBankAccount: json[RecurringTransactionFields.idBankAccount] as int,
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
        RecurringTransactionFields.idBankAccount: idBankAccount,
        RecurringTransactionFields.lastInsertion: lastInsertion?.toIso8601String(),
        BaseEntityFields.createdAt: createdAt?.toIso8601String(),
        BaseEntityFields.updatedAt: updatedAt?.toIso8601String(),
      };
}

class RecurringTransactionMethods extends SossoldiDatabase {
  Future<RecurringTransaction?> insert(RecurringTransaction item) async {
    try{
      final db = await database;
      final id = await db.insert(recurringTransactionTable, item.toJson());
      return item.copy(id: id);
    } catch (e){
      dev.log('$e');
    }
    return null;
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

    final orderBy = '${RecurringTransactionFields.createdAt} ASC';

    final result = await db.query(recurringTransactionTable, orderBy: orderBy);

    return result.map((json) => RecurringTransaction.fromJson(json)).toList();
  }

  Future<List<RecurringTransaction>> selectAllActive() async {
    final db = await database;

    final orderBy = '${RecurringTransactionFields.createdAt} ASC';

    final result = await db.query(
      recurringTransactionTable,
      orderBy: orderBy,
      where: '${RecurringTransactionFields.toDate} IS NULL OR ${RecurringTransactionFields.toDate} > ?',
      whereArgs: [DateTime.now().toIso8601String()],
    );

    return result.map((json) => RecurringTransaction.fromJson(json)).toList();
  }

  Future<int> updateItem(RecurringTransaction item) async {
    final db = await database;

    // You can use `rawUpdate` to write the query in SQL
    return db.update(
      recurringTransactionTable,
      item.toJson(),
      where: '${RecurringTransactionFields.id} = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteById(int id) async {
    final db = await database;

    return await db.delete(recurringTransactionTable,
        where: '${RecurringTransactionFields.id} = ?',
        whereArgs: [id]);
  }

  Future<void> checkRecurringTransactions() async {
    // get all recurring transactions active
    final transactions = await selectAllActive();

    if (transactions.isEmpty) {
      return;
    }

    for (var transaction in transactions) {
      DateTime lastTransactionDate;

      try {
        lastTransactionDate = await _getLastRecurringTransactionInsertion(transaction.id ?? 0);
      } catch (e) {
        lastTransactionDate = transaction.fromDate;
      }

      String entity = recurrenciesMap[transaction.recurrency]?['entity'] ?? 'UNMAPPED';
      int entityAmt = recurrenciesMap[transaction.recurrency]?['amount'] ?? 0;

      try {
        if (entityAmt == 0) {
          throw Exception('No amount provided for entity "$entity"');
        }

        populateRecurringTransaction(entity, lastTransactionDate, transaction, entityAmt);

      } catch (e) {
        // TODO show an error to the user?
      }
    }
  }

  Future<DateTime> _getLastRecurringTransactionInsertion(int tid) async {
    if (tid == 0) {
      throw Exception('No transaction ID provided');
    }

    final db = await database;

    final result = await db.query(
      transactionTable,
      orderBy: '${TransactionFields.date} DESC',
      where: '${TransactionFields.idRecurringTransaction} = ?',
      whereArgs: [tid],
      limit: 1,
    );

    if (result.isEmpty) {
      throw Exception('No transaction found for ID $tid');
    }

    return Transaction.fromJson(result.first).date;
  }

  void populateRecurringTransaction(String scope, DateTime lastTransactionDate, RecurringTransaction transaction, int amount) {

    if (amount == 0) {
      throw Exception('No amount provided for entity "$scope"');
    }

    DateTime now = DateTime.now();

    // create a list to store the months
    List<DateTime> transactions2Add = [];

    // calculate the number of periods between the current date and the last transaction insertion
    int periods;

    switch (scope) {
      case 'days':
        periods = (now.difference(lastTransactionDate).inDays/amount).floor();
        break;
      case 'months':
        periods = (((now.year - lastTransactionDate.year) * 12 + now.month - lastTransactionDate.month)/amount).floor();
        break;
      default:
        throw Exception('No scope provided');
    }

    // for each period passed, insert a new transaction
    for (int i = 0; i < periods; i++) {
      switch (scope) {
        case 'days':
          lastTransactionDate = DateTime(lastTransactionDate.year, lastTransactionDate.month, lastTransactionDate.day + amount);
          break;
        case 'months':
          // get the last day of the next period
          int lastDayOfNextPeriod = DateTime(lastTransactionDate.year, (lastTransactionDate.month + amount + 1), 0).day;
          int dayOfInsertion = transaction.fromDate.day;

          // if the next period's month has fewer days than the day of the last transaction insertion, adjust the day
          if (transaction.fromDate.day > lastDayOfNextPeriod) {
            dayOfInsertion = lastDayOfNextPeriod;
          }

          lastTransactionDate = DateTime(lastTransactionDate.year, lastTransactionDate.month + amount, dayOfInsertion);

          break;
        default:
        //nothing to do
          return;
      }

      if ((transaction.toDate?.isAfter(lastTransactionDate) ?? true) && lastTransactionDate.isBefore(DateTime.now())) {
        transactions2Add.add(lastTransactionDate);
      }

    }

    for (var tr in transactions2Add) {
      // insert a new transaction

      Transaction addTr = Transaction(
        date: tr,
        amount: transaction.amount,
        type: TransactionType.expense,
        note: transaction.note,
        idCategory: transaction.idCategory,
        idBankAccount: transaction.idBankAccount,
        recurring: true,
        idRecurringTransaction: transaction.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      TransactionMethods().insert(addTr);
    }

    // update the last insertion date
    updateItem(transaction.copy(lastInsertion: now));

  }

}