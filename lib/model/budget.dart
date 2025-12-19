import 'base_entity.dart';

const String budgetTable = 'budget';

class BudgetFields extends BaseEntityFields {
  static String id = BaseEntityFields.getId;
  static String name = 'name';
  static String idCategory = 'idCategory'; // FK
  static String amountLimit = 'amountLimit';
  static String active = 'active';
  static String createdAt = BaseEntityFields.getCreatedAt;
  static String updatedAt = BaseEntityFields.getUpdatedAt;

  static final List<String> allFields = [
    BaseEntityFields.id,
    idCategory,
    name,
    amountLimit,
    active,
    BaseEntityFields.createdAt,
    BaseEntityFields.updatedAt,
  ];
}

class Budget extends BaseEntity {
  final int idCategory;
  final String? name;
  final num amountLimit;
  final bool active;

  const Budget({
    super.id,
    required this.idCategory,
    this.name,
    required this.amountLimit,
    required this.active,
    super.createdAt,
    super.updatedAt,
  });

  Budget copy({
    int? id,
    int? idCategory,
    String? name,
    num? amountLimit,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Budget(
    id: id ?? this.id,
    idCategory: idCategory ?? this.idCategory,
    name: name ?? this.name,
    amountLimit: amountLimit ?? this.amountLimit,
    active: active ?? this.active,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  static Budget fromJson(Map<String, Object?> json) => Budget(
    id: json[BaseEntityFields.id] as int,
    idCategory: json[BudgetFields.idCategory] as int,
    name: json[BudgetFields.name] as String?,
    amountLimit: json[BudgetFields.amountLimit] as num,
    active: json[BudgetFields.active] == 1 ? true : false,
    createdAt: DateTime.parse(json[BaseEntityFields.createdAt] as String),
    updatedAt: DateTime.parse(json[BaseEntityFields.updatedAt] as String),
  );

  Map<String, Object?> toJson({bool update = false}) => {
    BaseEntityFields.id: id,
    BudgetFields.idCategory: idCategory,
    BudgetFields.name: name,
    BudgetFields.amountLimit: amountLimit,
    BudgetFields.active: active ? 1 : 0,
    BaseEntityFields.createdAt: update
        ? createdAt?.toIso8601String()
        : DateTime.now().toIso8601String(),
    BaseEntityFields.updatedAt: DateTime.now().toIso8601String(),
  };
}

class BudgetStats extends BaseEntity {
  final int idCategory;
  final String? name;
  final num amountLimit;
  final num spent;

  BudgetStats({
    required this.idCategory,
    required this.name,
    required this.amountLimit,
    required this.spent,
  });

  static BudgetStats fromJson(Map<String, Object?> json) => BudgetStats(
    idCategory: json[BudgetFields.idCategory] as int,
    name: json[BudgetFields.name] as String?,
    amountLimit: json[BudgetFields.amountLimit] as num,
    spent: json['spent'] as num,
  );

  Map<String, Object?> toJson() => {
    BudgetFields.idCategory: idCategory,
    BudgetFields.name: name,
    BudgetFields.amountLimit: amountLimit,
    'spent': spent,
  };
}
