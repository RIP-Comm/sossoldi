import 'base_entity.dart';

const String bankAccountTable = 'bankAccount';

class BankAccountFields extends BaseEntityFields {
  static String id = BaseEntityFields.getId;
  static String name = 'name';
  static String symbol = 'symbol';
  static String color = 'color';
  static String startingValue = 'startingValue';
  static String active = 'active';
  static String countNetWorth = 'countNetWorth';
  static String mainAccount = 'mainAccount';
  static String total = 'total';
  static String order = 'position';
  static String createdAt = BaseEntityFields.getCreatedAt;
  static String updatedAt = BaseEntityFields.getUpdatedAt;

  static final List<String> allFields = [
    BaseEntityFields.id,
    name,
    symbol,
    color,
    startingValue,
    active,
    countNetWorth,
    mainAccount,
    order,
    BaseEntityFields.createdAt,
    BaseEntityFields.updatedAt,
  ];
}

class BankAccount extends BaseEntity {
  final String name;
  final String symbol;
  final int color;
  final num startingValue;
  final bool active;
  final bool countNetWorth;
  final bool mainAccount;
  final int order;
  final num? total;

  const BankAccount({
    super.id,
    required this.name,
    required this.symbol,
    required this.color,
    required this.startingValue,
    required this.active,
    required this.countNetWorth,
    required this.mainAccount,
    required this.order,
    this.total,
    super.createdAt,
    super.updatedAt,
  });

  BankAccount copy({
    int? id,
    String? name,
    String? symbol,
    int? color,
    num? startingValue,
    bool? active,
    bool? countNetWorth,
    bool? mainAccount,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => BankAccount(
    id: id ?? this.id,
    name: name ?? this.name,
    symbol: symbol ?? this.symbol,
    color: color ?? this.color,
    startingValue: startingValue ?? this.startingValue,
    active: active ?? this.active,
    countNetWorth: countNetWorth ?? this.countNetWorth,
    mainAccount: mainAccount ?? this.mainAccount,
    order: order ?? this.order,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    total: total,
  );

  static BankAccount fromJson(Map<String, Object?> json) => BankAccount(
    id: json[BaseEntityFields.id] as int,
    name: json[BankAccountFields.name] as String,
    symbol: json[BankAccountFields.symbol] as String,
    color: json[BankAccountFields.color] as int,
    startingValue: json[BankAccountFields.startingValue] as num,
    active: json[BankAccountFields.active] == 1 ? true : false,
    countNetWorth: json[BankAccountFields.countNetWorth] == 1 ? true : false,
    mainAccount: json[BankAccountFields.mainAccount] == 1 ? true : false,
    order: json[BankAccountFields.order] as int,
    total: json[BankAccountFields.total] as num?,
    createdAt: DateTime.parse(json[BaseEntityFields.createdAt] as String),
    updatedAt: DateTime.parse(json[BaseEntityFields.updatedAt] as String),
  );

  Map<String, Object?> toJson({bool update = false}) => {
    BaseEntityFields.id: id,
    BankAccountFields.name: name,
    BankAccountFields.symbol: symbol,
    BankAccountFields.color: color,
    BankAccountFields.startingValue: startingValue,
    BankAccountFields.active: active ? 1 : 0,
    BankAccountFields.countNetWorth: countNetWorth ? 1 : 0,
    BankAccountFields.mainAccount: mainAccount ? 1 : 0,
    BankAccountFields.order: order,
    BaseEntityFields.createdAt: update
        ? createdAt?.toIso8601String()
        : DateTime.now().toIso8601String(),
    BaseEntityFields.updatedAt: DateTime.now().toIso8601String(),
  };
}
