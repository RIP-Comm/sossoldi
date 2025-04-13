import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/budget.dart';
import '../../model/category_transaction.dart';
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
          padding: const EdgeInsets.all(15),
          child: Text(
            "Select the categories to create your budget",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      padding: const EdgeInsets.only(right: 20.0),
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
              SizedBox(height: 8),
              Text("Swipe left to delete",
                  style: Theme.of(context).textTheme.bodySmall),
              SizedBox(height: 12),
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
        const SizedBox(height: 16),
        Text(
          "Your monthly budget will be: ${budgets.isEmpty ? 0 : budgets.fold(0, (sum, e) => sum + e.amountLimit.toInt())}€",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        const Divider(indent: 16, endIndent: 16),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
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
              child: Text("SAVE BUDGET"),
            ),
          ),
        ),
      ],
    );
  }
}
