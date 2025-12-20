import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/constants.dart';
import '../../../model/budget.dart';
import '../../../model/category_transaction.dart';
import '../../../providers/currency_provider.dart';
import '../../../ui/extensions.dart';
import '../../../ui/formatters/decimal_text_input_formatter.dart';
import '../../../ui/device.dart';
import '../../../ui/widgets/rounded_icon.dart';

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
      amountLimit: _controller.text.isNotEmpty ? _controller.text.toNum() : 0,
    );
    widget.onBudgetChanged(updatedBudget);
  }

  @override
  void initState() {
    _controller.text = widget.budget.amountLimit.toCurrency();
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
        spacing: Sizes.lg,
        children: [
          Expanded(
            child: Container(
              height: 55,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Sizes.borderRadius),
                border: Border.all(width: 1, color: Colors.grey),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: DropdownButton<CategoryTransaction>(
                value: selectedCategory,
                underline: const SizedBox(),
                borderRadius: BorderRadius.circular(Sizes.borderRadius),
                padding: const EdgeInsets.symmetric(
                  horizontal: Sizes.sm,
                  vertical: Sizes.xs,
                ),
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
                      spacing: Sizes.md,
                      children: [
                        RoundedIcon(
                          icon: icon,
                          padding: const EdgeInsets.all(Sizes.sm),
                          backgroundColor: categoryColorList[category.color]
                              .withValues(
                                alpha: isCurrent || !isUsed ? 1 : 0.4,
                              ),
                        ),
                        Text(
                          category.name,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary
                                .withValues(
                                  alpha: isCurrent || !isUsed ? 1 : 0.4,
                                ),
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
          Container(
            width: 100,
            height: 55,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(Sizes.borderRadius),
              border: Border.all(width: 1, color: Colors.grey),
            ),
            padding: const EdgeInsets.symmetric(horizontal: Sizes.sm),
            child: Center(
              child: TextField(
                controller: _controller,
                textAlign: TextAlign.center,
                // expands: true,
                inputFormatters: [DecimalTextInputFormatter(decimalDigits: 2)],
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) {
                  setState(() => _modifyBudget());
                },
                decoration: InputDecoration(
                  hintText: "-",
                  suffix: Text(
                    currencyState.symbol,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
