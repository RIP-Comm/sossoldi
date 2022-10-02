import 'package:sossoldi/model/base_entity.dart';

const String category = 'category';

class CategoryFields extends BaseEntityFields {
  static String name = 'name';

  static final List<String?> allFields = [
    BaseEntityFields.id,
    name, // PK
    BaseEntityFields.createdAt,
    BaseEntityFields.updatedAt
  ];
}

class Category extends BaseEntity {
  final String name;

  const Category(
      {int? id, required this.name, DateTime? createdAt, DateTime? updatedAt})
      : super(id: id, createdAt: createdAt, updatedAt: updatedAt);

  Category copy(
          {int? id, String? name, num? amountLimit, DateTime? updatedAt}) =>
      Category(
          id: id ?? this.id,
          name: name ?? this.name,
          createdAt: createdAt ?? this.createdAt,
          updatedAt: updatedAt ?? this.updatedAt);

  static Category fromJson(Map<String, Object?> json) => Category(
      id: json[BaseEntityFields.id] as int?,
      name: json[CategoryFields.name] as String,
      createdAt: DateTime.parse(json[BaseEntityFields.createdAt] as String),
      updatedAt: DateTime.parse(json[BaseEntityFields.updatedAt] as String));

  Map<String, Object?> toJson() => {
        BaseEntityFields.id: id,
        CategoryFields.name: name,
        BaseEntityFields.createdAt: createdAt?.toIso8601String(),
        BaseEntityFields.updatedAt: updatedAt?.toIso8601String(),
      };
}
