import '../database/sossoldi_database.dart';
import 'base_entity.dart';

const String BankAccountTable = 'bankAccount';

class BankAccountFields extends BaseEntityFields {
  static String id = 'id';
  static String name = 'name';
  static String value = 'value';
  static String createdAt = 'createdAt';
  static String updatedAt = 'updatedAt';

  static final List<String> allFields = [
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

class BankAccountMethods extends SossoldiDatabase {
  Future<BankAccount> insert(BankAccount item) async {
    final database = await SossoldiDatabase.instance.database;
    final id = await database.insert(BankAccountTable, item.toJson());
    return item.copy(id: id);
  }


  Future<BankAccount> selectById(int id) async {
    final database = await SossoldiDatabase.instance.database;

    final maps = await database.query(
      BankAccountTable,
      columns: BankAccountFields.allFields,
      where: '${BankAccountFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return BankAccount.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
      // reutrn null;
    }
  }

  Future<List<BankAccount>> selectAll() async {
    final database = await SossoldiDatabase.instance.database;

    final orderByASC = '${BankAccountFields.createdAt} ASC';

    // final result = await database.rawQuery('SELECT * FROM $tableExample ORDER BY $orderByASC')
    final result = await database.query(BankAccountTable, orderBy: orderByASC);

    return result.map((json) => BankAccount.fromJson(json)).toList();
  }

  Future<int> updateItem(BankAccount item) async {
    final database = await SossoldiDatabase.instance.database;

    // You can use `rawUpdate` to write the query in SQL
    return database.update(
      BankAccountTable,
      item.toJson(),
      where:
      '${BankAccountFields.id} = ?', // Use `:` if you will not use `sqflite_common_ffi`
      whereArgs: [item.id],
    );
  }

  Future<int> deleteById(int id) async {
    final database = await SossoldiDatabase.instance.database;

    return await database.delete(BankAccountTable,
        where:
        '${BankAccountFields.id} = ?', // Use `:` if you will not use `sqflite_common_ffi`
        whereArgs: [id]);
  }

}