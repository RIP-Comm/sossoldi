import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/constants.dart';
import '../../../ui/widgets/default_container.dart';
import '../../../ui/widgets/transaction_type_button.dart';
import '../../../model/category_transaction.dart';
import '../../../model/transaction.dart';
import '../../../providers/categories_provider.dart';
import '../../../providers/transactions_provider.dart';
import '../../../ui/device.dart';
import 'categories_pie_chart.dart';
import 'panel_list_tile.dart';

class CategoriesTab extends ConsumerWidget {
  const CategoriesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesData = ref.watch(categoryWithSubcategoriesDataProvider);
    final transactionType = ref.watch(selectedTransactionTypeProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: Sizes.xl),
      child: DefaultContainer(
        child: Column(
          spacing: Sizes.lg,
          children: [
            const TransactionTypeButton(),
            categoriesData.when(
              data: (data) {
                if (data.isEmpty) {
                  return SizedBox(
                    height: 400,
                    child: Center(
                      child: Text(
                        "No ${transactionType == TransactionType.income ? 'incomes' : 'expenses'} for selected month",
                      ),
                    ),
                  );
                }

                return CategorySection(categoryData: data);
              },
              error: (error, stackTrace) =>
                  Center(child: Text(error.toString())),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}

class CategorySection extends StatelessWidget {
  const CategorySection({required this.categoryData, super.key});

  final List<ParentCategoryWithSubcategoriesData> categoryData;

  @override
  Widget build(BuildContext context) {
    final List<CategoryTransaction> categories = categoryData
        .map((e) => e.parentCategory)
        .toList();
    final Map<int, double> amounts = categoryData.asMap().map((
      index,
      categoryData,
    ) {
      return MapEntry(
        categoryData.parentCategory.id!,
        categoryData.total.toDouble(),
      );
    });
    double total = categoryData.map((e) => e.total).fold(0, (a, b) => a + b);
    final Map<int, List<Transaction>> transactions = categoryData.asMap().map((
      index,
      categoryData,
    ) {
      return MapEntry(
        categoryData.parentCategory.id!,
        categoryData.transactions,
      );
    });
    return Column(
      spacing: Sizes.lg,
      children: [
        CategoriesPieChart(
          categories: categories,
          amounts: amounts,
          total: total,
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: Sizes.sm),
          itemBuilder: (context, index) {
            CategoryTransaction category = categories[index];
            return PanelListTile(
              name: category.name,
              color: categoryColorList[category.color],
              icon: iconList[category.symbol],
              transactions: transactions[category.id] ?? [],
              amount: amounts[category.id] ?? 0,
              percent: (amounts[category.id] ?? 0) / total * 100,
              index: index,
              enableSubcategories: true,
            );
          },
        ),
      ],
    );
  }
}
