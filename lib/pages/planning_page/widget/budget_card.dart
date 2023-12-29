import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/style.dart';
import '../../../model/budget.dart';
import '../../../providers/budgets_provider.dart';
import 'budget_pie_chart.dart';

class BudgetCard extends ConsumerStatefulWidget {
  const BudgetCard({super.key});

  @override
  ConsumerState<BudgetCard> createState() => _BudgetCardState();
}

class _BudgetCardState extends ConsumerState<BudgetCard> {
  @override
  Widget build(BuildContext context) {
    final budgets = ref.watch(budgetsProvider);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: budgets.when(
          data: (data) {
            return data.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Composition", style: Theme.of(context).textTheme.titleLarge),
                      BudgetPieChart(budgets: data),
                      Text("Progress", style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 10),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: data.length,
                        itemBuilder: (BuildContext context, int index) {
                          // Temporary static data of the amount spent on a budget.
                          int spent = 50;
                          Budget budget = data.elementAt(index);
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    budget.name!,
                                    style: const TextStyle(fontWeight: FontWeight.normal),
                                  ),
                                  const Spacer(),
                                  Text(
                                    "$spent/${budget.amountLimit}€",
                                    style: const TextStyle(fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: const BorderRadius.all(Radius.circular(16)),
                                child: LinearProgressIndicator(
                                  value: spent / budget.amountLimit,
                                  minHeight: 16,
                                  backgroundColor: index == 0
                                      ? Colors.deepPurple.withOpacity(0.3)
                                      : Colors.blue.withOpacity(0.3),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      index == 0 ? Colors.deepPurple : Colors.blue),
                                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                                ),
                              ),
                            ],
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(height: 15);
                        },
                      ),
                      const SizedBox(height: 5),
                      const Divider(color: grey2),
                      const SizedBox(height: 5),
                      TextButton.icon(
                        icon: Icon(
                          Icons.add_circle,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        onPressed: null, // TODO
                        label: Text(
                          "Add category budget",
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .apply(color: Theme.of(context).colorScheme.secondary),
                        ),
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
                        onPressed: null, // TODO
                        label: Text(
                          "Create budget",
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .apply(color: Theme.of(context).colorScheme.secondary),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                      )
                    ],
                  );
          },
          error: (error, stack) => const Text(""),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
