import '../ui/extensions.dart';
import 'transaction.dart';
import 'base_entity.dart';

const String recurringTransactionTable = 'recurringTransaction';

class RecurringTransactionFields extends BaseEntityFields {
  static String id = BaseEntityFields.getId;
  static String fromDate = 'fromDate';
  static String toDate = 'toDate';
  static String amount = 'amount';
  static String note = 'note';
  static String type = 'type';
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
    type,
    recurrency,
    idCategory,
    idBankAccount,
    lastInsertion,
    BaseEntityFields.createdAt,
    BaseEntityFields.updatedAt,
  ];
}

enum Recurrence {
  daily,
  weekly,
  monthly,
  bimonthly,
  quarterly,
  semester,
  annual;

  String get label => name.capitalize();

  int get days {
    switch (this) {
      case Recurrence.daily:
        return 1;
      case Recurrence.weekly:
        return 7;
      case Recurrence.monthly:
        return 30;
      case Recurrence.bimonthly:
        return 60;
      case Recurrence.quarterly:
        return 90;
      case Recurrence.semester:
        return 180;
      case Recurrence.annual:
        return 365;
    }
  }

  String get entity {
    switch (this) {
      case Recurrence.daily:
      case Recurrence.weekly:
        return 'days';
      case Recurrence.monthly:
      case Recurrence.bimonthly:
      case Recurrence.quarterly:
      case Recurrence.semester:
      case Recurrence.annual:
        return 'months';
    }
  }

  int get amount {
    switch (this) {
      case Recurrence.daily:
        return 1;
      case Recurrence.weekly:
        return 7;
      case Recurrence.monthly:
        return 1;
      case Recurrence.bimonthly:
        return 2;
      case Recurrence.quarterly:
        return 3;
      case Recurrence.semester:
        return 6;
      case Recurrence.annual:
        return 12;
    }
  }

  static Recurrence fromJson(String value) =>
      Recurrence.values.firstWhere((e) => e.name.toUpperCase() == value);

  String toJson() => name.toUpperCase();
}

class RecurringTransaction extends BaseEntity {
  final DateTime fromDate;
  final DateTime? toDate;
  final num amount;
  final String note;
  final Recurrence recurrency;
  final int idCategory;
  final int idBankAccount;
  final TransactionType type;
  final DateTime? lastInsertion;

  const RecurringTransaction({
    super.id,
    required this.fromDate,
    this.toDate,
    required this.amount,
    required this.note,
    required this.recurrency,
    required this.idCategory,
    required this.type,
    required this.idBankAccount,
    this.lastInsertion,
    super.createdAt,
    super.updatedAt,
  });

  RecurringTransaction copy({
    int? id,
    DateTime? fromDate,
    DateTime? toDate,
    num? amount,
    String? note,
    Recurrence? recurrency,
    int? idCategory,
    TransactionType? type,
    int? idBankAccount,
    DateTime? lastInsertion,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => RecurringTransaction(
    id: id ?? this.id,
    fromDate: fromDate ?? this.fromDate,
    toDate: toDate ?? this.toDate,
    amount: amount ?? this.amount,
    note: note ?? this.note,
    recurrency: recurrency ?? this.recurrency,
    idCategory: idCategory ?? this.idCategory,
    type: type ?? this.type,
    idBankAccount: idBankAccount ?? this.idBankAccount,
    lastInsertion: lastInsertion ?? this.lastInsertion,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  static RecurringTransaction fromJson(Map<String, Object?> json) =>
      RecurringTransaction(
        id: json[BaseEntityFields.id] as int?,
        fromDate: DateTime.parse(
          json[RecurringTransactionFields.fromDate] as String,
        ),
        toDate: json[RecurringTransactionFields.toDate] != null
            ? DateTime.parse(json[RecurringTransactionFields.toDate] as String)
            : null,
        amount: json[RecurringTransactionFields.amount] as num,
        note: json[RecurringTransactionFields.note] as String,
        recurrency: Recurrence.fromJson(
          json[RecurringTransactionFields.recurrency] as String,
        ),
        idCategory: json[RecurringTransactionFields.idCategory] as int,
        type: TransactionType.fromJson(
          json[RecurringTransactionFields.type] as String,
        ),
        idBankAccount: json[RecurringTransactionFields.idBankAccount] as int,
        lastInsertion: json[RecurringTransactionFields.lastInsertion] != null
            ? DateTime.parse(
                json[RecurringTransactionFields.lastInsertion] as String,
              )
            : null,
        createdAt: DateTime.parse(json[BaseEntityFields.createdAt] as String),
        updatedAt: DateTime.parse(json[BaseEntityFields.updatedAt] as String),
      );

  Map<String, Object?> toJson() => {
    BaseEntityFields.id: id,
    RecurringTransactionFields.fromDate: fromDate.toIso8601String(),
    RecurringTransactionFields.toDate: toDate?.toIso8601String(),
    RecurringTransactionFields.amount: amount,
    RecurringTransactionFields.note: note,
    RecurringTransactionFields.type: type.toJson(),
    RecurringTransactionFields.recurrency: recurrency.toJson(),
    RecurringTransactionFields.idCategory: idCategory,
    RecurringTransactionFields.idBankAccount: idBankAccount,
    RecurringTransactionFields.lastInsertion: lastInsertion?.toIso8601String(),
    BaseEntityFields.createdAt: createdAt?.toIso8601String(),
    BaseEntityFields.updatedAt: updatedAt?.toIso8601String(),
  };
}
