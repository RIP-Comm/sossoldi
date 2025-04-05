import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/widgets/transactions_list.dart';
import '../../../providers/transactions_provider.dart';
import '../../../ui/device.dart';

class ListTab extends ConsumerWidget {
  const ListTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTransactions = ref.watch(transactionsProvider);

    return Container(
      child: asyncTransactions.when(
        data: (transactions) {
          return TransactionsList(
            margin: const EdgeInsets.all(Sizes.lg),
            transactions: transactions,
          );
        },
        loading: () {
          return Container(
            color: Theme.of(context).colorScheme.primaryContainer,
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Text(stackTrace.toString()),
          );
        },
      ),
    );
  }
}
