import 'package:sossoldi/model/base_entity.dart';

const String bankAccount = 'bankAccount';

class BankAccountFields extends BaseEntityFields {
  static String name = 'name';
  static String value = 'value';

  static final List<String?> allFields = [
    BaseEntityFields.id,
    name,
    value,
    BaseEntityFields.createdAt,
    BaseEntityFields.updatedAt
  ];
}

class BankAccount extends BaseEntity {
  final String name;
  final num value;

  const BankAccount(
      {int? id,
      required this.name,
      required this.value,
      DateTime? createdAt,
      DateTime? updatedAt})
      : super(id: id, createdAt: createdAt, updatedAt: updatedAt);

  BankAccount copy(
          {int? id,
          String? name,
          num? value,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      BankAccount(
          id: id ?? this.id,
          name: name ?? this.name,
          value: value ?? this.value,
          createdAt: createdAt ?? this.createdAt,
          updatedAt: updatedAt ?? this.updatedAt);

  static BankAccount fromJson(Map<String, Object?> json) => BankAccount(
      id: json[BaseEntityFields.id] as int?,
      name: json[BankAccountFields.name] as String,
      value: json[BankAccountFields.value] as num,
      createdAt: DateTime.parse(json[BaseEntityFields.createdAt] as String),
      updatedAt: DateTime.parse(json[BaseEntityFields.updatedAt] as String));

  Map<String, Object?> toJson() => {
        BaseEntityFields.id: id,
        BankAccountFields.name: name,
        BankAccountFields.value: value,
        BaseEntityFields.createdAt: createdAt?.toIso8601String(),
        BaseEntityFields.updatedAt: updatedAt?.toIso8601String(),
      };
}
