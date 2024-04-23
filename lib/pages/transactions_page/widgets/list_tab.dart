import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/functions.dart';
import '../../../custom_widgets/transactions_list.dart';
import '../../../providers/transactions_provider.dart';

class ListTab extends ConsumerStatefulWidget {
  const ListTab({
    super.key,
  });

  @override
  ConsumerState<ListTab> createState() => _ListTabState();
}

class _ListTabState extends ConsumerState<ListTab> with Functions {
  @override
  Widget build(BuildContext context) {
    final asyncTransactions = ref.watch(transactionsProvider);

    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: asyncTransactions.when(
        data: (transactions) {
          return TransactionsList(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            transactions: transactions,
          );
        },
        loading: () {
          return Container(
            color: Colors.white,
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
