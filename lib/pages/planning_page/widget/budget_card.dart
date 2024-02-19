import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sossoldi/pages/planning_page/manage_budget_page.dart';
import 'package:sossoldi/providers/transactions_provider.dart';

import '../../../constants/constants.dart';
import '../../../constants/style.dart';
import '../../../model/budget.dart';
import '../../../model/transaction.dart';
import '../../../providers/budgets_provider.dart';
import 'budget_pie_chart.dart';

class BudgetCard extends ConsumerStatefulWidget {
  final Function() onRefreshBudgets;
  const BudgetCard(this.onRefreshBudgets, {super.key});

  @override
  ConsumerState<BudgetCard> createState() => _BudgetCardState();
}

class _BudgetCardState extends ConsumerState<BudgetCard> {
  @override
  Widget build(BuildContext context) {
    final budgets = ref.watch(budgetsProvider.notifier).getBudgets();
    final transactions =
        ref.watch(transactionsProvider.notifier).getMonthlyTransactions();
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder(
              future: Future.wait([budgets, transactions]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  List budgets = snapshot.data?[0] ?? [];
                  List transactions = snapshot.data?[1] ?? [];
                  return snapshot.data!.isNotEmpty && budgets.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Composition",
                                style: Theme.of(context).textTheme.titleLarge),
                            BudgetPieChart(budgets: budgets as List<Budget>),
                            Text("Progress",
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 10),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: budgets.length,
                              itemBuilder: (BuildContext context, int index) {
                                int spent = (transactions as List<Transaction>)
                                    .where((t) =>
                                        t.idCategory ==
                                        budgets[index].idCategory)
                                    .fold(
                                        0, (sum, t) => sum + t.amount.toInt());
                                Budget budget = budgets.elementAt(index);
                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          budget.name!,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.normal),
                                        ),
                                        const Spacer(),
                                        Text(
                                          "$spent/${budget.amountLimit}€",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(16)),
                                      child: LinearProgressIndicator(
                                        value: (spent == 0 ||
                                                budget.amountLimit == 0)
                                            ? 0
                                            : spent / budget.amountLimit,
                                        minHeight: 16,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                categoryColorList[index]),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(16)),
                                      ),
                                    ),
                                  ],
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return const SizedBox(height: 15);
                              },
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Text(
                              "There are no budget set",
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                            Image.asset(
                              'assets/wallet.png',
                              width: 240,
                              height: 240,
                            ),
                            Text(
                              "A monthly budget can help you keep track of your expenses and stay within the limits",
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 15),
                            TextButton.icon(
                              icon: Icon(
                                Icons.add_circle,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return ManageBudgetPage(
                                        onRefreshBudgets:
                                            widget.onRefreshBudgets);
                                  },
                                );
                              },
                              label: Text(
                                "Create budget",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .apply(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white,
                              ),
                            )
                          ],
                        );
                }
              })),
    );
  }
}
