final String tableCategory = 'category';

class CategoryFields {
  static const String id = 'id';
  static const String name = 'name';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';

  static const List<String> allFields = [id, name, createdAt, updatedAt];
}

class CategoryModel {
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel(
      {required this.id,
      required this.name,
      required this.createdAt,
      required this.updatedAt});

  static CategoryModel fromJson(Map<String, dynamic> json) => CategoryModel(
      id: json[CategoryFields.id] as int,
      name: json[CategoryFields.name],
      createdAt: DateTime.parse(json[CategoryFields.createdAt]),
      updatedAt: DateTime.parse(json[CategoryFields.updatedAt]));

  Map<String, dynamic> toJson() => {
        CategoryFields.id: id,
        CategoryFields.name: name,
        CategoryFields.createdAt: createdAt.toIso8601String(),
        CategoryFields.updatedAt: updatedAt.toIso8601String()
      };
}
