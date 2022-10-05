import 'dart:ffi';

import 'package:sossoldi/model/base_entity.dart';

const String recurringTransaction = 'recurringTransaction';

class RecurringTransactionFields extends BaseEntityFields {
  static String from = 'from';
  static String to = 'to';
  static String payDay = 'payDay';

  static final List<String?> allFields = [
    BaseEntityFields.id,
    from,
    to,
    payDay,
    BaseEntityFields.createdAt,
    BaseEntityFields.updatedAt
  ];
}

class Transaction extends BaseEntity {
  final DateTime from;
  final DateTime to;
  final Uint8 payDay;

  const Transaction(
      {int? id,
      required this.from,
      required this.to,
      required this.payDay,
      DateTime? createdAt,
      DateTime? updatedAt})
      : super(id: id, createdAt: createdAt, updatedAt: updatedAt);

  Transaction copy(
          {int? id,
          DateTime? from,
          DateTime? to,
          Uint8? payDay,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Transaction(
          id: id ?? this.id,
          from: from ?? this.from,
          to: to ?? this.to,
          payDay: payDay ?? this.payDay,
          createdAt: createdAt ?? this.createdAt,
          updatedAt: updatedAt ?? this.updatedAt);

  static Transaction fromJson(Map<String, Object?> json) => Transaction(
      id: json[BaseEntityFields.id] as int?,
      from: DateTime.parse(json[RecurringTransactionFields.from] as String),
      to: DateTime.parse(json[RecurringTransactionFields.to] as String),
      payDay: json[RecurringTransactionFields.payDay] as Uint8,
      createdAt: DateTime.parse(json[BaseEntityFields.createdAt] as String),
      updatedAt: DateTime.parse(json[BaseEntityFields.updatedAt] as String));

  Map<String, Object?> toJson() => {
        BaseEntityFields.id: id,
        RecurringTransactionFields.from: from.toIso8601String(),
        RecurringTransactionFields.to: to.toIso8601String(),
        RecurringTransactionFields.payDay: payDay,
        BaseEntityFields.createdAt: createdAt?.toIso8601String(),
        BaseEntityFields.updatedAt: updatedAt?.toIso8601String(),
      };
}
