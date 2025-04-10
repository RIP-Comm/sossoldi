import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/style.dart';
import '../../../model/transaction.dart';
import '../data/selected_category_index_provider.dart';
import '../data/selected_transaction_type_provider.dart';
import 'accounts_tab.dart';

class TransactionTypeButton extends ConsumerWidget {
  const TransactionTypeButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionType = ref.watch(selectedTransactionTypeProvider);
    // Reset index for categories and accounts when transactions type changes
    ref.listen(selectedTransactionTypeProvider, (previous, next) {
      ref.invalidate(selectedAccountIndexProvider);
      ref.invalidate(selectedCategoryIndexProvider);
    });
    final width = (MediaQuery.of(context).size.width - 64) * 0.5;
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.all(
          Radius.circular(5.0),
        ),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: Alignment(
              (transactionType == TransactionType.income) ? -1 : 1,
              0,
            ),
            curve: Curves.decelerate,
            duration: const Duration(milliseconds: 180),
            child: Container(
              width: width,
              height: 28,
              decoration: const BoxDecoration(
                color: blue5,
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              ref.read(selectedTransactionTypeProvider.notifier).state =
                  TransactionType.income;
            },
            child: Align(
              alignment: const Alignment(-1, 0),
              child: Container(
                width: width,
                color: Colors.transparent,
                alignment: Alignment.center,
                child: Text(
                  "Income",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: (transactionType == TransactionType.income)
                          ? white
                          : Theme.of(context).colorScheme.onPrimaryContainer),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              ref.read(selectedTransactionTypeProvider.notifier).state =
                  TransactionType.expense;
            },
            child: Align(
              alignment: const Alignment(1, 0),
              child: Container(
                width: width,
                color: Colors.transparent,
                alignment: Alignment.center,
                child: Text(
                  'Expenses',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: (transactionType == TransactionType.expense)
                          ? white
                          : Theme.of(context).colorScheme.onPrimaryContainer),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
