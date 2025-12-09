import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/style.dart';
import '../../../../model/currency.dart';
import '../../../../providers/currency_provider.dart';

class CurrencySelectorDialog {
  static void selectCurrencyDialog(
    BuildContext context,
    Currency currency,
    Future<List<Currency>> currencies,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select a currency',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        content: SizedBox(
          height: 300,
          width: 220,
          child: SingleChildScrollView(
            child: Consumer(
              builder: (context, ref, widget) {
                return FutureBuilder(
                  future: currencies,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.data != null &&
                        snapshot.connectionState == ConnectionState.done) {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int i) {
                          return GestureDetector(
                            onTap: () {
                              ref
                                  .read(currencyStateProvider.notifier)
                                  .setSelectedCurrency(snapshot.data![i]);
                              Navigator.pop(context);
                            },
                            child: ListTile(
                              tileColor: Colors.transparent,
                              leading: CircleAvatar(
                                radius: 22,
                                backgroundColor:
                                    currency.code == snapshot.data![i].code
                                    ? blue5
                                    : grey1,
                                child: Text(
                                  snapshot.data![i].symbol,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              title: Text(
                                snapshot.data![i].name,
                                textAlign: TextAlign.center,
                              ),
                            ),
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
