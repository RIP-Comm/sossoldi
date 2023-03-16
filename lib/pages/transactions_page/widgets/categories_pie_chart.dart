import "package:flutter/material.dart";
import 'package:fl_chart/fl_chart.dart';
import 'package:sossoldi/constants/style.dart';

import '../../../model/category_transaction.dart';

class CategoriesPieChart extends StatelessWidget {
  const CategoriesPieChart({
    required this.notifier,
    required this.categories,
    Key? key,
  }) : super(key: key);

  final ValueNotifier<int> notifier;
  final List<CategoryTransaction> categories;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ValueListenableBuilder(
        valueListenable: notifier,
        builder: (context, value, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  startDegreeOffset: -90,
                  centerSpaceRadius: 70,
                  sectionsSpace: 0,
                  borderData: FlBorderData(show: false),
                  sections: showingSections(),
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      // expand category when tapped
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        return;
                      }
                      notifier.value =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    },
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                // TODO: get icon, color and color from category
                children: [
                  (notifier.value != -1)
                      ? Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.amber,
                          ),
                          child: const Icon(Icons.home_rounded),
                        )
                      : const SizedBox(),
                  Text(
                    "-325.80€",
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge
                        ?.copyWith(color: red),
                  ),
                  (notifier.value != -1)
                      ? Text(categories[notifier.value].name)
                      : const Text("Total"),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(
      categories.length,
      (i) {
        final isTouched = (i == notifier.value);

        final radius = isTouched ? 30.0 : 25.0;
        // TODO: get the percentage of the total for each category
        return PieChartSectionData(
          color: (i % 2 == 0) ? Colors.red : Colors.blue,
          value: 360 / categories.length,
          radius: radius,
          showTitle: false,
        );
      },
    );
  }
}
