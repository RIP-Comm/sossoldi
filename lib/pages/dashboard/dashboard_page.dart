import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/account_section.dart';
import 'widgets/budgets_section.dart';
import '../../constants/style.dart';
import '../../providers/categories_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/transactions_provider.dart';
import '../../ui/device.dart';
import '../../ui/extensions.dart';
import '../../ui/snack_bars/transactions_snack_bars.dart';
import '../../ui/widgets/blur_widget.dart';
import '../../ui/widgets/line_chart.dart';
import '../../ui/widgets/transactions_list.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    ref.read(categoriesProvider);
    final lastTransactions = ref.watch(lastTransactionsProvider);
    final currencyState = ref.watch(currencyStateProvider);
    final income = ref.watch(incomeProvider);
    final expense = ref.watch(expenseProvider);
    final currentMonthList = ref.watch(currentMonthListProvider);
    final lastMonthList = ref.watch(lastMonthListProvider);

    ref.listen(
      duplicatedTransactionProvider,
      (prev, curr) => showDuplicatedTransactionSnackBar(
        context,
        transaction: curr,
        ref: ref,
      ),
    );

    return Container(
      color: Theme.of(context).colorScheme.tertiary,
      child: ListView(
        children: [
          ref
              .watch(dashboardProvider)
              .when(
                data: (_) {
                  return Column(
                    children: [
                      const SizedBox(height: Sizes.xl),
                      Row(
                        children: [
                          const SizedBox(width: Sizes.lg),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "MONTHLY BALANCE",
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                              ),
                              BlurWidget(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: (income + expense).toCurrency(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineLarge
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                      ),
                                      TextSpan(
                                        text: currencyState.symbol,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: Sizes.xl),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "INCOME",
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              BlurWidget(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: income.toCurrency(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: green),
                                      ),
                                      TextSpan(
                                        text: currencyState.symbol,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(color: green),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: Sizes.xl),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "EXPENSES",
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              BlurWidget(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: expense.toCurrency(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: red),
                                      ),
                                      TextSpan(
                                        text: currencyState.symbol,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(color: red),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: Sizes.lg),
                      LineChartWidget(
                        ignoreBlur: false,
                        lineData: currentMonthList,
                        line2Data: lastMonthList,
                      ),
                      Row(
                        children: [
                          const SizedBox(width: Sizes.lg),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: Sizes.xs),
                          Text(
                            "Current month",
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          const SizedBox(width: Sizes.md),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: grey2,
                            ),
                          ),
                          const SizedBox(width: Sizes.xs),
                          Text(
                            "Last month",
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Sizes.xl),
                    ],
                  );
                },
                loading: () => const SizedBox(height: 330),
                error: (err, stack) => Text('Error: $err'),
              ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer, //da modificare in darkMode
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(Sizes.borderRadiusLarge),
                topRight: Radius.circular(Sizes.borderRadiusLarge),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Sizes.lg,
                    Sizes.xl,
                    Sizes.lg,
                    Sizes.sm,
                  ),
                  child: Text(
                    "Your accounts",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const AccountSection(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Sizes.lg,
                      Sizes.xxl,
                      Sizes.lg,
                      Sizes.sm,
                    ),
                    child: Text(
                      "Last transactions",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                lastTransactions.when(
                  data: (transactions) => TransactionsList(
                    ignoreBlur: false,
                    transactions: transactions,
                  ),
                  loading: () => const SizedBox(),
                  error: (err, stack) => Text('Error: $err'),
                ),
                const SizedBox(height: Sizes.xxl),
                const BudgetsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
