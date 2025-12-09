import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/currency.dart';
import '../services/database/repositories/currency_repository.dart';

part 'currency_provider.g.dart';

@Riverpod(keepAlive: true)
class CurrencyState extends _$CurrencyState {
  //Initial currency selected (fallback)
  final Currency _defaultCurrency = const Currency(
    id: 2,
    symbol: '\$',
    code: 'USD',
    name: "United States Dollar",
    mainCurrency: true,
  );

  @override
  Currency build() {
    _initializeState();
    return _defaultCurrency;
  }

  Future<void> _initializeState() async {
    final currency = await ref
        .read(currencyRepositoryProvider)
        .getSelectedCurrency();
    state = currency;
  }

  Future<void> setSelectedCurrency(Currency currency) async {
    await ref.read(currencyRepositoryProvider).changeMainCurrency(currency.id!);
    state = currency;
  }
}
