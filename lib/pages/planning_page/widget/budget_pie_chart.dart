import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../model/budget.dart';


class BudgetPieChart extends StatefulWidget {
  BudgetPieChart({super.key, required this.budgets});

  final List<Budget> budgets;

  @override
  BudgetPieChartState createState() => BudgetPieChartState();
}

class BudgetPieChartState extends State<BudgetPieChart> {
  double totalBudget = 0;

  @override
  Widget build(BuildContext context) {
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
          Text("${totalBudget.round()}€", style: const TextStyle(fontSize: 25)),
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
        color: i == 0 ? Colors.deepPurple : Colors.blue,
        value: value,
        title: "",
        radius: 20,
      );
    });
  }
}
