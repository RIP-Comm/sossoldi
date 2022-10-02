import 'package:sossoldi/model/base_entity.dart';

const String category = 'category';

class BudgetFields extends BaseEntityFields {
  static String name = 'name';

  static final List<String?> allFields = [
    BaseEntityFields.id,
    name, // PK
    BaseEntityFields.createdAt,
    BaseEntityFields.updatedAt
  ];
}

class Budget extends BaseEntity {
  final String name;

  const Budget(
      {int? id, required this.name, DateTime? createdAt, DateTime? updatedAt})
      : super(id: id, createdAt: createdAt, updatedAt: updatedAt);

  Budget copy({int? id, String? name, num? amountLimit, DateTime? updatedAt}) =>
      Budget(
          id: id ?? this.id,
          name: name ?? this.name,
          createdAt: createdAt ?? this.createdAt,
          updatedAt: updatedAt ?? this.updatedAt);

  static Budget fromJson(Map<String, Object?> json) => Budget(
      id: json[BaseEntityFields.id] as int?,
      name: json[BudgetFields.name] as String,
      createdAt: DateTime.parse(json[BaseEntityFields.createdAt] as String),
      updatedAt: DateTime.parse(json[BaseEntityFields.updatedAt] as String));

  Map<String, Object?> toJson() => {
        BaseEntityFields.id: id,
        BudgetFields.name: name,
        BaseEntityFields.createdAt: createdAt?.toIso8601String(),
        BaseEntityFields.updatedAt: updatedAt?.toIso8601String(),
      };
}
