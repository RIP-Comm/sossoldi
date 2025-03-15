import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Consumer;

import '../../../custom_widgets/default_container.dart' show DefaultContainer;
import '../../../providers/transactions_provider.dart' show transactionsProvider;

class TransactionEmptyStateWidget extends StatelessWidget {
  const TransactionEmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 16),
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.5,
          child: DefaultContainer(
            child: Column(
              children: [
                Text(
                  "There are no transactions added yet",
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                Image.asset(
                  'assets/calculator.png',
                  width: 240,
                  height: 240,
                ),
                Text(
                  "Add a transaction to make this section more appealing",
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Consumer(builder: (context, ref, child) {
                  return TextButton.icon(
                    icon: Icon(
                      Icons.add_circle,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    onPressed: () {
                      ref.read(transactionsProvider.notifier).reset();
                      Navigator.of(context).pushNamed("/add-page");
                    },
                    label: Text(
                      "Add transaction",
                      style: Theme.of(context).textTheme.titleSmall!.apply(color: Theme.of(context).colorScheme.secondary),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                  );
                })
              ],
            ),
          ),
        ),
      ],
    );
  }
}
