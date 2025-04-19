import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/transactions_provider.dart';
import '../../../shared/ui/widgets/transactions_list.dart';

class ListTab extends ConsumerWidget {
  const ListTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTransactions = ref.watch(transactionsProvider);

    return switch (asyncTransactions) {
      AsyncData(:final value) => TransactionsList(
          margin: const EdgeInsets.all(16.0),
          transactions: value,
        ),
      AsyncError(:final error) => Center(
          child: Text('Error: $error'),
        ),
      _ => Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        ),
    };
  }
}
