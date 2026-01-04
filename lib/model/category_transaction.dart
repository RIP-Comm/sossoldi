import 'base_entity.dart';
import 'transaction.dart';

const String categoryTransactionTable = 'categoryTransaction';

class CategoryTransactionFields extends BaseEntityFields {
  static String id = BaseEntityFields.getId;
  static String name = 'name';
  static String type = 'type';
  static String symbol = 'symbol';
  static String color = 'color';
  static String note = 'note';
  static String parent = 'parent';
  static String order = 'position';
  static String createdAt = BaseEntityFields.getCreatedAt;
  static String updatedAt = BaseEntityFields.getUpdatedAt;

  static final List<String> allFields = [
    BaseEntityFields.id,
    name,
    type,
    symbol,
    color,
    note,
    parent,
    order,
    BaseEntityFields.createdAt,
    BaseEntityFields.updatedAt,
  ];
}

enum CategoryTransactionType {
  income,
  expense;

  String get code => switch (this) {
    CategoryTransactionType.income => "IN",
    CategoryTransactionType.expense => "OUT",
  };

  TransactionType get transactionType => switch (this) {
    CategoryTransactionType.income => TransactionType.income,
    CategoryTransactionType.expense => TransactionType.expense,
  };

  static CategoryTransactionType fromJson(String value) {
    switch (value) {
      case "IN":
        return CategoryTransactionType.income;
      case "OUT":
        return CategoryTransactionType.expense;
      default:
        throw ArgumentError('Invalid : $value');
    }
  }
}

class CategoryTransaction extends BaseEntity {
  final String name;
  final CategoryTransactionType type;
  final String symbol;
  final int color;
  final String? note;
  final int? parent;
  final int order;

  const CategoryTransaction({
    super.id,
    required this.name,
    required this.type,
    required this.symbol,
    required this.color,
    this.note,
    this.parent,
    required this.order,
    super.createdAt,
    super.updatedAt,
  });

  CategoryTransaction copy({
    int? id,
    String? name,
    CategoryTransactionType? type,
    String? symbol,
    int? color,
    String? note,
    int? parent,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CategoryTransaction(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    symbol: symbol ?? this.symbol,
    color: color ?? this.color,
    note: note ?? this.note,
    parent: parent ?? this.parent,
    order: order ?? this.order,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  static CategoryTransaction fromJson(Map<String, Object?> json) =>
      CategoryTransaction(
        id: json[BaseEntityFields.id] as int?,
        name: json[CategoryTransactionFields.name] as String,
        type: CategoryTransactionType.fromJson(
          json[CategoryTransactionFields.type] as String,
        ),
        symbol: json[CategoryTransactionFields.symbol] as String,
        color: json[CategoryTransactionFields.color] as int,
        note: json[CategoryTransactionFields.note] as String?,
        parent: json[CategoryTransactionFields.parent] as int?,
        order: json[CategoryTransactionFields.order] as int,
        createdAt: DateTime.parse(json[BaseEntityFields.createdAt] as String),
        updatedAt: DateTime.parse(json[BaseEntityFields.updatedAt] as String),
      );

  Map<String, Object?> toJson({bool update = false}) => {
    BaseEntityFields.id: id,
    CategoryTransactionFields.name: name,
    CategoryTransactionFields.type: type.code,
    CategoryTransactionFields.symbol: symbol,
    CategoryTransactionFields.color: color,
    CategoryTransactionFields.note: note,
    CategoryTransactionFields.parent: parent,
    CategoryTransactionFields.order: order,
    BaseEntityFields.createdAt: update
        ? createdAt?.toIso8601String()
        : DateTime.now().toIso8601String(),
    BaseEntityFields.updatedAt: DateTime.now().toIso8601String(),
  };
}
