import 'package:sqflite/sqflite.dart';

import '../database/sossoldi_database.dart';
import 'base_entity.dart';

const String bankAccountTable = 'bankAccount';

class BankAccountFields extends BaseEntityFields {
  static String id = BaseEntityFields.getId;
  static String name = 'name';
  static String symbol = 'symbol';
  static String color = 'color';
  static String value = 'value';
  static String active = 'active';
  static String mainAccount = 'mainAccount';
  static String createdAt = BaseEntityFields.getCreatedAt;
  static String updatedAt = BaseEntityFields.getUpdatedAt;

  static final List<String> allFields = [
    BaseEntityFields.id,
    name,
    symbol,
    color,
    value,
    active,
    mainAccount,
    BaseEntityFields.createdAt,
    BaseEntityFields.updatedAt
  ];
}

class BankAccount extends BaseEntity {
  final String name;
  final String symbol;
  final int color;
  final num value;
  final bool active;
  final bool mainAccount;

  const BankAccount(
      {int? id,
      required this.name,
      required this.symbol,
      required this.color,
      required this.value,
      required this.mainAccount,
      required this.active,
      DateTime? createdAt,
      DateTime? updatedAt})
      : super(id: id, createdAt: createdAt, updatedAt: updatedAt);

  BankAccount copy(
          {int? id,
          String? name,
          String? symbol,
          int? color,
          num? value,
          bool? active,
          bool? mainAccount,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      BankAccount(
          id: id ?? this.id,
          name: name ?? this.name,
          symbol: symbol ?? this.symbol,
          color: color ?? this.color,
          value: value ?? this.value,
          active: active ?? this.active,
          mainAccount: mainAccount ?? this.mainAccount,
          createdAt: createdAt ?? this.createdAt,
          updatedAt: updatedAt ?? this.updatedAt);

  static BankAccount fromJson(Map<String, Object?> json) => BankAccount(
      id: json[BaseEntityFields.id] as int,
      name: json[BankAccountFields.name] as String,
      symbol: json[BankAccountFields.symbol] as String,
      color: json[BankAccountFields.color] as int,
      value: json[BankAccountFields.value] as num,
      active: json[BankAccountFields.active] == 1 ? true : false,
      mainAccount: json[BankAccountFields.mainAccount] == 1 ? true : false,
      createdAt: DateTime.parse(json[BaseEntityFields.createdAt] as String),
      updatedAt: DateTime.parse(json[BaseEntityFields.updatedAt] as String));

  Map<String, Object?> toJson({bool update = false}) => {
        BaseEntityFields.id: id,
        BankAccountFields.name: name,
        BankAccountFields.symbol: symbol,
        BankAccountFields.color: color,
        BankAccountFields.value: value,
        BankAccountFields.active: active ? 1 : 0,
        BankAccountFields.mainAccount: mainAccount ? 1 : 0,
        BaseEntityFields.createdAt:
            update ? createdAt?.toIso8601String() : DateTime.now().toIso8601String(),
        BaseEntityFields.updatedAt: DateTime.now().toIso8601String(),
      };
}

class BankAccountMethods extends SossoldiDatabase {
  Future<BankAccount> insert(BankAccount item) async {
    final db = await database;

    await changeMainAccount(db, item);
    
    final id = await db.insert(bankAccountTable, item.toJson());
    return item.copy(id: id);
  }

  Future<BankAccount> selectById(int id) async {
    final db = await database;

    final maps = await db.query(
      bankAccountTable,
      columns: BankAccountFields.allFields,
      where: '${BankAccountFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return BankAccount.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<BankAccount?> selectMain() async {
    final db = await database;

    final maps = await db.query(
      bankAccountTable,
      columns: BankAccountFields.allFields,
      where: '${BankAccountFields.mainAccount} = ?',
      whereArgs: [1],
    );

    if (maps.isNotEmpty) {
      return BankAccount.fromJson(maps.first);
    } else {
      throw Exception('Main Account not found');
    }
  }

  Future<List<BankAccount>> selectAll() async {
    final db = await database;

    final orderByASC = '${BankAccountFields.createdAt} ASC';
    final where = '${BankAccountFields.active}  = 1';

    final result = await db.query(bankAccountTable, where:where, orderBy: orderByASC);

    return result.map((json) => BankAccount.fromJson(json)).toList();
  }

  Future<int> updateItem(BankAccount item) async {
    final db = await database;

    await changeMainAccount(db, item);

    // You can use `rawUpdate` to write the query in SQL
    return db.update(
      bankAccountTable,
      item.toJson(update: true),
      where: '${BankAccountFields.id} = ?',
      whereArgs: [item.id],
    );
  }

  // Check if the new item has mainAccount true, than find the previous main account and set it to false
  changeMainAccount(Database db, BankAccount item) async {
    if (item.mainAccount) {
      BankAccount? mainAccount = await selectMain();
      if (mainAccount != null && mainAccount.id != item.id) {
        mainAccount = mainAccount.copy(mainAccount: false);
        await db.update(
          bankAccountTable,
          mainAccount.toJson(update: true),
          where: '${BankAccountFields.id} = ?',
          whereArgs: [mainAccount.id],
        );
      }
    }
  }

  Future<int> deleteById(int id) async {
    final db = await database;

    return await db.delete(bankAccountTable, where: '${BankAccountFields.id} = ?', whereArgs: [id]);
  }
  Future<int> deactivateById(int id) async {
    final db = await database;

    return await db.update(
        bankAccountTable,
        {'active':0},
        where: '${BankAccountFields.id} = ?',
        whereArgs: [id],
    );
  }
}
