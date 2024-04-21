import 'dart:convert';
import 'dart:developer';

import 'package:fl_chart/fl_chart.dart';
import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/constants.dart';
import '../../../../constants/functions.dart';
import '../../../../constants/style.dart';
import '../../../../model/category_transaction.dart';
import '../../../../providers/categories_provider.dart';
import '../../../../providers/currency_provider.dart';

class CategoriesPieChart2 extends ConsumerWidget {
  const CategoriesPieChart2({
    required this.categoryMap,
    required this.total,
    super.key,
  });

  final Map<CategoryTransaction, double> categoryMap;
  final double total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final currencyState = ref.watch(currencyStateNotifier);

    List<PieChartSectionData> sections = categoryMap.entries.map((entry) {
      bool isSelected =
          selectedCategory != null && selectedCategory.id == entry.key.id;
      return PieChartSectionData(
        color: categoryColorList[entry.key.color],
        value: 360 * entry.value / total, // Normalize value for pie chart
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
                  if (pieTouchResponse?.touchedSection != null) {
                    int touchedIndex =
                        pieTouchResponse!.touchedSection!.touchedSectionIndex;
                    if (touchedIndex >= 0 &&
                        touchedIndex < categoryMap.length) {
                      CategoryTransaction touchedCategory =
                          categoryMap.keys.elementAt(touchedIndex);
                      ref.read(selectedCategoryProvider.notifier).state =
                          touchedCategory;
                    } else {
                      ref.read(selectedCategoryProvider.notifier).state = null;
                    }
                  } else {
                    ref.read(selectedCategoryProvider.notifier).state = null;
                  }
                },
              ),
            ),
          ),
          _categoryInfo(context, selectedCategory, currencyState),
        ],
      ),
    );
  }

  Widget _categoryInfo(BuildContext context,
      CategoryTransaction? selectedCategory, CurrencyState currencyState) {
    final bool hasSelection = selectedCategory != null;
    final TextStyle? headlineStyle =
        Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: hasSelection ? green : red,
            );

    double displayAmount =
        hasSelection ? categoryMap[selectedCategory] ?? 0 : total;
    String displayText = hasSelection ? selectedCategory.name : "Total";

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasSelection)
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: categoryColorList[selectedCategory.color],
            ),
            child: Icon(
              iconList[selectedCategory.symbol],
              color: Colors.white,
            ),
          ),
        Text(
          "${displayAmount.toStringAsFixed(2)} ${currencyState.selectedCurrency.symbol}",
          style: headlineStyle,
        ),
        Text(displayText),
      ],
    );
  }
}
