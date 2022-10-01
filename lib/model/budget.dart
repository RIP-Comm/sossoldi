import 'package:sossoldi/model/base_entity.dart';

const String budget = 'budget';

class BudgetFields extends BaseEntityFields {
  static String name = 'name';
  static String amountLimit = 'amountLimit';

  static final List<String?> allFields = [
    BaseEntityFields.id,
    name, // PK
    amountLimit,
    BaseEntityFields.createdAt,
    BaseEntityFields.updatedAt
  ];
}

class Budget extends BaseEntity {
  final String name;
  final num amountLimit;

  const Budget(
      {int? id,
      required this.name,
      required this.amountLimit,
      DateTime? createdAt,
      DateTime? updatedAt})
      : super(id: id, createdAt: createdAt, updatedAt: updatedAt);

  Budget copy(
          {int? id,
          String? name,
          num? amountLimit,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Budget(
          id: id ?? this.id,
          name: name ?? this.name,
          amountLimit: amountLimit ?? this.amountLimit,
          createdAt: createdAt ?? this.createdAt,
          updatedAt: updatedAt ?? this.updatedAt);

  static Budget fromJson(Map<String, Object?> json) => Budget(
      id: json[BaseEntityFields.id] as int?,
      name: json[BudgetFields.name] as String,
      amountLimit: json[BudgetFields.amountLimit] as num,
      createdAt: DateTime.parse(json[BaseEntityFields.createdAt] as String),
      updatedAt: DateTime.parse(json[BaseEntityFields.updatedAt] as String));

  Map<String, Object?> toJson() => {
        BaseEntityFields.id: id,
        BudgetFields.name: name,
        BudgetFields.amountLimit: amountLimit,
        BaseEntityFields.createdAt: createdAt?.toIso8601String(),
        BaseEntityFields.updatedAt: updatedAt?.toIso8601String(),
      };
}
