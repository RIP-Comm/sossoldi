import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../custom_widgets/category_type_button.dart';
import '../../../../custom_widgets/default_container.dart';
import '../../../../model/category_transaction.dart';
import '../../../../providers/categories_provider.dart';
import '../../../transactions_page/widgets/month_selector.dart';
import '../card_label.dart';
import '../linear_progress_bar.dart';
import 'categories_bar_chart.dart';
import 'categories_pie_chart2.dart';
import 'category_label.dart';

class CategoriesCard extends ConsumerWidget {
  const CategoriesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryType = ref.watch(categoryTypeProvider);
    final categoryMap = ref.watch(categoryMapProvider(categoryType));
    final categoryTotalAmount =
        ref.watch(categoryTotalAmountProvider(categoryType)).value ?? 0;

    return Column(
      children: [
        const CardLabel(label: "Categories"),
        const SizedBox(height: 10),
        DefaultContainer(
          child: categoryMap.when(
            data: (categories) {
              return categoryTotalAmount != 0
                  ? CategoriesContent(
                      categories: categories, totalAmount: categoryTotalAmount)
                  : const NoTransactionsContent();
            },
            loading: () => const SizedBox.shrink(),
            error: (e, s) => Text("Error: $e"),
          ),
        ),
      ],
    );
  }
}

class CategoriesContent extends StatelessWidget {
  const CategoriesContent(
      {required this.categories, required this.totalAmount, super.key});

  final Map<CategoryTransaction, double> categories;
  final double totalAmount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const MonthSelector(type: MonthSelectorType.simple),
        const SizedBox(height: 30),
        const CategoryTypeButton(),
        const SizedBox(height: 20),
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
                category: category, amount: amount, totalAmount: totalAmount);
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
          const Padding(padding: EdgeInsets.all(2.0)),
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

class NoTransactionsContent extends StatelessWidget {
  const NoTransactionsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        MonthSelector(type: MonthSelectorType.simple),
        SizedBox(height: 20),
        CategoryTypeButton(),
        SizedBox(height: 20),
        NoTransactionsMessage(),
      ],
    );
  }
}

class NoTransactionsMessage extends StatelessWidget {
  const NoTransactionsMessage({super.key});

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
