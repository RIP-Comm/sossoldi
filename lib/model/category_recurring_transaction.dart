import 'package:sossoldi/model/base_entity.dart';

const String categoryRecurringTransaction = 'categoryRecurringTransaction';

class CategoryRecurringTransactionFields extends BaseEntityFields {
  static String name = 'name';
  static String symbol = 'symbol'; // Short name
  static String note = 'note';

  static final List<String?> allFields = [
    BaseEntityFields.id,
    name, // PK
    symbol,
    note,
    BaseEntityFields.createdAt,
    BaseEntityFields.updatedAt
  ];
}

class CategoryRecurringTransaction extends BaseEntity {
  final String name;
  final String? symbol;
  final String? note;

  const CategoryRecurringTransaction(
      {int? id,
      required this.name,
      this.symbol,
      this.note,
      DateTime? createdAt,
      DateTime? updatedAt})
      : super(id: id, createdAt: createdAt, updatedAt: updatedAt);

  CategoryRecurringTransaction copy(
          {int? id,
          String? name,
          String? symbol,
          String? note,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      CategoryRecurringTransaction(
          id: id ?? this.id,
          name: name ?? this.name,
          symbol: symbol ?? this.symbol,
          note: note ?? this.note,
          createdAt: createdAt ?? this.createdAt,
          updatedAt: updatedAt ?? this.updatedAt);

  static CategoryRecurringTransaction fromJson(Map<String, Object?> json) =>
      CategoryRecurringTransaction(
          id: json[BaseEntityFields.id] as int?,
          name: json[CategoryRecurringTransactionFields.name] as String,
          symbol: json[CategoryRecurringTransactionFields.symbol] as String,
          note: json[CategoryRecurringTransactionFields.note] as String,
          createdAt: DateTime.parse(json[BaseEntityFields.createdAt] as String),
          updatedAt:
              DateTime.parse(json[BaseEntityFields.updatedAt] as String));

  Map<String, Object?> toJson() => {
        BaseEntityFields.id: id,
        CategoryRecurringTransactionFields.name: name,
        CategoryRecurringTransactionFields.symbol: symbol,
        CategoryRecurringTransactionFields.note: note,
        BaseEntityFields.createdAt: createdAt?.toIso8601String(),
        BaseEntityFields.updatedAt: updatedAt?.toIso8601String(),
      };
}
