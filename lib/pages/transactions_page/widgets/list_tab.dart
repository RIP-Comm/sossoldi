import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/functions.dart';
import '../../../custom_widgets/transactions_list.dart';
import '../../../providers/transactions_provider.dart';

class ListTab extends ConsumerWidget with Functions {
  const ListTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTransactions = ref.watch(transactionsProvider);

    return Container(
      child: asyncTransactions.when(
        data: (transactions) {
          return TransactionsList(
            margin: const EdgeInsets.all(16.0),
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
