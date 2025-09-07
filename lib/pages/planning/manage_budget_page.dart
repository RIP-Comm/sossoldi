import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/budget.dart';
import '../../model/category_transaction.dart';
import '../../ui/device.dart';
import '../../ui/snack_bars/snack_bar.dart';
import 'widget/budget_category_selector.dart';
import '../../../providers/categories_provider.dart';
import '../../../providers/budgets_provider.dart';

class ManageBudgetPage extends ConsumerStatefulWidget {
  final Function() onRefreshBudgets;
  const ManageBudgetPage({required this.onRefreshBudgets, super.key});

  @override
  ConsumerState<ManageBudgetPage> createState() => _ManageBudgetPageState();
}

class _ManageBudgetPageState extends ConsumerState<ManageBudgetPage> {
  List<CategoryTransaction> categories = [];
  List<Budget> budgets = [];
  List<Budget> deletedBudgets = [];
  Set<int> usedCategoryIds = {};

  void _loadCategories() async {
    categories = await ref.read(categoriesProvider.notifier).getCategories();
    categories.removeWhere(
        (element) => element.type == CategoryTransactionType.income);
    budgets = await ref.read(budgetsProvider.notifier).getBudgets();
    usedCategoryIds = budgets.map((b) => b.idCategory).toSet();
    setState(() {});
  }

  void _addBudget(Budget budget) {
    setState(() {
      budgets.add(budget);
      usedCategoryIds.add(budget.idCategory);
    });
  }

  void _updateBudget(Budget updatedBudget, int index) {
    setState(() {
      deletedBudgets.add(budgets[index]);
      budgets[index] = updatedBudget;
      usedCategoryIds.add(updatedBudget.idCategory);
    });
  }

  void _deleteBudget(int index) {
    setState(() {
      deletedBudgets.add(budgets[index]);
      usedCategoryIds.remove(budgets[index].idCategory);
      budgets.removeAt(index);
    });
  }

  Future<void> updateBudget(Budget updatedBudget, int index) async {
    setState(() {
      deletedBudgets.add(budgets[index]);
      budgets[index] = updatedBudget;
    });
    await ref.read(budgetsProvider.notifier).refreshBudgets();
  }

  Future<void> deleteBudget(Budget removedBudget, int index) async {
    setState(() {
      budgets.removeAt(index);
      deletedBudgets.add(removedBudget);
    });
    await ref.read(budgetsProvider.notifier).refreshBudgets();
  }

  void handleEmptyCategories() {
    showSnackBar(
      context,
      message: "Add a category first to set a budget",
      actionLabel: "ADD",
      onAction: () async {
        final categoryAdded = await Navigator.pushNamed(
          context,
          '/add-category',
          arguments: {'hideIncome': true},
        ) as bool?;

        if (categoryAdded ?? false) _loadCategories();
      },
    );
  }

  @override
  void initState() {
    _loadCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final availableCategories =
        categories.where((c) => !usedCategoryIds.contains(c.id)).toList();
    final canAddCategory = availableCategories.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(Sizes.lg),
              child: Text(
                "Select the categories to create your budget",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: Sizes.lg, vertical: Sizes.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CATEGORY',
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    'AMOUNT',
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: budgets.length,
                      itemBuilder: (context, index) {
                        final usedExcludingCurrent =
                            Set<int>.from(usedCategoryIds)
                              ..remove(budgets[index].idCategory);

                        final initCategory = categories.firstWhere(
                          (c) => c.id == budgets[index].idCategory,
                          orElse: () => categories.first,
                        );
                        return Dismissible(
                          key: Key(budgets[index].idCategory.toString()),
                          background: Container(
                            padding: const EdgeInsets.only(right: Sizes.lg),
                            alignment: Alignment.centerRight,
                            color: Colors.red,
                            child: const Text(
                              'Delete',
                              textAlign: TextAlign.right,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          onDismissed: (_) => _deleteBudget(index),
                          child: BudgetCategorySelector(
                            categories: categories,
                            usedCategoryIds: usedExcludingCurrent,
                            budget: budgets[index],
                            initSelectedCategory: initCategory,
                            onBudgetChanged: (updated) =>
                                _updateBudget(updated, index),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: Sizes.sm),
                  Text("Swipe left to delete",
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: Sizes.md),
                  TextButton.icon(
                    icon: Icon(Icons.add_circle, size: 32),
                    onPressed: canAddCategory
                        ? () => _addBudget(Budget(
                              active: true,
                              amountLimit: 100,
                              idCategory: availableCategories[0].id!,
                              name: availableCategories[0].name,
                            ))
                        : null,
                    label: Text("Add category budget"),
                  ),
                  if (!canAddCategory)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "You have already added all available categories.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: Sizes.lg),
            Center(
              child: Text(
                "Your monthly budget will be: ${budgets.isEmpty ? 0 : budgets.fold(0, (sum, e) => sum + e.amountLimit.toInt())}€",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: Sizes.lg),
            const Divider(indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.all(Sizes.lg),
              child: ElevatedButton(
                onPressed: () async {
                  for (var item in deletedBudgets) {
                    await BudgetMethods().deleteByCategory(item.idCategory);
                  }
                  for (var item in budgets) {
                    await BudgetMethods().insertOrUpdate(item);
                  }

                  widget.onRefreshBudgets();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: Text("SAVE BUDGET"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
