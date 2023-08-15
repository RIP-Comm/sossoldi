import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/pages/onboarding_page/widgets/account_setup.dart';
import '/pages/onboarding_page/widgets/add_budget.dart';
import '/model/budget.dart';
import '/providers/categories_provider.dart';
import '/constants/constants.dart';
import '/constants/style.dart';
import '/model/category_transaction.dart';
import '/providers/budgets_provider.dart';
import 'package:collection/collection.dart';

class BudgetSetup extends ConsumerStatefulWidget {
  const BudgetSetup({Key? key}) : super(key: key);

  @override
  ConsumerState<BudgetSetup> createState() => _BudgetSetupState();
}

class _BudgetSetupState extends ConsumerState<BudgetSetup> {
  // sum of the budget of the selected cards
  int totalBudget = 0;

  @override
  Widget build(BuildContext context) {
    final categoriesGrid = ref.watch(categoriesProvider);
    return Scaffold(
      backgroundColor: blue7,
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text("STEP 1 OF 2", style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 20),
            Text(
              "Set up your monthly\nbudgets",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(color: blue1),
            ),
            const SizedBox(height: 30),
            Text(
              "Choose which categories you want to set a budget for",
              textAlign: TextAlign.center,
              style:
                  Theme.of(context).textTheme.bodySmall?.copyWith(color: blue1),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 0, bottom: 0, left: 16, right: 16),
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
                            child: Container(
                              child: buildCard(categories.elementAt(i)),
                            ),
                          );
                        } else {
                          return GestureDetector(
                            onTap: () => Navigator.of(context)
                                .pushNamed('/add-category'),
                            child: buildDefaultCard(),
                          );
                        }
                      },
                    ),
                    error: (err, stack) => Text('Error: $err'),
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
            ),

            // if the total budget (sum of the budget of the selected cards) is > 0, set the other layout. otherwise set the "continue without budget" button
            totalBudget > 0
                ? Center(
                    child: Column(
                      children: [
                        Text("Monthly budget total:",
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 10),
                        RichText(
                          textScaleFactor:
                              MediaQuery.of(context).textScaleFactor,
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
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 342,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AccountSetup()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: blue5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
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
                : Padding(
                    padding: const EdgeInsets.only(left: 75, right: 75),
                    child: ElevatedButton(
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
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 1.0),
                        decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(width: 1.2, color: black))),
                        child: Row(
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
                      ),
                    ),
                  ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildCard(CategoryTransaction category) {
    final budgetsList = ref.watch(budgetsProvider);
    Color categoryColor = categoryColorList[category.color];
    String categoryName = category.name;
    if (budgetsList is AsyncData<List<CategoryTransaction>>) {
      final budgets = budgetsList.value;

      Budget? budget =
          budgets?.firstWhereOrNull((c) => c.idCategory == category.id);

      if (budget != null && budget.active) {
        return Container(
          color: categoryColor,
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: categoryColor, width: 2.5),
                color: categoryColor,
                borderRadius: const BorderRadius.all(Radius.circular(8))),
            alignment: Alignment.center,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: categoryColor,
                  radius: 15.0,
                  child: CircleAvatar(
                    backgroundColor: white,
                    radius: 13,
                    child: Icon(Icons.check, color: categoryColor, size: 22),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 125,
                      child: Text(
                        categoryName,
                        textAlign: TextAlign.left,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.apply(color: white),
                      ),
                    ),
                    SizedBox(
                      width: 95,
                      child: Text(
                        "BUDGET: ${budget.amountLimit}€",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.apply(color: white),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      }
    }
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: categoryColor, width: 2.5),
        color: HSLColor.fromColor(categoryColor)
            .withLightness(clampDouble(0.99, 0.0, 0.9))
            .toColor(),
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      alignment: Alignment.center,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: CircleAvatar(
              backgroundColor: blue1,
              radius: 15.0,
              child: CircleAvatar(
                  backgroundColor: HSLColor.fromColor(categoryColor)
                      .withLightness(clampDouble(0.99, 0.0, 0.9))
                      .toColor(),
                  radius: 13,
                  child: const Icon(Icons.add, color: blue1)),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                  width: 95,
                  child: Text(
                    categoryName,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.bodyMedium,
                  )),
              SizedBox(
                  width: 95,
                  child: Text("ADD BUDGET",
                      style: Theme.of(context).textTheme.bodySmall)),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDefaultCard() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: grey2, width: 1.5),
        color: grey3,
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      alignment: Alignment.center,
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 10),
            child: CircleAvatar(
              backgroundColor: grey1,
              radius: 15.0,
              child: CircleAvatar(
                backgroundColor: grey3,
                radius: 13,
                child: Icon(Icons.add, color: grey1),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 125,
                child: Text(
                  "Add category",
                  textAlign: TextAlign.left,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.apply(color: grey1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
