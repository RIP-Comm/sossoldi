import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/functions.dart';
import '../../../constants/style.dart';
import '../../../model/budget.dart';
import '../../../model/category_transaction.dart';
import '../../../providers/budgets_provider.dart';

class AddBudget extends ConsumerStatefulWidget {
  final CategoryTransaction category;

  const AddBudget(this.category, {super.key});

  @override
  ConsumerState<AddBudget> createState() => _AddBudgetState();
}

class _AddBudgetState extends ConsumerState<AddBudget> with Functions {
  final TextEditingController amountController = TextEditingController();

  List<Budget>? budgetsList = [];
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize the text controller with the current budget amount
    budgetsList = ref.watch(budgetsProvider).value;
    const Budget defaultBudget = Budget(idCategory: 99999, name: '', amountLimit: 9999, active: false);

    final Budget? budget = budgetsList?.firstWhere((element) => element.idCategory == widget.category.id, orElse: () => defaultBudget);

    if (budget != null) {
      amountController.text = budget.amountLimit.toString();
    }
    if(budget == defaultBudget){
      amountController.text = "";
    }

  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Add budget for ${widget.category.name}',
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
      content: TextField(
        controller: amountController,
        keyboardType: TextInputType.number,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('CANCEL', style: Theme.of(context).textTheme.bodyMedium),
        ),
        ElevatedButton(
          onPressed: () async {
            await ref.watch(budgetsProvider.notifier).addBudget(
                Budget(
                  name: widget.category.name,
                  createdAt: DateTime.now(),
                  idCategory: widget.category.id!,
                  amountLimit: num.tryParse(amountController.text) ?? 0,
                  active: true,
                )).whenComplete(() => Navigator.pop(context));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: blue5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'CONFIRM',
            style: Theme.of(context).textTheme.bodyMedium?.apply(color: white),
          ),
        ),
      ],
    );
  }
}
