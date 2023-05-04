import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sossoldi/constants/constants.dart';

import '../../../constants/style.dart';
import '../../../constants/functions.dart';
import '../../../model/category_transaction.dart';
import '../../../providers/categories_provider.dart';
import '../../../providers/transactions_provider.dart';
import 'categories_pie_chart.dart';
import 'category_list_tile.dart';

enum Type { income, expense }

class CategoriesTab extends ConsumerStatefulWidget {
  const CategoriesTab({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends ConsumerState<CategoriesTab> with Functions {
  final selectedCategory = ValueNotifier<int>(-1);

  /// income or expenses
  final transactionType = ValueNotifier<int>(Type.income.index);

  @override
  Widget build(BuildContext context) {
    // TODO: query only categories with expenses/income during the selected month
    final categories = ref.watch(categoriesProvider);
    final transactions = ref.watch(transactionsProvider);

    // create a map to link each categories with a list of its transactions
    // stored as Map<String, dynamic> to be passed to CategoryListTile
    Map<int, List<Map<String, dynamic>>> categoryToTransactions = {};
    Map<int, double> categoryToAmount = {};
    double total = 0;

    if (transactions.value != null) {
      for (var t in transactions.value!) {
        // add transaction to its category
        int categoryId = t.idCategory!;
        if (categoryToTransactions.containsKey(categoryId)) {
          categoryToTransactions[categoryId]?.add({
            "account": t.idBankAccount.toString(),
            "amount": t.amount,
            "category": categoryId.toString(),
            "title": t.note,
          });
        } else {
          categoryToTransactions.putIfAbsent(
            categoryId,
            () => [
              {
                "account": t.idBankAccount.toString(),
                "amount": t.amount,
                "category": categoryId.toString(),
                "title": t.note,
              }
            ],
          );
        }

        // update total amount for the category
        total += t.amount;
        if (categoryToAmount.containsKey(categoryId)) {
          categoryToAmount[categoryId] =
              categoryToAmount[categoryId]! + t.amount.toDouble();
        } else {
          categoryToAmount.putIfAbsent(categoryId, () => t.amount.toDouble());
        }
      }
    }

    // Add missing catogories (with amount 0)
    // This will be removed when only categories with transactions are queried
    for (var c in categories.value!) {
      categoryToAmount.putIfAbsent(c.id!, () => 0);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      color: grey3,
      child: ListView(
        children: [
          const SizedBox(height: 12.0),
          TransactionTypeButton(
            width: MediaQuery.of(context).size.width,
            notifier: transactionType,
          ),
          const SizedBox(height: 16),
          categories.when(
            data: (data) => CategoriesPieChart(
              notifier: selectedCategory,
              categories: categories.value!,
              amounts: categoryToAmount,
              total: total,
            ),
            error: (error, stackTrace) => Center(
              child: Text(error.toString()),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          const SizedBox(height: 16),
          categories.when(
            data: (data) {
              return ValueListenableBuilder(
                valueListenable: selectedCategory,
                builder: (context, value, child) {
                  return SizedBox(
                    // calculate height from the number of categories and transactions
                    //! it throws RenderFlex overflowed during the closing animation
                    height: 72.0 * categories.value!.length +
                        ((value != -1)
                            ? (categoryToTransactions[
                                            categories.value![value].id]
                                        ?.length ??
                                    0.0) *
                                70.0
                            : 0.0),
                    child: Column(
                      children: List.generate(
                        categories.value!.length,
                        (index) {
                          CategoryTransaction t = categories.value![index];
                          return CategoryListTile(
                            title: t.name,
                            nTransactions:
                                categoryToTransactions[t.id]?.length ?? 0,
                            transactions: categoryToTransactions[t.id] ?? [],
                            amount: categoryToAmount[t.id] ?? 0,
                            percent:
                                (categoryToAmount[t.id] ?? 0) / total * 100,
                            color: const Color(0xFFEBC35F),
                            icon: iconList[t.symbol] ??
                                Icons.swap_horiz_rounded,
                            notifier: selectedCategory,
                            index: index,
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
            error: (error, stackTrace) => Center(
              child: Text(error.toString()),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          const SizedBox(height: 12.0),
        ],
      ),
    );
  }
}

/// Switch between income and expenses
class TransactionTypeButton extends StatelessWidget {
  const TransactionTypeButton({
    super.key,
    required this.width,
    required this.notifier,
  });

  final ValueNotifier<int> notifier;
  final double width;
  final double height = 28.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(5.0),
        ),
      ),
      child: ValueListenableBuilder(
        valueListenable: notifier,
        builder: (context, value, child) {
          return Stack(
            children: [
              AnimatedAlign(
                alignment: Alignment(
                  (notifier.value == Type.income.index) ? -1 : 1,
                  0,
                ),
                curve: Curves.decelerate,
                duration: const Duration(milliseconds: 180),
                child: Container(
                  width: width * 0.5,
                  height: height,
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
                  notifier.value = Type.income.index;
                },
                child: Align(
                  alignment: const Alignment(-1, 0),
                  child: Container(
                    width: width * 0.5,
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    child: Text(
                      "Income",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: (notifier.value == Type.income.index)
                              ? white
                              : blue2),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  notifier.value = Type.expense.index;
                },
                child: Align(
                  alignment: const Alignment(1, 0),
                  child: Container(
                    width: width * 0.5,
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    child: Text(
                      'Expenses',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: (notifier.value == Type.expense.index)
                              ? white
                              : blue2),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
