import 'package:sossoldi/model/base_entity.dart';

const String categoryTransaction = 'category_transaction';

class CategoryTransactionFields extends BaseEntityFields {
  static String name = 'name';

  static final List<String?> allFields = [
    BaseEntityFields.id,
    name, // PK
    BaseEntityFields.createdAt,
    BaseEntityFields.updatedAt
  ];
}

class CategoryTransaction extends BaseEntity {
  final String name;

  const CategoryTransaction(
      {int? id, required this.name, DateTime? createdAt, DateTime? updatedAt})
      : super(id: id, createdAt: createdAt, updatedAt: updatedAt);

  CategoryTransaction copy(
          {int? id,
          String? name,
          num? amountLimit,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      CategoryTransaction(
          id: id ?? this.id,
          name: name ?? this.name,
          createdAt: createdAt ?? this.createdAt,
          updatedAt: updatedAt ?? this.updatedAt);

  static CategoryTransaction fromJson(Map<String, Object?> json) =>
      CategoryTransaction(
          id: json[BaseEntityFields.id] as int?,
          name: json[CategoryTransactionFields.name] as String,
          createdAt: DateTime.parse(json[BaseEntityFields.createdAt] as String),
          updatedAt:
              DateTime.parse(json[BaseEntityFields.updatedAt] as String));

  Map<String, Object?> toJson() => {
        BaseEntityFields.id: id,
        CategoryTransactionFields.name: name,
        BaseEntityFields.createdAt: createdAt?.toIso8601String(),
        BaseEntityFields.updatedAt: updatedAt?.toIso8601String(),
      };
}
