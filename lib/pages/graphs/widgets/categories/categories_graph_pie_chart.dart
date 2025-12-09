import 'package:fl_chart/fl_chart.dart';
import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/constants.dart';
import '../../../../constants/style.dart';
import '../../../../ui/widgets/rounded_icon.dart';
import '../../../../model/category_transaction.dart';
import '../../../../providers/categories_provider.dart';
import '../../../../providers/currency_provider.dart';
import '../../../../ui/device.dart';

class CategoriesGraphPieChart extends ConsumerWidget {
  const CategoriesGraphPieChart({
    required this.categoryMap,
    required this.total,
    super.key,
  });

  final Map<CategoryTransaction, double> categoryMap;
  final double total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);

    List<PieChartSectionData> sections = categoryMap.entries.map((entry) {
      bool isSelected =
          selectedCategory != null && selectedCategory.id == entry.key.id;
      return PieChartSectionData(
        color: categoryColorList[entry.key.color],
        value: 360 * entry.value / total,
        radius: isSelected ? 30.0 : 25.0,
        showTitle: false,
      );
    }).toList();

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
              sections: sections,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  if (!event.isInterestedForInteractions) {
                    return;
                  }
                  int? touchedIndex =
                      pieTouchResponse?.touchedSection?.touchedSectionIndex;
                  if (touchedIndex != null &&
                      touchedIndex >= 0 &&
                      touchedIndex < categoryMap.length) {
                    CategoryTransaction touchedCategory = categoryMap.keys
                        .elementAt(touchedIndex);
                    ref
                        .read(selectedCategoryProvider.notifier)
                        .setCategory(touchedCategory);
                  } else {
                    ref
                        .read(selectedCategoryProvider.notifier)
                        .setCategory(null);
                  }
                },
              ),
            ),
          ),
          PieChartCategoryInfo(categoryMap: categoryMap, total: total),
        ],
      ),
    );
  }
}

class PieChartCategoryInfo extends ConsumerWidget {
  const PieChartCategoryInfo({
    required this.categoryMap,
    required this.total,
    super.key,
  });

  final Map<CategoryTransaction, double> categoryMap;
  final double total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final currencyState = ref.watch(currencyStateProvider);

    double? categoryValue;
    if (selectedCategory != null && categoryMap.containsKey(selectedCategory)) {
      categoryValue = categoryMap[selectedCategory];
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (selectedCategory != null && categoryValue != null)
          RoundedIcon(
            icon: iconList[selectedCategory.symbol] ?? Icons.swap_horiz_rounded,
            backgroundColor: categoryColorList[selectedCategory.color],
            padding: const EdgeInsets.all(Sizes.sm),
          ),
        Text(
          categoryValue != null
              ? "${categoryValue.toStringAsFixed(2)} ${currencyState.symbol}"
              : "${total.toStringAsFixed(2)} ${currencyState.symbol}",
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color:
                (categoryValue != null && categoryValue >= 0) ||
                    (selectedCategory == null && total >= 0)
                ? green
                : red,
            fontSize: 18,
          ),
        ),
        if (selectedCategory != null)
          Text(selectedCategory.name)
        else
          const Text("Total"),
      ],
    );
  }
}
