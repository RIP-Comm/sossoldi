// Satistics page.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/constants/functions.dart';
import '../../../shared/constants/style.dart';
import '../../../shared/widgets/line_chart.dart';
import '../../../shared/models/transaction.dart';
import '../../../shared/providers/currency_provider.dart';
import '../../../shared/providers/statistics_provider.dart';
import 'categories/categories_card.dart';
import 'accounts_card.dart';

class GraphsPage extends ConsumerStatefulWidget {
  const GraphsPage({super.key});

  @override
  ConsumerState<GraphsPage> createState() => _GraphsPageState();
}

class _GraphsPageState extends ConsumerState<GraphsPage> with Functions {
  @override
  Widget build(BuildContext context) {
    final currentYearMonthlyTransactions =
        ref.watch(currentYearMontlyTransactionsProvider);
    final currencyState = ref.watch(currencyStateNotifier);

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
                          currentYearMonthlyTransactions[
                                  currentYearMonthlyTransactions.length - 2]
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
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: currentYearMonthlyTransactions
                                              .isNotEmpty
                                          ? numToCurrency(
                                              currentYearMonthlyTransactions
                                                  .last.y)
                                          : '0',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineLarge
                                          ?.copyWith(
                                            color: typeToColor(
                                              TransactionType.transfer,
                                              brightness:
                                                  Theme.of(context).brightness,
                                            ),
                                          ),
                                    ),
                                    TextSpan(
                                      text:
                                          currencyState.selectedCurrency.symbol,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            color: typeToColor(
                                              TransactionType.transfer,
                                              brightness:
                                                  Theme.of(context).brightness,
                                            ),
                                          ),
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
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  "${numToCurrency(percentGainLoss)}%",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color:
                                            percentGainLoss < 0 ? red : green,
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
                    LineChartWidget(
                      lineData: currentYearMonthlyTransactions,
                      enableGapFilling: false,
                      period: Period.year,
                    ),
                  ],
                );
              },
              loading: () => const SizedBox(),
              error: (error, stack) => Text('Error: $error'),
            ),
        const SizedBox(height: 24),
        const AccountsCard(),
        const SizedBox(height: 24),
        const CategoriesCard(),
        const SizedBox(height: 24),
      ],
    );
  }
}
