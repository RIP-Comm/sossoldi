import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/constants.dart';

import '../../../ui/widgets/budget_circular_indicator.dart';
import '../../../model/budget.dart';
import '../../../providers/budgets_provider.dart';
import '../../../ui/device.dart';

class BudgetsSection extends ConsumerWidget {
  const BudgetsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(monthlyBudgetsStatsProvider.future);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FutureBuilder<List<BudgetStats>>(
              future: budgets,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final budgets = snapshot.data;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: Sizes.lg),
                      if (budgets == null || budgets.isEmpty)
                        Container(
                          height: 90,
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "No budget set",
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: Sizes.sm),
                              Text(
                                "Create a budget to track your spending",
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        )
                      else
                        SizedBox(
                          height: 150,
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: budgets.length,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Sizes.md,
                              ),
                              child: BudgetCircularIndicator(
                                title: budgets[index].name!,
                                amount:
                                    budgets[index].amountLimit -
                                            budgets[index].spent >
                                        0
                                    ? budgets[index].amountLimit -
                                          budgets[index].spent
                                    : 0,
                                perc:
                                    budgets[index].spent /
                                            budgets[index].amountLimit >
                                        1
                                    ? 1
                                    : budgets[index].spent /
                                          budgets[index].amountLimit,
                                color:
                                    categoryColorList[index %
                                        categoryColorList.length],
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 50),
      ],
    );
  }
}
