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
  int touchedIndex = -1;
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
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                setState(() {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    touchedIndex = -1;
                    return;
                  }
                  touchedIndex =
                      pieTouchResponse.touchedSection!.touchedSectionIndex;
                });
              },
            ),
            borderData: FlBorderData(
              show: false,
            ),
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
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 0.0;
      final radius = isTouched ? 40.0 : 20.0;

      double value = (budget.amountLimit / totalBudget) * 100;

      return PieChartSectionData(
        color: i == 0 ? Colors.deepPurple : Colors.blue,
        value: value,
        title: "${value.round()}%",
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }
}
