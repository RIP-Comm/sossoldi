import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/functions.dart';
import '../../../providers/budgets_provider.dart';
import 'budgets_list.dart';

class BudgetsSection extends ConsumerWidget with Functions {
  const BudgetsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(monthlyBudgetsStatsProvider);
    return Column(
      children: [
        switch (budgetsAsync) {
          AsyncData(:final value) => BudgetsList(budgets: value),
          AsyncError(:final error) => Text('Error: $error'),
          _ => CircularProgressIndicator(),
        },
        const SizedBox(height: 50),
      ],
    );
  }
}
