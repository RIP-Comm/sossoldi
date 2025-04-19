import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/transactions_provider.dart';
import '../../../ui/widgets/transactions_list.dart';

class LastTransactionsSection extends ConsumerWidget {
  const LastTransactionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
            child: Text(
              "Last transactions",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        switch (ref.watch(lastTransactionsProvider)) {
          AsyncData(:final value) => TransactionsList(transactions: value),
          AsyncError(:final error) => Text('Error: $error'),
          _ => const SizedBox(),
        },
      ],
    );
  }
}
