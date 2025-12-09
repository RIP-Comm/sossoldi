import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../constants/style.dart';
import '../../../../providers/categories_provider.dart';
import '../../../../providers/statistics_provider.dart';
import '../../../../providers/transactions_provider.dart';
import '../../../../ui/device.dart';

class CategoriesBarChart extends ConsumerWidget {
  const CategoriesBarChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highlightedMonth = ref.watch(highlightedMonthProvider);
    final monthlyTotals = ref.watch(monthlyTotalsProvider);
    final startDate = ref.watch(filterDateStartProvider);

    final currentYear = startDate.year;

    return Column(
      children: [
        Text('$currentYear', style: Theme.of(context).textTheme.bodySmall),
        monthlyTotals.when(
          data: (totals) {
            final average = totals.isNotEmpty
                ? totals.reduce((a, b) => a + b) /
                      totals.where((total) => total > 0).length
                : 0.0;

            return SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: _generateBarGroups(
                    context,
                    totals,
                    highlightedMonth,
                  ),
                  titlesData: _titlesData(context),
                  barTouchData: _barTouchData(ref, currentYear),
                  borderData: FlBorderData(show: false),
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: average,
                        color: Theme.of(context).colorScheme.secondary,
                        strokeWidth: 2,
                        dashArray: [5, 5],
                        label: HorizontalLineLabel(
                          show: true,
                          labelResolver: (line) => "avg",
                          alignment: Alignment.topRight,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (error, stack) => Text('$error'),
        ),
      ],
    );
  }

  List<BarChartGroupData> _generateBarGroups(
    BuildContext context,
    List<double> totals,
    int highlightedMonth,
  ) {
    const rodBorderRadius = BorderRadius.only(
      topLeft: Radius.circular(Sizes.borderRadiusSmall),
      topRight: Radius.circular(Sizes.borderRadiusSmall),
    );

    final maxAmount = totals.isNotEmpty
        ? totals.reduce((a, b) => a > b ? a : b)
        : 1.0;

    return List.generate(totals.length, (index) {
      final barHeight = maxAmount > 0 ? totals[index] : 0.0;
      final isHighlighted = index == highlightedMonth;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: barHeight,
            width: 20,
            borderRadius: rodBorderRadius,
            color: isHighlighted
                ? Theme.of(context).colorScheme.secondary
                : grey2,
          ),
        ],
      );
    });
  }

  FlTitlesData _titlesData(BuildContext context) {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.only(top: Sizes.sm),
              child: Text(
                DateFormat('MMM').format(DateTime(0, value.toInt() + 1)),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 10,
                ),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                meta.formattedValue,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 10,
                ),
              ),
            );
          },
        ),
      ),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  BarTouchData _barTouchData(WidgetRef ref, int currentYear) {
    return BarTouchData(
      enabled: true,
      handleBuiltInTouches: true,
      touchTooltipData: BarTouchTooltipData(
        tooltipPadding: EdgeInsets.zero,
        tooltipMargin: 0,
        getTooltipItem: (group, groupIndex, rod, rodIndex) =>
            null, // Hidden tooltip
      ),
      touchCallback: (event, response) {
        if (response != null &&
            response.spot != null &&
            event is FlTapUpEvent) {
          final selectedMonthIndex = response.spot!.touchedBarGroup.x;
          ref
              .read(highlightedMonthProvider.notifier)
              .setValue(selectedMonthIndex);
          _updateSelectedMonth(ref, currentYear, selectedMonthIndex);
        }
      },
    );
  }

  void _updateSelectedMonth(WidgetRef ref, int year, int monthIndex) {
    final selectedMonth = DateTime(year, monthIndex + 1, 1);
    ref
        .read(filterDateStartProvider.notifier)
        .setDate(DateTime(selectedMonth.year, selectedMonth.month, 1));
    ref
        .read(filterDateEndProvider.notifier)
        .setDate(DateTime(selectedMonth.year, selectedMonth.month + 1, 0));
  }
}
