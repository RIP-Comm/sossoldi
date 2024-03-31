import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/currency.dart';

final currencyStateNotifier = ChangeNotifierProvider(
  (ref) => CurrencyState(),
);

class CurrencyState extends ChangeNotifier {
  //Initial currency selected
  Currency selectedCurrency = const Currency(
    id: 2,
    symbol: '\$',
    code: 'USD',
    name: "United States Dollar",
    mainCurrency: true
  );

  CurrencyState() {
    _initializeState();
  }

  Future<void> _initializeState() async {
    selectedCurrency = await CurrencyMethods().getSelectedCurrency();
    notifyListeners();
  }

  void insertAll() {
    Currency euro = const Currency(symbol: "€", code: "EUR", name: "Euro", mainCurrency: true);
    Currency dollar = const Currency(symbol: "\$", code: "USD", name: "United States Dollar", mainCurrency: false);
    Currency franc = const Currency(symbol: "CHF", code: "CHF", name: "Switzerland Franc", mainCurrency: false);
    Currency pound = const Currency(symbol: "£", code: "GBP", name: "United Kingdom Pound", mainCurrency: false);

    List<Currency> list = [euro, dollar, franc, pound];
    CurrencyMethods().insertAll(list);
    notifyListeners();
  }

  void setSelectedCurrency(Currency currency) {
      selectedCurrency = currency;
      CurrencyMethods().changeMainCurrency(currency.id!);
      notifyListeners();
  }
}
