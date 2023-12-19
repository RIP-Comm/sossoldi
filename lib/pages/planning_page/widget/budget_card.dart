import 'package:flutter/material.dart';

import '../../../model/budget.dart';
import 'budget_pie_chart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class BudgetCard extends StatefulWidget {
  const BudgetCard({super.key});

  @override
  State<BudgetCard> createState() => _BudgetCardState();
}

class _BudgetCardState extends State<BudgetCard> {
  int touchedIndex = -1;

  // temporary static data
  List<Budget> budgets = [
    const Budget(idCategory: 1, amountLimit: 100, active: true, name: "Travel"),
    const Budget(idCategory: 2, amountLimit: 200, active: true, name: "Health"),
  ];

  createBudget() {
    print("create budget");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: budgets.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.composition,
                        style: Theme.of(context).textTheme.titleLarge),
                    BudgetPieChart(budgets: budgets),
                    Text(AppLocalizations.of(context)!.progress,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: budgets.length,
                      itemBuilder: (BuildContext context, int index) {
                        // Temporary static data of the amount spent on a budget.
                        int spent = 15;
                        Budget budget = budgets.elementAt(index);
                        return Column(
                          children: [
                            Row(
                              children: [
                                Text(budget.name!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.normal)),
                                const Spacer(),
                                Text("$spent/${budget.amountLimit}€",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.normal))
                              ],
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                                height: 10,
                                child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    child: LinearProgressIndicator(
                                      value: spent / budget.amountLimit,
                                      backgroundColor: index == 0
                                          ? Colors.deepPurple.withOpacity(0.3)
                                          : Colors.blue.withOpacity(0.3),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          index == 0
                                              ? Colors.deepPurple
                                              : Colors.blue),
                                      color: Colors.black,
                                    )))
                          ],
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(height: 15);
                      },
                    ),
                    const SizedBox(height: 5),
                    const Divider(color: Colors.black),
                    const SizedBox(height: 5),
                    ElevatedButton.icon(
                      icon: Icon(
                        Icons.add_circle,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      onPressed: createBudget,
                      label: Text(
                        AppLocalizations.of(context)!.addCategoryBudget,
                        style: Theme.of(context).textTheme.titleSmall!.apply(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        fixedSize: const Size(330, 50),
                      ),
                    )
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("There are no budget set",
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 13),
                        textAlign: TextAlign.center),
                    Image.asset(
                      'assets/wallet.png',
                      width: 240,
                      height: 240,
                    ),
                    const Text(
                        "A monthly budget can help you keep track of your expenses and stay within the limits",
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 13),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      icon: Icon(
                        Icons.add_circle,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      onPressed: createBudget,
                      label: Text(
                        "Create budget",
                        style: Theme.of(context).textTheme.titleSmall!.apply(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        fixedSize: const Size(330, 50),
                      ),
                    )
                  ],
                ),
        ));
  }
}
