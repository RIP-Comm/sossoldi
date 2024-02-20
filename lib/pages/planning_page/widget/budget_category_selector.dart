import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sossoldi/model/budget.dart';
import 'package:sossoldi/model/category_transaction.dart';

import '../../../constants/constants.dart';

class BudgetCategorySelector extends ConsumerStatefulWidget {
  final List<CategoryTransaction> categories;
  final Budget budget;
  final CategoryTransaction initSelectedCategory;
  final Function(Budget) onBudgetChanged;

  BudgetCategorySelector(
      {super.key,
      required this.categories,
      required this.budget,
      required this.initSelectedCategory,
      required this.onBudgetChanged});

  @override
  ConsumerState<BudgetCategorySelector> createState() =>
      _BudgetCategorySelector();
}

class _BudgetCategorySelector extends ConsumerState<BudgetCategorySelector> {
  late CategoryTransaction selectedCategory = widget.initSelectedCategory;
  final TextEditingController _controller = TextEditingController();

  void _modifyBudget() {
    Budget updatedBudget = Budget(
        idCategory: selectedCategory.id!,
        name: selectedCategory.name,
        active: true,
        amountLimit:
            _controller.text.isNotEmpty ? double.parse(_controller.text) : 0);

    widget.onBudgetChanged(updatedBudget);
  }

  @override
  void initState() {
    _controller.text = widget.budget.amountLimit.toInt().toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8),
        color: Colors.grey[200],
        child: Row(children: [
          Expanded(
              child: Container(
                  height: 55,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(width: 1, color: Colors.grey)),
                  child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8)),
                      child: DropdownButton<CategoryTransaction>(
                        value: selectedCategory,
                        underline: const SizedBox(),
                        isExpanded: true,
                        items: widget.categories
                            .map((CategoryTransaction category) {
                          IconData? icon = iconList[category.symbol];
                          return DropdownMenuItem<CategoryTransaction>(
                              value: category,
                              child: Row(
                                children: [Icon(icon), const SizedBox(width: 15,), Text(category.name)],
                              ));
                        }).toList(),
                        onChanged: (CategoryTransaction? newValue) {
                          setState(() {
                            selectedCategory = newValue!;
                            _modifyBudget();
                          });
                        },
                      )))),
          const SizedBox(width: 20),
          Container(
              width: 100,
              height: 55,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(width: 1, color: Colors.grey)),
              child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                      controller: _controller,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onEditingComplete: () {
                        setState(() {
                          _modifyBudget();
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: "-",
                        border: InputBorder.none,
                        prefixText: ' ', // set to center the amount
                        suffixText: '€',
                      ))))
        ]));
  }
}
