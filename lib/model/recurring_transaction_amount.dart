import 'base_entity.dart';

const String recurringTransactionAmountTable = 'recurringTransactionAmount';

class RecurringTransactionAmountFields extends BaseEntityFields {
  static String id = 'id';
  static String from = 'from';
  static String to = 'to';
  static String amount = 'amount';
  static String idRecurringTransaction = 'idRecurringTransaction'; // FK
  static String createdAt = 'createdAt';
  static String updatedAt = 'updatedAt';

  static final List<String?> allFields = [
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
