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
    final categories = ref.watch(categoriesProvider);
    final transactions = ref.watch(transactionsProvider);
    final transactionType = ref.watch(selectedTransactionTypeProvider);

    // create a map to link each categories with a list of its transactions
    // stored as Transaction to be passed to CategoryListTile
    Map<int, List<Transaction>> categoryToTransactionsIncome = {},
        categoryToTransactionsExpense = {};
    Map<int, double> categoryToAmountIncome = {}, categoryToAmountExpense = {};
    double totalIncome = 0, totalExpense = 0;

    for (Transaction transaction in transactions.value ?? []) {
      final categoryId = transaction.idCategory;
      if (categoryId != null) {
        if (transaction.type == TransactionType.income) {
          if (categoryToTransactionsIncome.containsKey(categoryId)) {
            categoryToTransactionsIncome[categoryId]?.add(transaction);
          } else {
            categoryToTransactionsIncome.putIfAbsent(
              categoryId,
              () => [transaction],
            );
          }

          // update total amount for the category
          totalIncome += transaction.amount;
          if (categoryToAmountIncome.containsKey(categoryId)) {
            categoryToAmountIncome[categoryId] =
                categoryToAmountIncome[categoryId]! +
                transaction.amount.toDouble();
          } else {
            categoryToAmountIncome.putIfAbsent(
              categoryId,
              () => transaction.amount.toDouble(),
            );
          }
        } else if (transaction.type == TransactionType.expense) {
          if (categoryToTransactionsExpense.containsKey(categoryId)) {
            categoryToTransactionsExpense[categoryId]?.add(transaction);
          } else {
            categoryToTransactionsExpense.putIfAbsent(
              categoryId,
              () => [transaction],
            );
          }

          // update total amount for the category
          totalExpense -= transaction.amount;
          if (categoryToAmountExpense.containsKey(categoryId)) {
            categoryToAmountExpense[categoryId] =
                categoryToAmountExpense[categoryId]! -
                transaction.amount.toDouble();
          } else {
            categoryToAmountExpense.putIfAbsent(
              categoryId,
              () => -transaction.amount.toDouble(),
            );
          }
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: Sizes.xl),
      child: DefaultContainer(
        child: Column(
          spacing: Sizes.lg,
          children: [
            const TransactionTypeButton(),
            categories.when(
              data: (data) {
                List<CategoryTransaction> categoryIncomeList = data
                    .where(
                      (category) =>
                          categoryToAmountIncome.containsKey(category.id),
                    )
                    .toList();
                List<CategoryTransaction> categoryExpenseList = data
                    .where(
                      (category) =>
                          categoryToAmountExpense.containsKey(category.id),
                    )
                    .toList();
                return transactionType == TransactionType.income
                    ? categoryIncomeList.isEmpty
                          ? const SizedBox(
                              height: 400,
                              child: Center(
                                child: Text("No incomes for selected month"),
                              ),
                            )
                          : CategorySection(
                              categoryList: categoryIncomeList,
                              amounts: categoryToAmountIncome,
                              total: totalIncome,
                              transactions: categoryToTransactionsIncome,
                            )
                    : categoryExpenseList.isEmpty
                    ? const SizedBox(
                        height: 400,
                        child: Center(
                          child: Text("No expenses for selected month"),
                        ),
                      )
                    : CategorySection(
                        categoryList: categoryExpenseList,
                        amounts: categoryToAmountExpense,
                        total: totalExpense,
                        transactions: categoryToTransactionsExpense,
                      );
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
  const CategorySection({
    required this.categoryList,
    required this.amounts,
    required this.total,
    required this.transactions,
    super.key,
  });

  final List<CategoryTransaction> categoryList;
  final Map<int, double> amounts;
  final double total;
  final Map<int, List<Transaction>> transactions;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: Sizes.lg,
      children: [
        CategoriesPieChart(
          categories: categoryList,
          amounts: amounts,
          total: total,
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categoryList.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: Sizes.sm),
          itemBuilder: (context, index) {
            CategoryTransaction category = categoryList[index];
            return PanelListTile(
              name: category.name,
              color: categoryColorList[category.color],
              icon: iconList[category.symbol],
              transactions: transactions[category.id] ?? [],
              amount: amounts[category.id] ?? 0,
              percent: (amounts[category.id] ?? 0) / total * 100,
              index: index,
            );
          },
        ),
      ],
    );
  }
}
