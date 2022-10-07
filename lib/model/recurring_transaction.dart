import 'package:sossoldi/model/base_entity.dart';

const String recurringTransaction = 'recurringTransaction';

class RecurringTransactionFields extends BaseEntityFields {
  static String from = 'from';
  static String to = 'to';
  static String payDay = 'payDay';
  static String idCategoryRecurring = 'idCategoryRecurring'; // FK

  static final List<String?> allFields = [
    BaseEntityFields.id,
    from,
    to,
    payDay,
    idCategoryRecurring,
    BaseEntityFields.createdAt,
    BaseEntityFields.updatedAt
  ];
}

class RecurringTransaction extends BaseEntity {
  final DateTime from;
  final DateTime to;
  final int payDay;
  final int? idCategoryRecurring;

  const RecurringTransaction(
      {int? id,
      required this.from,
      required this.to,
      required this.payDay,
      this.idCategoryRecurring,
      DateTime? createdAt,
      DateTime? updatedAt})
      : super(id: id, createdAt: createdAt, updatedAt: updatedAt);

  RecurringTransaction copy(
          {int? id,
          DateTime? from,
          DateTime? to,
          int? payDay,
          int? idCategoryRecurring,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      RecurringTransaction(
          id: id ?? this.id,
          from: from ?? this.from,
          to: to ?? this.to,
          payDay: payDay ?? this.payDay,
          idCategoryRecurring: idCategoryRecurring ?? this.idCategoryRecurring,
          createdAt: createdAt ?? this.createdAt,
          updatedAt: updatedAt ?? this.updatedAt);

  static RecurringTransaction fromJson(Map<String, Object?> json) =>
      RecurringTransaction(
          id: json[BaseEntityFields.id] as int?,
          from: DateTime.parse(json[RecurringTransactionFields.from] as String),
          to: DateTime.parse(json[RecurringTransactionFields.to] as String),
          payDay: json[RecurringTransactionFields.payDay] as int,
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
        RecurringTransactionFields.idCategoryRecurring: idCategoryRecurring,
        BaseEntityFields.createdAt: createdAt?.toIso8601String(),
        BaseEntityFields.updatedAt: updatedAt?.toIso8601String(),
      };
}
