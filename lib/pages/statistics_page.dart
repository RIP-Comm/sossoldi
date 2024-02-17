// Satistics page.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/functions.dart';
import '../constants/style.dart';
import '../custom_widgets/default_container.dart';
import '../custom_widgets/line_chart.dart';
import '../custom_widgets/transaction_type_button.dart';
import '../model/bank_account.dart';
import '../providers/accounts_provider.dart';
import '../providers/statistics_provider.dart';

class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage> with Functions {
  @override
  Widget build(BuildContext context) {
    final currentYearMonthlyTransactions = ref.watch(currentYearMontlyTransactionsProvider);
    final accountList = ref.watch(accountsProvider);

    return ListView(
      children: [
        const SizedBox(height: 16),
        ref.watch(statisticsProvider).when(
              data: (value) {
                double percentGainLoss = 0;
                if (currentYearMonthlyTransactions.length > 1) {
                  percentGainLoss = ((currentYearMonthlyTransactions.last.y -
                              currentYearMonthlyTransactions[
                                      currentYearMonthlyTransactions.length - 2]
                                  .y) /
                          currentYearMonthlyTransactions[currentYearMonthlyTransactions.length - 2]
                              .y) *
                      100;
                }
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      color: Theme.of(context).colorScheme.tertiary,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Available liquidity",
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: numToCurrency(currentYearMonthlyTransactions.last.y),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineLarge
                                          ?.copyWith(color: blue4),
                                    ),
                                    TextSpan(
                                      text: "€",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(color: blue4),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.background,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  "${numToCurrency(percentGainLoss)}%",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: percentGainLoss < 0 ? red : green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              Text(
                                " VS last month",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w300),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    LineChartWidget(lineData: currentYearMonthlyTransactions),
                  ],
                );
              },
              loading: () => const SizedBox(),
              error: (err, stack) => Text('Error: $err'),
            ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              "Accounts",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
        ),
        DefaultContainer(
          child: accountList.when(
            data: (accounts) => ListView.builder(
              itemCount: accounts.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemBuilder: (context, i) {
                BankAccount account = accounts[i];
                return SizedBox(
                  height: 50.0,
                  child: Column(
                    children: [
                      const Padding(padding: EdgeInsets.all(2.0)),
                      Row(
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: account.name,
                                  style:
                                      Theme.of(context).textTheme.bodySmall?.copyWith(color: blue1),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "${numToCurrency(account.total)}€",
                              textAlign: TextAlign.right,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: blue1),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(16)),
                        child: LinearProgressIndicator(
                          value: account.total != 0 ? account.startingValue / account.total! : 0,
                          minHeight: 16,
                          backgroundColor: blue3.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(blue3),
                          borderRadius: const BorderRadius.all(Radius.circular(16)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            loading: () => const SizedBox(),
            error: (err, stack) => Text('Error: $err'),
          ),
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              "Categories",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
        ),
        DefaultContainer(
          child: Column(
            children: [
              const TransactionTypeButton(),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    "After you add some transactions, some outstanding graphs will appear here... almost by magic!",
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
