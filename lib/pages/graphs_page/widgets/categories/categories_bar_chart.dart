import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../constants/style.dart';
import '../../../../providers/categories_provider.dart';
import '../../../../providers/transactions_provider.dart';

final highlightedMonthProvider = StateProvider<int>((ref) => DateTime.now().month - 1);

class CategoriesBarChart extends ConsumerWidget {
  const CategoriesBarChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int highlightedMonth = ref.watch(highlightedMonthProvider);
    final categoryTotalAmount = ref.watch(categoryTotalAmountProvider(ref.watch(categoryTypeProvider)));

    const rodBorderRadius = BorderRadius.only(
      topLeft: Radius.circular(5),
      topRight: Radius.circular(5),
      bottomLeft: Radius.zero,
      bottomRight: Radius.zero,
    );

    List<BarChartGroupData> generateBarGroups() {
      return List.generate(12, (index) {
        bool isHighlighted = index == highlightedMonth;
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: categoryTotalAmount.value!.abs() * 10.0,
              width: 40,
              borderRadius: rodBorderRadius,
              color: isHighlighted ? blue2 : grey2,
            ),
          ],
        );
      });
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 12, //only 12 months (temporary)
        itemBuilder: (context, index) {
          return SizedBox(
            width: MediaQuery.of(context).size.width / 6,
            child: BarChart(
              BarChartData(
                barGroups: [generateBarGroups()[index]],
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            DateFormat('MMM').format(DateTime(0, value.toInt() + 1)),
                            style: const TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  handleBuiltInTouches: true,
                  touchCallback: (event, response) {
                    if (response != null && response.spot != null && event is FlTapUpEvent) {
                      final x = response.spot!.touchedBarGroup.x;
                      ref.read(highlightedMonthProvider.notifier).state = x;

                      DateTime selectedMonth = DateTime(DateTime.now().year, x + 1, 1);
                      ref.read(filterDateStartProvider.notifier).state =
                          DateTime(selectedMonth.year, selectedMonth.month, 1);
                      ref.read(filterDateEndProvider.notifier).state =
                          DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
                    }
                  },
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          );
        },
      ),
    );
  }
}
