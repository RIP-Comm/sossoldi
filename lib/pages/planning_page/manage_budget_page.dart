import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/budget.dart';
import '../../model/category_transaction.dart';
import '../../ui/device.dart';
import 'widget/budget_category_selector.dart';
import '../../../providers/categories_provider.dart';
import '../../../providers/budgets_provider.dart';
import 'widget/missing_category_snackabr.dart';

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

  void _loadCategories() async {
    categories = await ref.read(categoriesProvider.notifier).getCategories();
    categories.removeWhere(
        (element) => element.type == CategoryTransactionType.income);
    budgets = await ref.read(budgetsProvider.notifier).getBudgets();
    setState(() {});
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: MissingCategorySnackBarContent(
          onActionPressed: () async {
            ScaffoldMessenger.of(context).clearSnackBars();
            final bool? categoryAdded;

            // Push /add-category route, saving the returned result.
            //
            // Returned result will be false if no new category is added, true otherwise.
            categoryAdded = await Navigator.pushNamed(
              context,
              '/add-category',
              arguments: {'hideIncome': true},
            ) as bool?;

            // Only call _loadCategories() if a new category has been added.
            //
            // When the user navigates back without adding a category without pressing the back button
            // on the /add-category page, Navigator will return null, which will be handled as a false.
            if (categoryAdded ?? false) _loadCategories();
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    _loadCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(Sizes.lg),
          child: Text(
            "Select the categories to create your budget",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const Padding(
          padding:
              EdgeInsets.symmetric(horizontal: Sizes.lg, vertical: Sizes.sm),
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
              ListView.builder(
                shrinkWrap: true,
                itemCount: budgets.length,
                itemBuilder: (context, index) {
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
                    onDismissed: (direction) {
                      deleteBudget(budgets[index], index);
                    },
                    child: BudgetCategorySelector(
                      categories: categories,
                      categoriesAlreadyUsed: categories
                          .where((element) =>
                              budgets.map((e) => e.name).contains(element.name))
                          .map((e) => e.name)
                          .toList(),
                      budget: budgets[index],
                      initSelectedCategory: categories
                              .where((element) =>
                                  element.id == budgets[index].idCategory)
                              .isEmpty
                          ? categories[0]
                          : categories
                              .where((element) =>
                                  element.id == budgets[index].idCategory)
                              .first,
                      onBudgetChanged: (updatedBudget) {
                        updateBudget(updatedBudget, index);
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: Sizes.xs),
              Text("Swipe left to delete",
                  style: Theme.of(context).textTheme.bodySmall),
              SizedBox(height: Sizes.md),
              TextButton.icon(
                icon: Icon(Icons.add_circle, size: 32),
                onPressed: () {
                  setState(() {
                    budgets.add(Budget(
                        active: true,
                        amountLimit: 100,
                        idCategory: categories[0].id!,
                        name: categories[0].name));
                  });
                },
                label: Text("Add category budget"),
              ),
            ],
          ),
        ),
        const SizedBox(height: Sizes.lg),
        Text(
          "Your monthly budget will be: ${budgets.isEmpty ? 0 : budgets.fold(0, (sum, e) => sum + e.amountLimit.toInt())}€",
          style: Theme.of(context).textTheme.titleMedium,
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
              setState(() {
                widget.onRefreshBudgets();
                Navigator.of(context).pop();
              });
            },
            style: ElevatedButton.styleFrom(elevation: 2),
            child: Center(child: Text("SAVE BUDGET")),
          ),
        ),
      ],
    );
  }
}
