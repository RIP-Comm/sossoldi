import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/constants.dart';

import '../../constants/functions.dart';
import '../../custom_widgets/budget_circular_indicator.dart';
import '../../model/budget.dart';
import '../../providers/budgets_provider.dart';

class BudgetsSection extends ConsumerStatefulWidget {
  const BudgetsSection({super.key});

  @override
  ConsumerState<BudgetsSection> createState() => _BudgetsSectionState();
}

class _BudgetsSectionState extends ConsumerState<BudgetsSection> with Functions {
  @override
  Widget build(BuildContext context) {
    final budgets =ref.watch(budgetsProvider.notifier).getMonthlyBudgetsStats();

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
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            "Your budgets",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 150,
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: budgets!.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 13),
                            child: BudgetCircularIndicator(
                              title: budgets[index].name!,
                              amount: budgets[index].amountLimit - budgets[index].spent > 0 ? budgets[index].amountLimit - budgets[index].spent : 0,
                              perc: budgets[index].spent / budgets[index].amountLimit > 1 ? 1 : budgets[index].spent / budgets[index].amountLimit,
                              color: categoryColorList[index % categoryColorList.length],
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
        const SizedBox(height: 50)
      ],
    );
  }
}
