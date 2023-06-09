import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sossoldi/constants/functions.dart';
import 'package:sossoldi/providers/budgets_provider.dart';

import '../../../model/category_transaction.dart';

class AddBudget extends ConsumerStatefulWidget {
  final CategoryTransaction category;

  const AddBudget(this.category, {Key? key}) : super(key: key);

  @override
  ConsumerState<AddBudget> createState() => _AddBudgetState();
}

class _AddBudgetState extends ConsumerState<AddBudget> with Functions {
  final TextEditingController amountController = TextEditingController();

  @override
  void dispose() {
    ref.invalidate(selectedBudgetProvider);
    ref.invalidate(budgetCategoryIdProvider);
    ref.invalidate(budgetNameProvider);
    ref.invalidate(budgetAmountLimitProvider);
    ref.invalidate(budgetAmountLimitProvider);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amountLimit = ref.read(budgetAmountLimitProvider);
    setState(() {
      amountController.text = (amountLimit).toString();
    });

    return AlertDialog(
      title: Text('Add budget for ${widget.category.name}'),
      content: TextField(
        controller: amountController,
        keyboardType: TextInputType.number,
        onChanged: (value) => ref.read(budgetAmountLimitProvider.notifier).state = value as num,
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            ref.read(budgetActiveProvider.notifier).state = true;
            ref.read(budgetNameProvider.notifier).state = widget.category.name;
            ref.read(budgetCategoryIdProvider.notifier).state = widget.category.id!;
            ref.read(budgetsProvider.notifier).addBudget().whenComplete(() => Navigator.pop(context));
            print('ok');
          },
          child: const Text('Confirm'),
        ),
        ElevatedButton(
          onPressed: () {
            ref.read(budgetActiveProvider.notifier).state = false;
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
