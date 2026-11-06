import '../ui/extensions.dart';
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
  static String deletedAt = BaseEntityFields.getDeletedAt;
  static String ebAccountUid = 'ebAccountUid';
  static String ebConnectionId = 'ebConnectionId';
  static String identificationHash = 'identificationHash';
  static String identificationHashes = 'identificationHashes';
  static String iban = 'iban';
  static String lastSyncAt = 'lastSyncAt';
  static String currencyCode = 'currencyCode';

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
    BaseEntityFields.deletedAt,
    ebAccountUid,
    ebConnectionId,
    identificationHash,
    identificationHashes,
    iban,
    lastSyncAt,
    currencyCode,
  ];
}

class BankAccount extends BaseEntity {
  static const _unset = Object();

  final String name;
  final String symbol;
  final int color;
  final num startingValue;
  final bool active;
  final bool countNetWorth;
  final bool mainAccount;
  final int order;
  final num? total;
  final String? ebAccountUid;
  final int? ebConnectionId;
  final String? identificationHash;
  final String? identificationHashes;
  final String? iban;
  final DateTime? lastSyncAt;
  final String? currencyCode;

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
    this.ebAccountUid,
    this.ebConnectionId,
    this.identificationHash,
    this.identificationHashes,
    this.iban,
    this.lastSyncAt,
    this.currencyCode,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
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
    DateTime? deletedAt,
    Object? ebAccountUid = _unset,
    Object? ebConnectionId = _unset,
    Object? identificationHash = _unset,
    Object? identificationHashes = _unset,
    Object? iban = _unset,
    Object? lastSyncAt = _unset,
    Object? currencyCode = _unset,
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
    deletedAt: deletedAt ?? this.deletedAt,
    total: total,
    ebAccountUid: ebAccountUid == _unset
        ? this.ebAccountUid
        : ebAccountUid as String?,
    ebConnectionId: ebConnectionId == _unset
        ? this.ebConnectionId
        : ebConnectionId as int?,
    identificationHash: identificationHash == _unset
        ? this.identificationHash
        : identificationHash as String?,
    identificationHashes: identificationHashes == _unset
        ? this.identificationHashes
        : identificationHashes as String?,
    iban: iban == _unset ? this.iban : iban as String?,
    lastSyncAt: lastSyncAt == _unset
        ? this.lastSyncAt
        : lastSyncAt as DateTime?,
    currencyCode: currencyCode == _unset
        ? this.currencyCode
        : currencyCode as String?,
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
    deletedAt: json[BaseEntityFields.deletedAt] != null
        ? DateTime.parse(json[BaseEntityFields.deletedAt] as String)
        : null,
    ebAccountUid: json[BankAccountFields.ebAccountUid] as String?,
    ebConnectionId: json[BankAccountFields.ebConnectionId] as int?,
    identificationHash: json[BankAccountFields.identificationHash] as String?,
    identificationHashes:
        json[BankAccountFields.identificationHashes] as String?,
    iban: json[BankAccountFields.iban] as String?,
    lastSyncAt: json[BankAccountFields.lastSyncAt] == null
        ? null
        : DateTime.parse(json[BankAccountFields.lastSyncAt] as String).toUtc(),
    currencyCode: json[BankAccountFields.currencyCode] as String?,
  );

  Map<String, Object?> toJson({bool update = false, bool delete = false}) => {
    BaseEntityFields.id: id,
    BankAccountFields.name: name,
    BankAccountFields.symbol: symbol,
    BankAccountFields.color: color,
    BankAccountFields.startingValue: startingValue.toCurrency().toNum(),
    BankAccountFields.active: active && !delete ? 1 : 0,
    BankAccountFields.countNetWorth: countNetWorth && !delete ? 1 : 0,
    BankAccountFields.mainAccount: mainAccount && !delete ? 1 : 0,
    BankAccountFields.order: delete ? 0 : order,
    BaseEntityFields.createdAt: update || delete
        ? createdAt?.toIso8601String()
        : DateTime.now().toIso8601String(),
    BaseEntityFields.updatedAt: DateTime.now().toIso8601String(),
    if (delete) BaseEntityFields.deletedAt: DateTime.now().toIso8601String(),
    BankAccountFields.ebAccountUid: ebAccountUid,
    BankAccountFields.ebConnectionId: ebConnectionId,
    BankAccountFields.identificationHash: identificationHash,
    BankAccountFields.identificationHashes: identificationHashes,
    BankAccountFields.iban: iban,
    BankAccountFields.lastSyncAt: lastSyncAt?.toUtc().toIso8601String(),
    BankAccountFields.currencyCode: currencyCode,
  };
}
