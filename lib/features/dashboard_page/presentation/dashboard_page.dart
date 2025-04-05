import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/accounts_provider.dart';
import '../../../utils/snack_bars/transactions_snack_bars.dart';
import '../../../pages/home_widget/budgets_home.dart';
import '../../../constants/functions.dart';
import 'accounts_list.dart';
import '../../../custom_widgets/transactions_list.dart';
import '../../../providers/transactions_provider.dart';
import 'dashboard_graph.dart';

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

    final accountListWidget = switch (ref.watch(accountsProvider)) {
      AsyncData(:final value) => AccountsList(accounts: value),
      AsyncError(:final error) => Text('Error: $error'),
      _ => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CircularProgressIndicator.adaptive(),
        ),
    };

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
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    "Your accounts",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                SizedBox(
                  height: 80.0,
                  child: accountListWidget,
                ),
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
