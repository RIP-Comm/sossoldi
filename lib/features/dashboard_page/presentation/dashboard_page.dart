import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/accounts_provider.dart';
import '../../../utils/snack_bars/transactions_snack_bars.dart';
import '../../../pages/home_widget/budgets_home.dart';
import '../../../constants/functions.dart';
import '../../../constants/style.dart';
import '../../../custom_widgets/accounts_sum.dart';
import '../../../custom_widgets/rounded_icon.dart';
import '../../../custom_widgets/transactions_list.dart';
import '../../../model/bank_account.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/theme_provider.dart';
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
    final accountList = ref.watch(accountsProvider);
    final lastTransactions = ref.watch(lastTransactionsProvider);
    final isDarkMode = ref.watch(appThemeStateNotifier).isDarkModeEnabled;

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
                  child: accountList.when(
                    data: (accounts) => ListView.separated(
                      itemCount: accounts.length + 1,
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (context, i) =>
                          const SizedBox(width: 16),
                      itemBuilder: (context, i) {
                        if (i == accounts.length) {
                          return Container(
                            constraints: const BoxConstraints(maxWidth: 140),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [defaultShadow],
                            ),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.surface,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                              icon: RoundedIcon(
                                icon: Icons.add_rounded,
                                backgroundColor: blue5,
                                padding: EdgeInsets.all(5.0),
                              ),
                              label: Text(
                                "New Account",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      color: isDarkMode
                                          ? grey3
                                          : Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                    ),
                                maxLines: 2,
                              ),
                              onPressed: () {
                                ref.read(accountsProvider.notifier).reset();
                                Navigator.of(context).pushNamed('/add-account');
                              },
                            ),
                          );
                        }
                        BankAccount account = accounts[i];
                        return AccountsSum(account: account);
                      },
                    ),
                    loading: () => const SizedBox(),
                    error: (err, stack) => Text('Error: $err'),
                  ),
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
