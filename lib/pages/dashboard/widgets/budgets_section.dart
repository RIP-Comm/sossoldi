import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/constants.dart';

import '../../../ui/widgets/budget_circular_indicator.dart';
import '../../../providers/budgets_provider.dart';
import '../../../providers/categories_provider.dart';
import '../../../providers/transactions_provider.dart';
import '../../../ui/device.dart';

class BudgetsSection extends ConsumerWidget {
  const BudgetsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetsProvider);
    final transactionsAsync = ref.watch(monthlyTransactionsProvider);
    final categoriesAsync = ref.watch(allParentCategoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Sizes.lg,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: Sizes.lg),
            child: Text(
              "Your budgets",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        budgetsAsync.when(
          data: (budgets) {
            if (budgets.isEmpty) {
              return Container(
                height: 120,
                padding: const EdgeInsets.only(bottom: Sizes.xl),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "No budget set",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: Sizes.sm),
                    Text(
                      "Create a budget to track your spending",
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }
            return transactionsAsync.when(
              data: (transactions) => categoriesAsync.when(
                data: (categories) {
                  return SizedBox(
                    height: 150,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: budgets.length,
                      itemBuilder: (context, index) {
                        final budget = budgets[index];
                        final category = categories.firstWhereOrNull(
                          (cat) => cat.id == budget.idCategory,
                        );
                        if (category == null) return const SizedBox();
                        final double spent = transactions
                            .where(
                              (t) =>
                                  t.idCategory == budget.idCategory ||
                                  t.categoryParent == budget.idCategory,
                            )
                            .fold(0.0, (sum, t) => sum + t.amount);
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Sizes.md,
                          ),
                          child: BudgetCircularIndicator(
                            title: budget.name!,
                            amount: max(0, budget.amountLimit - spent),
                            perc: budget.amountLimit > 0
                                ? min(1, spent / budget.amountLimit)
                                : 0,
                            color: categoryColorList[category.color],
                          ),
                        );
                      },
                    ),
                  );
                },
                error: (err, stack) => Text('Error: $err'),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => Text('Error: $err'),
              loading: () => const Center(child: CircularProgressIndicator()),
            );
          },
          error: (err, stack) => Text('Error: $err'),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }
}
