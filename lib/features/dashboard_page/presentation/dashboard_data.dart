import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/style.dart';
import '../../../providers/currency_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../ui/extensions.dart';
import '../../../ui/widgets/line_chart.dart';

class DashboardData extends ConsumerWidget {
  const DashboardData({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final income = ref.watch(incomeProvider);
    final expense = ref.watch(expenseProvider);
    final total = income + expense;
    final currentMonthList = ref.watch(currentMonthListProvider);
    final lastMonthList = ref.watch(lastMonthListProvider);
    final currencyState = ref.watch(currencyStateNotifier);

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
                        text: total.toCurrency(),
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(
                                color: Theme.of(context).colorScheme.primary),
                      ),
                      TextSpan(
                        text: currencyState.selectedCurrency.symbol,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary),
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
                        text: income.toCurrency(),
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
                        text: expense.toCurrency(),
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
  }
}
