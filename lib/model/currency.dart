import '../database/sossoldi_database.dart';
import 'base_entity.dart';

const String currencyTable = 'currency';

class CurrencyFields extends BaseEntityFields {
  static String id = BaseEntityFields.getId;
  static String symbol = 'symbol';
  static String code = 'code';
  static String name = 'name';
  static String mainCurrency = 'mainCurrency';

  static final List<String> allFields = [
    BaseEntityFields.id,
    symbol,
    code,
    name,
    mainCurrency,
  ];
}

class Currency extends BaseEntity {
  final String symbol;
  final String code;
  final String name;
  final bool mainCurrency;

  const Currency(
      {int? id,
      required this.symbol,
      required this.code,
      required this.name,
      required this.mainCurrency})
      : super(id: id);

  Currency copy(
          {int? id,
          String? symbol,
          String? code,
          String? name,
          bool? mainCurrency,t}) =>
      Currency(
          id: id ?? this.id,
          symbol: symbol ?? this.symbol,
          code: code ?? this.code,
          name: name ?? this.name,
          mainCurrency: mainCurrency ?? this.mainCurrency);

  static Currency fromJson(Map<String, Object?> json) => Currency(
      id: json[BaseEntityFields.id] as int?,
      symbol: json[CurrencyFields.symbol] as String,
      code: json[CurrencyFields.code] as String,
      name: json[CurrencyFields.name] as String,
      mainCurrency: json[CurrencyFields.mainCurrency] == 1 ? true : false);

  Map<String, Object?> toJson() => {
        BaseEntityFields.id: id,
        CurrencyFields.symbol: symbol,
        CurrencyFields.code: code,
        CurrencyFields.name: name,
        CurrencyFields.mainCurrency: mainCurrency
      };
}

class BudgetMethods extends SossoldiDatabase {
  Future<Currency> insert(Currency item) async {
    final database = await SossoldiDatabase.instance.database;
    final id = await database.insert(currencyTable, item.toJson());
    return item.copy(id: id);
  }


  Future<Currency> selectById(int id) async {
    final database = await SossoldiDatabase.instance.database;

    final maps = await database.query(
      currencyTable,
      columns: CurrencyFields.allFields,
      where: '${CurrencyFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Currency.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Currency>> selectAll() async {
    final database = await SossoldiDatabase.instance.database;

    final orderByASC = '${CurrencyFields.id} ASC';

    final result = await database.query(currencyTable, orderBy: orderByASC);

    return result.map((json) => Currency.fromJson(json)).toList();
  }

  Future<int> updateItem(Currency item) async {
    final database = await SossoldiDatabase.instance.database;

    // You can use `rawUpdate` to write the query in SQL
    return database.update(
      currencyTable,
      item.toJson(),
      where:
      '${CurrencyFields.id} = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteById(int id) async {
    final database = await SossoldiDatabase.instance.database;

    return await database.delete(currencyTable,
        where:
        '${CurrencyFields.id} = ?',
        whereArgs: [id]);
  }

}