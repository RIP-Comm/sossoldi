import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/snack_bars/transactions_snack_bars.dart';
import 'budgets_section.dart';
import '../../../constants/functions.dart';
import '../../../custom_widgets/transactions_list.dart';
import '../../../providers/transactions_provider.dart';
import 'dashboard_graph.dart';
import 'your_accounts_section.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> with Functions {
  @override
  Widget build(BuildContext context) {
    ref.listen(
        duplicatedTransactoinProvider,
        (prev, curr) => showDuplicatedTransactionSnackBar(context,
            transaction: curr, ref: ref));

    final lastTransactionsWidget =
        switch (ref.watch(lastTransactionsProvider)) {
      AsyncData(:final value) => TransactionsList(transactions: value),
      AsyncError(:final error) => Text('Error: $error'),
      _ => const SizedBox(),
    };

    return Container(
      color: Theme.of(context).colorScheme.tertiary,
      child: ListView(
        children: [
          const DashboardGraph(),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer, //da modificare in darkMode
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const YourAccountsSection(),
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
                lastTransactionsWidget,
                const SizedBox(height: 28),
                const BudgetsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
