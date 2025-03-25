import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ui/device.dart';
import '../utils/snack_bars/transactions_snack_bars.dart';
import 'home_widget/budgets_home.dart';
import '../constants/functions.dart';
import '../constants/style.dart';
import '../custom_widgets/accounts_sum.dart';
import '../custom_widgets/line_chart.dart';
import '../custom_widgets/rounded_icon.dart';
import '../custom_widgets/transactions_list.dart';
import '../model/bank_account.dart';
import '../providers/accounts_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/transactions_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with Functions {
  @override
  Widget build(BuildContext context) {
    final accountList = ref.watch(accountsProvider);
    final lastTransactions = ref.watch(lastTransactionsProvider);
    final currencyState = ref.watch(currencyStateNotifier);
    final isDarkMode = ref.watch(appThemeStateNotifier).isDarkModeEnabled;

    ref.listen(
        duplicatedTransactoinProvider,
        (prev, curr) => showDuplicatedTransactionSnackBar(context,
            transaction: curr, ref: ref));

    return Container(
      color: Theme.of(context).colorScheme.tertiary,
      child: ListView(
        children: [
          ref.watch(dashboardProvider).when(
                data: (value) {
                  final income = ref.watch(incomeProvider);
                  final expense = ref.watch(expenseProvider);
                  final total = income + expense;
                  final currentMonthList = ref.watch(currentMonthListProvider);
                  final lastMonthList = ref.watch(lastMonthListProvider);

                  return Column(
                    children: [
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "MONTHLY BALANCE",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: numToCurrency(total),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineLarge
                                          ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                    ),
                                    TextSpan(
                                      text:
                                          currencyState.selectedCurrency.symbol,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 30),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "INCOME",
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: numToCurrency(income),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: green),
                                    ),
                                    TextSpan(
                                      text:
                                          currencyState.selectedCurrency.symbol,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(color: green),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 30),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "EXPENSES",
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: numToCurrency(expense),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: red),
                                    ),
                                    TextSpan(
                                      text:
                                          currencyState.selectedCurrency.symbol,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(color: red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LineChartWidget(
                        lineData: currentMonthList,
                        line2Data: lastMonthList,
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 16),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Current month",
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: grey2,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Last month",
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                    ],
                  );
                },
                loading: () => const SizedBox(height: 330),
                error: (err, stack) => Text('Error: $err'),
              ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer, //da modificare in darkMode
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(Sizes.borderRadiusLarge),
                topRight: Radius.circular(Sizes.borderRadiusLarge),
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
                              borderRadius: BorderRadius.circular(
                                  Sizes.borderRadius),
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
