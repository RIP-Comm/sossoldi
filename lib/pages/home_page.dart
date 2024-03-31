import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/functions.dart';
import '../constants/style.dart';
import '../custom_widgets/accounts_sum.dart';
import '../custom_widgets/budget_circular_indicator.dart';
import '../custom_widgets/line_chart.dart';
import '../custom_widgets/transactions_list.dart';
import '../model/bank_account.dart';
import '../providers/accounts_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/dashboard_provider.dart';
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
                                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: numToCurrency(total),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineLarge
                                          ?.copyWith(color: Theme.of(context).colorScheme.primary),
                                    ),
                                    TextSpan(
                                      text: currencyState.selectedCurrency.symbol,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(color: Theme.of(context).colorScheme.primary),
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
                                      text: currencyState.selectedCurrency.symbol,
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
                                      text: currencyState.selectedCurrency.symbol,
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
                                ?.copyWith(color: Theme.of(context).colorScheme.primary),
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
                                ?.copyWith(color: Theme.of(context).colorScheme.primary),
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
              color: Theme.of(context).colorScheme.primaryContainer, //da modificare in darkMode
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
                  height: 86.0,
                  child: accountList.when(
                    data: (accounts) => ListView.builder(
                      itemCount: accounts.length + 1,
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, i) {
                        if (i == accounts.length || accounts.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [defaultShadow],
                              ),
                              child: TextButton.icon(
                                style: ButtonStyle(
                                  maximumSize: MaterialStateProperty.all(const Size(130, 48)),
                                  backgroundColor: MaterialStateProperty.all(
                                      Theme.of(context).colorScheme.surface),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ),
                                icon: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: blue5,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: Icon(
                                      Icons.add_rounded,
                                      size: 24.0,
                                      color: white,
                                    ),
                                  ),
                                ),
                                label: Text(
                                  "New Account",
                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                  maxLines: 2,
                                ),
                                onPressed: () {
                                  ref.read(accountsProvider.notifier).reset();
                                  Navigator.of(context).pushNamed('/add-account');
                                },
                              ),
                            ),
                          );
                        } else if(accounts.isNotEmpty) {
                          BankAccount account = accounts[i];
                          return AccountsSum(account: account);
                        }

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
                  data: (transactions) => TransactionsList(transactions: transactions),
                  loading: () => const SizedBox(),
                  error: (err, stack) => Text('Error: $err'),
                ),
                const SizedBox(height: 28),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      "Your budgets",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BudgetCircularIndicator(
                        title: "TOTALE",
                        amount: 320,
                        perc: 0.25,
                        color: Color(0xFFEBC35F),
                      ),
                      BudgetCircularIndicator(
                        title: "SPESE",
                        amount: 500,
                        perc: 0.5,
                        color: Color(0xFFD336B6),
                      ),
                      BudgetCircularIndicator(
                        title: "SVAGO",
                        amount: 178.67,
                        perc: 0.88,
                        color: Color(0xFF8E5FEB),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
