import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/currency.dart';

final currencyStateNotifier = ChangeNotifierProvider(
  (ref) => CurrencyState(),
);

class CurrencyState extends ChangeNotifier {
  //Initial currency selected
  Currency selectedCurrency = const Currency(
      id: 2, symbol: '\$', code: 'USD', name: "United States Dollar", mainCurrency: true);

  CurrencyState() {
    _initializeState();
  }

  Future<void> _initializeState() async {
    selectedCurrency = await CurrencyMethods().getSelectedCurrency();
    notifyListeners();
  }

  void setSelectedCurrency(Currency currency) {
    selectedCurrency = currency;
    CurrencyMethods().changeMainCurrency(currency.id!);
    notifyListeners();
  }
}
