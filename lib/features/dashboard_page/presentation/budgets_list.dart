import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/constants.dart';
import '../../../models/budget.dart';
import '../../../ui/widgets/budget_circular_indicator.dart';

class BudgetsList extends ConsumerWidget {
  const BudgetsList({
    super.key,
    required this.budgets,
  });

  final List<BudgetStats> budgets;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              "Your budgets",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (budgets.isEmpty) ...[
          Container(
            height: 90,
            width: width,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "No budget set",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Create a budget to track your spending",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                ),
              ],
            ),
          )
        ] else ...[
          SizedBox(
            height: 150,
            width: width,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: budgets.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                child: BudgetCircularIndicator(
                  title: budgets[index].name!,
                  amount: budgets[index].amountLimit - budgets[index].spent > 0
                      ? budgets[index].amountLimit - budgets[index].spent
                      : 0,
                  perc: budgets[index].spent / budgets[index].amountLimit > 1
                      ? 1
                      : budgets[index].spent / budgets[index].amountLimit,
                  color: categoryColorList[index % categoryColorList.length],
                ),
              ),
            ),
          ),
        ]
      ],
    );
  }
}
