import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/functions.dart';
import '../../../constants/style.dart';
import '../../../custom_widgets/default_container.dart';
import '../../../model/category_transaction.dart';
import '../../../model/transaction.dart';
import '../../../providers/categories_provider.dart';
import '../../../providers/transactions_provider.dart';
import 'categories_pie_chart.dart';
import 'category_list_tile.dart';

final selectedCategoryIndexProvider = StateProvider<int>((ref) => -1);

final selectedTransactionTypeProvider =
    StateProvider<TransactionType>((ref) => TransactionType.income);

class CategoriesTab extends ConsumerStatefulWidget {
  const CategoriesTab({
    super.key,
  });

  @override
  ConsumerState<CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends ConsumerState<CategoriesTab> with Functions {
  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final transactions = ref.watch(transactionsProvider);
    final transactionType = ref.watch(selectedTransactionTypeProvider);

    // create a map to link each categories with a list of its transactions
    // stored as Map<String, dynamic> to be passed to CategoryListTile
    Map<int, List<Map<String, dynamic>>> categoryToTransactionsIncome = {},
        categoryToTransactionsExpense = {};
    Map<int, double> categoryToAmountIncome = {}, categoryToAmountExpense = {};
    double totalIncome = 0, totalExpense = 0;

    for (Transaction transaction in transactions.value ?? []) {
      final categoryId = transaction.idCategory;
      if (categoryId != null) {
        final updateValue = {
          "account": transaction.idBankAccount.toString(),
          "amount": transaction.amount,
          "category": categoryId.toString(),
          "title": transaction.note,
        };
        if (transaction.type == TransactionType.income) {
          if (categoryToTransactionsIncome.containsKey(categoryId)) {
            categoryToTransactionsIncome[categoryId]?.add(updateValue);
          } else {
            categoryToTransactionsIncome.putIfAbsent(categoryId, () => [updateValue]);
          }

          // update total amount for the category
          totalIncome += transaction.amount;
          if (categoryToAmountIncome.containsKey(categoryId)) {
            categoryToAmountIncome[categoryId] =
                categoryToAmountIncome[categoryId]! + transaction.amount.toDouble();
          } else {
            categoryToAmountIncome.putIfAbsent(categoryId, () => transaction.amount.toDouble());
          }
        } else if (transaction.type == TransactionType.expense) {
          if (categoryToTransactionsExpense.containsKey(categoryId)) {
            categoryToTransactionsExpense[categoryId]?.add(updateValue);
          } else {
            categoryToTransactionsExpense.putIfAbsent(categoryId, () => [updateValue]);
          }

          // update total amount for the category
          totalExpense -= transaction.amount;
          if (categoryToAmountExpense.containsKey(categoryId)) {
            categoryToAmountExpense[categoryId] =
                categoryToAmountExpense[categoryId]! - transaction.amount.toDouble();
          } else {
            categoryToAmountExpense.putIfAbsent(categoryId, () => -transaction.amount.toDouble());
          }
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: DefaultContainer(
        child: Column(
          children: [
            const TransactionTypeButton(),
            const SizedBox(height: 16),
            categories.when(
              data: (data) {
                List<CategoryTransaction> categoryIncomeList = data
                    .where((category) => categoryToAmountIncome.containsKey(category.id))
                    .toList();
                List<CategoryTransaction> categoryExpenseList = data
                    .where((category) => categoryToAmountExpense.containsKey(category.id))
                    .toList();
                return transactionType == TransactionType.income
                    ? categoryIncomeList.isEmpty
                        ? const SizedBox(
                            height: 400,
                            child: Center(
                              child: Text("No incomes for selected month"),
                            ),
                          )
                        : Column(
                            children: [
                              CategoriesPieChart(
                                categories: categoryIncomeList,
                                amounts: categoryToAmountIncome,
                                total: totalIncome,
                              ),
                              const SizedBox(height: 16),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: categoryIncomeList.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  CategoryTransaction category = categoryIncomeList[index];
                                  return CategoryListTile(
                                    category: category,
                                    transactions: categoryToTransactionsIncome[category.id] ?? [],
                                    amount: categoryToAmountIncome[category.id] ?? 0,
                                    percent: (categoryToAmountIncome[category.id] ?? 0) /
                                        totalIncome *
                                        100,
                                    index: index,
                                  );
                                },
                              ),
                            ],
                          )
                    : categoryExpenseList.isEmpty
                        ? const SizedBox(
                            height: 400,
                            child: Center(
                              child: Text("No expenses for selected month"),
                            ),
                          )
                        : Column(
                            children: [
                              CategoriesPieChart(
                                categories: categoryExpenseList,
                                amounts: categoryToAmountExpense,
                                total: totalExpense,
                              ),
                              const SizedBox(height: 16),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: categoryExpenseList.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  CategoryTransaction category = categoryExpenseList[index];
                                  return CategoryListTile(
                                    category: category,
                                    transactions: categoryToTransactionsExpense[category.id] ?? [],
                                    amount: categoryToAmountExpense[category.id] ?? 0,
                                    percent: (categoryToAmountExpense[category.id] ?? 0) /
                                        totalExpense *
                                        100,
                                    index: index,
                                  );
                                },
                              ),
                            ],
                          );
              },
              error: (error, stackTrace) => Center(
                child: Text(error.toString()),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Switch between income and expenses
class TransactionTypeButton extends ConsumerWidget {
  const TransactionTypeButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionType = ref.watch(selectedTransactionTypeProvider);
    final width = (MediaQuery.of(context).size.width - 64) * 0.5;
    return Container(
      height: 28,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(5.0),
        ),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: Alignment(
              (transactionType == TransactionType.income) ? -1 : 1,
              0,
            ),
            curve: Curves.decelerate,
            duration: const Duration(milliseconds: 180),
            child: Container(
              width: width,
              height: 28,
              decoration: const BoxDecoration(
                color: blue5,
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              ref.read(selectedTransactionTypeProvider.notifier).state = TransactionType.income;
            },
            child: Align(
              alignment: const Alignment(-1, 0),
              child: Container(
                width: width,
                color: Colors.transparent,
                alignment: Alignment.center,
                child: Text(
                  "Income",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: (transactionType == TransactionType.income) ? white : blue2),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              ref.read(selectedTransactionTypeProvider.notifier).state = TransactionType.expense;
            },
            child: Align(
              alignment: const Alignment(1, 0),
              child: Container(
                width: width,
                color: Colors.transparent,
                alignment: Alignment.center,
                child: Text(
                  'Expenses',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: (transactionType == TransactionType.expense) ? white : blue2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
