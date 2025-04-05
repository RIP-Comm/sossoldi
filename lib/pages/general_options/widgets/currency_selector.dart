import 'package:flutter/material.dart';

import '../../../constants/style.dart';
import '../../../model/currency.dart';
import '../../../providers/currency_provider.dart';

class CurrencySelectorDialog {
  static void selectCurrencyDialog(
    BuildContext context,
    CurrencyState state,
    Future<List<Currency>> currencies,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select a currency',
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        content: SizedBox(
          height: 300,
          width: 220,
          child: SingleChildScrollView(
            child: FutureBuilder(
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
                          state.setSelectedCurrency(snapshot.data![i]);
                          Navigator.pop(context);
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 22,
                            backgroundColor: state.selectedCurrency.code ==
                                    snapshot.data![i].code
                                ? blue5
                                : grey1,
                            child: Text(snapshot.data![i].symbol,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontSize: 20)),
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
            ),
          ),
        ),
      ),
    );
  }
}
