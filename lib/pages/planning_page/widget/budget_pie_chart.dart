import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/constants.dart';
import '../../../model/budget.dart';
import '../../../providers/currency_provider.dart';

class BudgetPieChart extends ConsumerStatefulWidget {
  const BudgetPieChart({super.key, required this.budgets});

  final List<Budget> budgets;

  @override
  BudgetPieChartState createState() => BudgetPieChartState();
}

class BudgetPieChartState extends ConsumerState<BudgetPieChart> {
  double totalBudget = 0;

  @override
  Widget build(BuildContext context) {
    final currencyState = ref.watch(currencyStateNotifier);
    totalBudget = 0;
    for (Budget budget in widget.budgets) {
      totalBudget += budget.amountLimit;
    }
    return Stack(alignment: Alignment.center, children: [
      AspectRatio(
        aspectRatio: 1.5,
        child: PieChart(
          PieChartData(
            sectionsSpace: 0,
            centerSpaceRadius: 70,
            sections: showingSections(),
          ),
        ),
      ),
      Column(
        children: [
          Text("${totalBudget.round()}${currencyState.selectedCurrency.symbol}", style: const TextStyle(fontSize: 25)),
          const SizedBox(height: 5),
          const Text("PLANNED", style: TextStyle(fontWeight: FontWeight.normal))
        ],
      )
    ]);
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(widget.budgets.length, (i) {
      final Budget budget = widget.budgets.elementAt(i);

      double value = (budget.amountLimit / totalBudget) * 100;

      return PieChartSectionData(
        color: categoryColorList[i],
        value: value,
        title: "",
        radius: 20,
      );
    });
  }
}
