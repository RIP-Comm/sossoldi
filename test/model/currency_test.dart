import 'package:flutter_test/flutter_test.dart';

import 'package:sossoldi/model/currency.dart';
import 'package:sossoldi/model/base_entity.dart';

void main() {
  test('Test Copy Currency', () {
    Currency b = const Currency(
        id: 2,
        symbol: '\$',
        code: 'USD',
        name: "United States Dollar",
        mainCurrency: true
    );

    Currency bCopy = b.copy(id: 10);

    assert(bCopy.id == 10);
    assert(bCopy.name == b.name);
    assert(bCopy.code == b.code);
    assert(bCopy.symbol == b.symbol);
    assert(bCopy.mainCurrency == b.mainCurrency);
  });

  test("Test fromJson Currency", () {
    Map<String, Object?> json = {
      BaseEntityFields.id: 2,
      CurrencyFields.name: "United States Dollar",
      CurrencyFields.code: "USD",
      CurrencyFields.symbol: "\$",
      CurrencyFields.mainCurrency: false,
    };

    Currency b = Currency.fromJson(json);

    assert(b.id == json[BaseEntityFields.id]);
    assert(b.name == json[CurrencyFields.name]);
    assert(b.code == json[CurrencyFields.code]);
    assert(b.mainCurrency == json[CurrencyFields.mainCurrency]);
  });

  test("Test toJson Currency", () {
    Currency b = const Currency(
        id: 2,
        symbol: '\$',
        code: 'USD',
        name: "United States Dollar",
        mainCurrency: true);

    Map<String, Object?> json = b.toJson();

    assert(b.id == json[BaseEntityFields.id]);
    assert(b.name == json[CurrencyFields.name]);
    assert(b.symbol == json[CurrencyFields.symbol]);
    assert(b.code == json[CurrencyFields.code]);
    assert(b.symbol == json[CurrencyFields.symbol]);
    assert(b.mainCurrency == json[CurrencyFields.mainCurrency]);
  });
}
