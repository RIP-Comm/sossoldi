import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../ui/widgets/category_type_button.dart';
import '../../../../ui/widgets/default_container.dart';
import '../../../../model/category_transaction.dart';
import '../../../../providers/categories_provider.dart';
import '../../../../ui/device.dart';
import '../../../transactions_page/widgets/month_selector.dart';
import '../card_label.dart';
import '../linear_progress_bar.dart';
import 'categories_bar_chart.dart';
import 'categories_pie_chart2.dart';
import 'category_label.dart';

class CategoriesCard extends ConsumerStatefulWidget {
  const CategoriesCard({super.key});

  @override
  ConsumerState<CategoriesCard> createState() => CategoriesCardState();
}

class CategoriesCardState extends ConsumerState<CategoriesCard> {
  int _categoriesCount = 0;

  @override
  Widget build(BuildContext context) {
    final categoryMap = ref.watch(categoryMapProvider);
    final categoryTotalAmount =
        ref.watch(categoryTotalAmountProvider).value ?? 0;

    return Column(
      children: [
        const CardLabel(label: "Categories"),
        const SizedBox(height: 10),
        DefaultContainer(
          child: Column(
            children: [
              const MonthSelector(type: MonthSelectorType.simple),
              const SizedBox(height: 30),
              const CategoryTypeButton(),
              const SizedBox(height: 20),
              categoryMap.when(
                data: (categories) {
                  _categoriesCount = categories.length;

                  return categoryTotalAmount != 0
                      ? CategoriesContent(
                          categories: categories,
                          totalAmount: categoryTotalAmount,
                        )
                      : const NoTransactionsContent();
                },
                loading: () => LoadingContentWidget(
                    previousCategoriesCount: _categoriesCount),
                error: (e, s) => Text("Error: $e"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CategoriesContent extends StatelessWidget {
  const CategoriesContent({
    required this.categories,
    required this.totalAmount,
    super.key,
  });

  final Map<CategoryTransaction, double> categories;
  final double totalAmount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CategoriesPieChart2(
          categoryMap: categories,
          total: totalAmount,
        ),
        const SizedBox(height: 20),
        ListView.builder(
          itemCount: categories.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, i) {
            final category = categories.keys.elementAt(i);
            final amount = categories[category] ?? 0;
            return CategoryItem(
              category: category,
              amount: amount,
              totalAmount: totalAmount,
            );
          },
        ),
        const SizedBox(height: 30),
        const CategoriesBarChart(),
      ],
    );
  }
}

class CategoryItem extends StatelessWidget {
  const CategoryItem({
    required this.category,
    required this.amount,
    required this.totalAmount,
    super.key,
  });

  final CategoryTransaction category;
  final double amount;
  final double totalAmount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.0,
      child: Column(
        children: [
          const Padding(padding: EdgeInsets.all(Sizes.xxs * 0.5)),
          CategoryLabel(
            category: category,
            amount: amount,
            total: totalAmount,
          ),
          const SizedBox(height: 4.0),
          LinearProgressBar(
            type: BarType.category,
            amount: amount,
            total: totalAmount,
            colorIndex: category.color,
          ),
        ],
      ),
    );
  }
}

class LoadingContentWidget extends StatelessWidget {
  final int previousCategoriesCount;

  const LoadingContentWidget({
    super.key,
    required this.previousCategoriesCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // height of CategoriesPieChart2
        const SizedBox(height: 200),
        const SizedBox(height: 20),
        // Height of CategoryItem's list
        SizedBox(height: 50.0 * previousCategoriesCount),
        const SizedBox(height: 30),
        // Height of CategoriesBarChart
        const SizedBox(height: 200),
      ],
    );
  }
}

class NoTransactionsContent extends StatelessWidget {
  const NoTransactionsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Text(
          "After you add some transactions, some outstanding graphs will appear here... almost by magic!",
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
