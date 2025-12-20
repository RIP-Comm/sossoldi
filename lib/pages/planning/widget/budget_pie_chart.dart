import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/constants.dart';
import '../../../model/budget.dart';
import '../../../providers/currency_provider.dart';
import '../../../ui/device.dart';
import '../../../ui/extensions.dart';

class BudgetPieChart extends ConsumerWidget {
  const BudgetPieChart({required this.budgets, super.key});

  final List<Budget> budgets;

  List<PieChartSectionData> showingSections(double totalBudget) {
    return List.generate(budgets.length, (i) {
      final Budget budget = budgets.elementAt(i);

      double value = (budget.amountLimit / totalBudget) * 100;

      return PieChartSectionData(
        color: categoryColorList[i % categoryColorList.length],
        value: value,
        title: "",
        radius: 20,
      );
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyState = ref.watch(currencyStateProvider);
    double totalBudget = 0;
    for (Budget budget in budgets) {
      totalBudget += budget.amountLimit;
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: 1.5,
          child: PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 70,
              sections: showingSections(totalBudget),
            ),
          ),
        ),
        Column(
          spacing: Sizes.xs,
          children: [
            Text(
              "${totalBudget.toCurrency()}${currencyState.symbol}",
              style: const TextStyle(fontSize: 25),
            ),
            const Text(
              "PLANNED",
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ],
    );
  }
}
