import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/budget.dart';
import '../../model/category_transaction.dart';
import '../../providers/currency_provider.dart';
import '../../ui/device.dart';
import '../../ui/extensions.dart';
import '../../ui/snack_bars/snack_bar.dart';
import 'widget/budget_category_selector.dart';
import '../../../providers/categories_provider.dart';
import '../../../providers/budgets_provider.dart';

class ManageBudgetPage extends ConsumerStatefulWidget {
  const ManageBudgetPage({super.key});

  @override
  ConsumerState<ManageBudgetPage> createState() => _ManageBudgetPageState();
}

class _ManageBudgetPageState extends ConsumerState<ManageBudgetPage> {
  List<CategoryTransaction> categories = [];
  List<Budget> budgets = [];
  List<Budget> deletedBudgets = [];
  Set<int> usedCategoryIds = {};

  void _loadCategories() async {
    categories = await ref.read(allParentCategoriesProvider.future);
    categories.removeWhere(
      (element) => element.type == CategoryTransactionType.income,
    );
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
      usedCategoryIds.remove(budgets[index].idCategory);
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

  void handleEmptyCategories() {
    showSnackBar(
      context,
      message: "Add a category first to set a budget",
      actionLabel: "ADD",
      onAction: () async {
        final categoryAdded =
            await Navigator.pushNamed(
                  context,
                  '/add-category',
                  arguments: {'hideIncome': true},
                )
                as bool?;

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
    final availableCategories = categories
        .where((c) => !usedCategoryIds.contains(c.id))
        .toList();
    final canAddCategory = availableCategories.isNotEmpty;
    final currencyState = ref.watch(currencyStateProvider);

    return Scaffold(
      persistentFooterDecoration: const BoxDecoration(),
      persistentFooterButtons: [
        Column(
          children: [
            Text(
              "Swipe left to delete",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: Sizes.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Your monthly budget will be: ",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text.rich(
                    TextSpan(
                      text:
                          "${(budgets.isEmpty ? 0 : budgets.fold<num>(0, (sum, e) => sum + e.amountLimit)).toCurrency()} ",
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      children: [
                        TextSpan(
                          text: currencyState.symbol,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Sizes.lg),
            const Divider(indent: 16, endIndent: 16),
            Container(
              padding: const EdgeInsets.all(Sizes.lg),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await ref
                      .read(budgetsProvider.notifier)
                      .saveBudget(budgets, deletedBudgets);

                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text("SAVE BUDGET"),
              ),
            ),
          ],
        ),
      ],
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
                horizontal: Sizes.lg,
                vertical: Sizes.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('CATEGORY', textAlign: TextAlign.left),
                  Text('AMOUNT', textAlign: TextAlign.right),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: budgets.length + 1,
                      itemBuilder: (context, index) {
                        if (index == budgets.length) {
                          if (canAddCategory) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: Sizes.md,
                                horizontal: Sizes.xxl,
                              ),
                              child: TextButton.icon(
                                icon: const Icon(Icons.add_circle, size: 32),
                                onPressed: () => _addBudget(
                                  Budget(
                                    active: true,
                                    amountLimit: 100,
                                    idCategory: availableCategories[0].id!,
                                    name: availableCategories[0].name,
                                  ),
                                ),
                                label: const Text("Add category budget"),
                              ),
                            );
                          } else {
                            return const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Center(
                                child: Text(
                                  "You have already added all available categories.",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            );
                          }
                        }

                        final usedExcludingCurrent = Set<int>.from(
                          usedCategoryIds,
                        )..remove(budgets[index].idCategory);
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
