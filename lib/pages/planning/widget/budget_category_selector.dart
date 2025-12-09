import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/constants.dart';
import '../../../model/budget.dart';
import '../../../model/category_transaction.dart';
import '../../../providers/currency_provider.dart';
import '../../../ui/formatters/decimal_text_input_formatter.dart';
import '../../../ui/device.dart';

class BudgetCategorySelector extends ConsumerStatefulWidget {
  final List<CategoryTransaction> categories;
  final Budget budget;
  final Set<int> usedCategoryIds;
  final CategoryTransaction initSelectedCategory;
  final Function(Budget) onBudgetChanged;

  const BudgetCategorySelector({
    super.key,
    required this.categories,
    required this.budget,
    required this.initSelectedCategory,
    required this.onBudgetChanged,
    required this.usedCategoryIds,
  });

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
      amountLimit: _controller.text.isNotEmpty
          ? double.parse(_controller.text)
          : 0,
    );
    widget.onBudgetChanged(updatedBudget);
  }

  @override
  void initState() {
    _controller.text = widget.budget.amountLimit.toInt().toString();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyState = ref.watch(currencyStateProvider);
    return Container(
      padding: const EdgeInsets.all(Sizes.lg),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 55,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Sizes.borderRadius),
                border: Border.all(width: 1, color: Colors.grey),
              ),
              child: Container(
                padding: const EdgeInsets.all(Sizes.xxs),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(Sizes.borderRadius),
                ),
                child: DropdownButton<CategoryTransaction>(
                  value: selectedCategory,
                  underline: const SizedBox(),
                  isExpanded: true,
                  items: widget.categories.map((CategoryTransaction category) {
                    final bool isUsed = widget.usedCategoryIds.contains(
                      category.id,
                    );
                    final bool isCurrent = category.id == selectedCategory.id;
                    IconData? icon = iconList[category.symbol];
                    return DropdownMenuItem<CategoryTransaction>(
                      value: category,
                      enabled: isCurrent || !isUsed,
                      child: Row(
                        children: [
                          Icon(
                            icon,
                            color: isCurrent || !isUsed ? null : Colors.grey,
                          ),
                          const SizedBox(width: Sizes.lg),
                          Text(
                            category.name,
                            style: TextStyle(
                              color: isCurrent || !isUsed ? null : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (CategoryTransaction? newValue) {
                    if (newValue == null) return;
                    setState(() {
                      selectedCategory = newValue;
                      _modifyBudget();
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: Sizes.xl),
          Container(
            width: 100,
            height: 55,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(Sizes.borderRadius),
              border: Border.all(width: 1, color: Colors.grey),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sizes.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        DecimalTextInputFormatter(decimalDigits: 2),
                      ],
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) {
                        setState(() {
                          _modifyBudget();
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: "-",
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  Text(currencyState.symbol),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
