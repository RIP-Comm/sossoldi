import 'package:sossoldi/model/base_entity.dart';

const String transaction = 'transaction';

class TransactionFields extends BaseEntityFields {
  static String date = 'date';
  static String amount = 'amount';
  static String type = 'type';
  static String note = 'note';
  static String nameBankAccount = 'nameBankAccount'; // FK
  static String nameBudget = 'nameBudget'; // FK
  static String nameCategory = 'nameCategory'; // FK

  static final List<String?> allFields = [
    BaseEntityFields.id,
    date,
    amount,
    type,
    note,
    nameBankAccount,
    nameBudget,
    nameCategory,
    BaseEntityFields.createdAt,
    BaseEntityFields.updatedAt
  ];
}

enum Type { income, expense, transfer }

class Transaction extends BaseEntity {
  final DateTime date;
  final int amount;
  final Type type;
  final String? note;
  final int nameBankAccount;
  final String nameBudget;
  final int nameCategory;

  const Transaction(
      {int? id,
      required this.date,
      required this.amount,
      required this.type,
      this.note,
      required this.nameBankAccount,
      required this.nameBudget,
      required this.nameCategory,
      DateTime? createdAt,
      DateTime? updatedAt})
      : super(id: id, createdAt: createdAt, updatedAt: updatedAt);

  Transaction copy(
          {int? id,
          DateTime? date,
          int? amount,
          Type? type,
          String? note,
          int? nameBankAccount,
          String? nameBudget,
          int? nameCategory,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Transaction(
          id: id ?? this.id,
          date: date ?? this.date,
          amount: amount ?? this.amount,
          type: type ?? this.type,
          note: note ?? this.note,
          nameBankAccount: nameBankAccount ?? this.nameBankAccount,
          nameBudget: nameBudget ?? this.nameBudget,
          nameCategory: nameCategory ?? this.nameCategory,
          createdAt: createdAt ?? this.createdAt,
          updatedAt: updatedAt ?? this.updatedAt);

  static Transaction fromJson(Map<String, Object?> json) => Transaction(
      id: json[BaseEntityFields.id] as int?,
      date: DateTime.parse(json[TransactionFields.date] as String),
      amount: json[TransactionFields.amount] as int,
      type: Type.values[json[TransactionFields.type] as int],
      note: json[TransactionFields.note] as String,
      nameBankAccount: json[TransactionFields.nameBankAccount] as int,
      nameBudget: json[TransactionFields.nameBudget] as String,
      nameCategory: json[TransactionFields.nameCategory] as int,
      createdAt: DateTime.parse(json[BaseEntityFields.createdAt] as String),
      updatedAt: DateTime.parse(json[BaseEntityFields.updatedAt] as String));

  Map<String, Object?> toJson() => {
        BaseEntityFields.id: id,
        TransactionFields.date: date.toIso8601String(),
        TransactionFields.amount: amount,
        TransactionFields.type: type.index,
        TransactionFields.note: note,
        TransactionFields.nameBankAccount: nameBankAccount,
        TransactionFields.nameBudget: nameBudget,
        TransactionFields.nameCategory: nameCategory,
        BaseEntityFields.createdAt: createdAt?.toIso8601String(),
        BaseEntityFields.updatedAt: updatedAt?.toIso8601String(),
      };
}
