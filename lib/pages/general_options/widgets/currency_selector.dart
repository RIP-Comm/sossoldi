import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/currency.dart';
import '../../../providers/currency_provider.dart';
import 'selector/selector_container.dart';
import 'selector/selector_tile.dart';

class SettingsCurrencySelector extends ConsumerStatefulWidget {
  const SettingsCurrencySelector({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SettingsCurrencySelectorState();
}

class _SettingsCurrencySelectorState
    extends ConsumerState<SettingsCurrencySelector> {
  final currenciesFuture = CurrencyMethods().selectAll();

  @override
  Widget build(BuildContext context) {
    final currencyState = ref.watch(currencyStateNotifier);

    return SelectorContainer(
      label: 'CURRENCY',
      child: FutureBuilder(
        future: currenciesFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.connectionState == ConnectionState.done) {
            final currencies = snapshot.data;

            return ListView.separated(
              padding: EdgeInsets.zero,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 8.0);
              },
              shrinkWrap: true,
              itemCount: currencies!.length,
              itemBuilder: (context, index) {
                final selected = currencyState.selectedCurrency.code ==
                    currencies[index].code;

                return SelectorTile(
                  onTap: () {
                    currencyState.setSelectedCurrency(currencies[index]);
                  },
                  title: currencies[index].name,
                  trailing: currencies[index].symbol,
                  isSelected: selected,
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Something went wrong: ${snapshot.error}');
          } else {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Transform.scale(
                scale: 0.5,
                child: const CircularProgressIndicator(),
              );
            } else {
              return const Text("Search for a transaction");
            }
          }
        },
      ),
    );
  }
}
