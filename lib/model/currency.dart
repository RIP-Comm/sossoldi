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

  const Currency({
    super.id,
    required this.symbol,
    required this.code,
    required this.name,
    required this.mainCurrency,
  });

  Currency copy({
    int? id,
    String? symbol,
    String? code,
    String? name,
    bool? mainCurrency,
    t,
  }) => Currency(
    id: id ?? this.id,
    symbol: symbol ?? this.symbol,
    code: code ?? this.code,
    name: name ?? this.name,
    mainCurrency: mainCurrency ?? this.mainCurrency,
  );

  static Currency fromJson(Map<String, Object?> json) => Currency(
    id: json[BaseEntityFields.id] as int?,
    symbol: json[CurrencyFields.symbol] as String,
    code: json[CurrencyFields.code] as String,
    name: json[CurrencyFields.name] as String,
    mainCurrency: json[CurrencyFields.mainCurrency] == 1 ? true : false,
  );

  Map<String, Object?> toJson() => {
    BaseEntityFields.id: id,
    CurrencyFields.symbol: symbol,
    CurrencyFields.code: code,
    CurrencyFields.name: name,
    CurrencyFields.mainCurrency: mainCurrency ? 1 : 0,
  };
}
