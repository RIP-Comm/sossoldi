import 'package:fl_chart/fl_chart.dart';
import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/constants.dart';
import '../../../constants/functions.dart';
import '../../../constants/style.dart';
import '../../../model/category_transaction.dart';
import '../../../providers/categories_provider.dart';
import '../../../providers/currency_provider.dart';
import 'categories_tab.dart';

class CategoriesPieChart extends ConsumerWidget with Functions {
  const CategoriesPieChart({
    required this.categories,
    required this.amounts,
    required this.total,
    super.key,
  });

  final List<CategoryTransaction> categories;
  final Map<int, double> amounts;
  final double total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategoryIndex = ref.watch(selectedCategoryIndexProvider);
    final selectedCategory = (selectedCategoryIndex >= 0) ? categories[selectedCategoryIndex] : null;
    final currencyState = ref.watch(currencyStateNotifier);
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              startDegreeOffset: -90,
              centerSpaceRadius: 70,
              sectionsSpace: 0,
              borderData: FlBorderData(show: false),
              sections: showingSections(selectedCategoryIndex),
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  // expand category when tapped
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    return;
                  }
                  ref.read(selectedCategoryIndexProvider.notifier).state =
                      pieTouchResponse.touchedSection!.touchedSectionIndex;
                },
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              (selectedCategory != null)
                  ? Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: categoryColorList[selectedCategory.color],
                      ),
                      child: Icon(
                        iconList[selectedCategory.symbol] ?? Icons.swap_horiz_rounded,
                        color: Colors.white,
                      ),
                    )
                  : const SizedBox(),
              Text(
                (selectedCategory != null)
                    ? "${amounts[selectedCategory.id]!.toStringAsFixed(2)} ${currencyState.selectedCurrency.symbol}"
                    : "${total.toStringAsFixed(2)} ${currencyState.selectedCurrency.symbol}",
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: ((selectedCategory != null && amounts[selectedCategory.id]! > 0) ||
                            (selectedCategory == null && total > 0))
                        ? green
                        : red),
              ),
              (selectedCategory != null) ? Text(selectedCategory.name) : const Text("Total"),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData>? showingSections(int index) {
    return List.generate(
      amounts.values.length,
      (i) {
        final isTouched = (i == index);

        final radius = isTouched ? 30.0 : 25.0;
        return PieChartSectionData(
          color: categoryColorList[categories[i].color],
          value: 360 * amounts[categories[i].id]!,
          radius: radius,
          showTitle: false,
        );
      },
    );
  }
}
