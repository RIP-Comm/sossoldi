import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/accounts_provider.dart';
import '../../../utils/snack_bars/transactions_snack_bars.dart';
import '../../../pages/home_widget/budgets_home.dart';
import '../../../constants/functions.dart';
import 'accounts_list_widget.dart';
import '../../../custom_widgets/transactions_list.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/transactions_provider.dart';
import 'dashboard_data_widget.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> with Functions {
  @override
  Widget build(BuildContext context) {
    final lastTransactions = ref.watch(lastTransactionsProvider);

    ref.listen(
        duplicatedTransactoinProvider,
        (prev, curr) => showDuplicatedTransactionSnackBar(context,
            transaction: curr, ref: ref));

    final dashboardHeader = switch (ref.watch(dashboardProvider)) {
      AsyncData() => const DashboardDataWidget(),
      // TODO: handle error properly
      AsyncError(:final error) => Text('Error: $error'),
      _ => const SizedBox(
          height: 330,
          child: Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        ),
    };

    final accountListWidget = switch (ref.watch(accountsProvider)) {
      AsyncData(:final value) => AccountsListWidget(accounts: value),
      // TODO: handle error properly
      AsyncError(:final error) => Text('Error: $error'),
      _ => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CircularProgressIndicator.adaptive(),
        ),
    };

    return Container(
      color: Theme.of(context).colorScheme.tertiary,
      child: ListView(
        children: [
          dashboardHeader,
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
                lastTransactions.when(
                  data: (transactions) =>
                      TransactionsList(transactions: transactions),
                  loading: () => const SizedBox(),
                  error: (err, stack) => Text('Error: $err'),
                ),
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
