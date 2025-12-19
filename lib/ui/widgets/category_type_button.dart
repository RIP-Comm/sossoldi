import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/style.dart';
import '../../model/category_transaction.dart';
import '../../providers/categories_provider.dart';
import '../../providers/transactions_provider.dart';
import '../device.dart';

class CategoryTypeButton extends ConsumerWidget {
  const CategoryTypeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryType = ref.watch(categoryTypeProvider);
    final width = (MediaQuery.of(context).size.width - 64) * 0.5;

    TextStyle textStyleFromType(CategoryTransactionType type) =>
        Theme.of(context).textTheme.bodyLarge!.copyWith(
          color: categoryType == type
              ? white
              : Theme.of(context).colorScheme.onPrimaryContainer,
        );

    void onTap(CategoryTransactionType type) {
      ref.invalidate(totalAmountProvider);
      ref.read(categoryTypeProvider.notifier).setType(type);
      ref.read(selectedCategoryProvider.notifier).setCategory(null);
    }

    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(Sizes.borderRadiusSmall),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: Alignment(
              (categoryType == CategoryTransactionType.income) ? -1 : 1,
              0,
            ),
            curve: Curves.decelerate,
            duration: const Duration(milliseconds: 180),
            child: Container(
              width: width,
              height: 28,
              decoration: BoxDecoration(
                color: blue5,
                borderRadius: BorderRadius.circular(Sizes.borderRadiusSmall),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(-1, 0),
            child: GestureDetector(
              onTap: () => onTap(CategoryTransactionType.income),
              child: Container(
                width: width,
                color: Colors.transparent,
                alignment: Alignment.center,
                child: Text(
                  "Income",
                  style: textStyleFromType(CategoryTransactionType.income),
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(1, 0),
            child: GestureDetector(
              onTap: () => onTap(CategoryTransactionType.expense),
              child: Container(
                width: width,
                color: Colors.transparent,
                alignment: Alignment.center,
                child: Text(
                  'Expenses',
                  style: textStyleFromType(CategoryTransactionType.expense),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
