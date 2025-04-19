import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../add_category_feature/presentation/add_category.dart';
import '../../../ui/device.dart';
import '/constants/constants.dart';
import '/constants/style.dart';
import '../../../models/budget.dart';
import 'account_setup.dart';
import 'add_budget.dart';
import '/providers/budgets_provider.dart';
import '/providers/categories_provider.dart';
import 'add_category_button.dart';
import 'category_button.dart';

class BudgetSetup extends ConsumerStatefulWidget {
  const BudgetSetup({super.key});

  @override
  ConsumerState<BudgetSetup> createState() => _BudgetSetupState();
}

class _BudgetSetupState extends ConsumerState<BudgetSetup> {
  // sum of the budget of the selected cards

  List<Budget>? budgetsList = [];
  num totalBudget = 0; //ref.read(budgetAmountLimitProvider.notifier).state;

  @override
  Widget build(BuildContext context) {
    budgetsList = ref.watch(budgetsProvider).value;
    totalBudget = budgetsList?.fold<num>(
            0, (total, budget) => total + budget.amountLimit) ??
        0;
    final categoriesGrid = ref.watch(categoriesProvider);
    return Scaffold(
      backgroundColor: blue7,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.lg),
          child: Column(
            children: [
              Text("STEP 1 OF 2",
                  style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: Sizes.xl),
              Text(
                "Set up your monthly\nbudgets",
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(color: blue1),
              ),
              const SizedBox(height: Sizes.xxl),
              Text(
                "Choose which categories you want to set a budget for",
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: blue1),
              ),
              const SizedBox(height: Sizes.lg),
              Expanded(
                child: NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (OverscrollIndicatorNotification overscroll) {
                    overscroll.disallowIndicator();
                    return true;
                  },
                  child: categoriesGrid.when(
                    data: (categories) => GridView.builder(
                      itemCount: categories.length + 1,
                      scrollDirection: Axis.vertical,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 300,
                        childAspectRatio: 3,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, i) {
                        if (i < categories.length) {
                          return GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      AddBudget(categories.elementAt(i)),
                                );
                              },
                              child: CategoryButton(
                                categoryColor: categoryColorList[
                                    categories.elementAt(i).color],
                                categoryName: categories.elementAt(i).name,
                                budget: budgetsList?.firstWhereOrNull(
                                    (budget) =>
                                        budget.idCategory ==
                                        categories.elementAt(i).id),
                              ));
                        } else {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddCategory(hideIncome: true),
                                ),
                              );
                            },
                            child: const AddCategoryButton(),
                          );
                        }
                      },
                    ),
                    error: (err, stack) => Text('Error: $err'),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),

              // if the total budget (sum of the budget of the selected cards) is > 0, set the other layout. otherwise set the "continue without budget" button
              totalBudget > 0
                  ? Center(
                      child: Column(
                        children: [
                          const SizedBox(height: Sizes.sm),
                          Text("Monthly budget total:",
                              style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: Sizes.sm),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: totalBudget.toString(),
                                  style:
                                      Theme.of(context).textTheme.displayMedium,
                                ),
                                TextSpan(
                                  text: "€",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.apply(
                                    fontFeatures: [
                                      const FontFeature.subscripts()
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: Sizes.xl),
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AccountSetup()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: blue5,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(Sizes.borderRadius),
                                ),
                              ),
                              child: Text('NEXT STEP',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AccountSetup()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        shadowColor: Colors.transparent,
                        backgroundColor: Colors.transparent,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('CONTINUE WITHOUT BUDGET  ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: blue1)),
                              const Icon(Icons.arrow_forward,
                                  size: 15, color: blue1),
                            ],
                          ),
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width / 1.6,
                            child: const Divider(
                              color: blue1,
                              thickness: 1,
                            ),
                          )
                        ],
                      ),
                    ),
              const SizedBox(height: Sizes.xl),
            ],
          ),
        ),
      ),
    );
  }
}
