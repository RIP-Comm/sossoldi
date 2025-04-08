import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/constants.dart';
import '../../../constants/functions.dart';
import '../../../constants/style.dart';
import '../../../custom_widgets/rounded_icon.dart';
import '../../../features/transactions_page/data/selected_category_index_provider.dart';
import '../../../model/category_transaction.dart';
import '../../../model/transaction.dart';
import '../../../providers/currency_provider.dart';

class CategoryListTile extends ConsumerWidget {
  const CategoryListTile({
    super.key,
    required this.category,
    required this.amount,
    required this.transactions,
    required this.percent,
    required this.index,
  });

  final CategoryTransaction category;
  final double amount;
  final List<Transaction> transactions;
  final double percent;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategoryIndex = ref.watch(selectedCategoryIndexProvider);
    final currencyState = ref.watch(currencyStateNotifier);
    final nTransactions = transactions.length;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            if (selectedCategoryIndex == index) {
              ref.invalidate(selectedCategoryIndexProvider);
            } else {
              ref.read(selectedCategoryIndexProvider.notifier).state = index;
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: categoryColorList[category.color].withAlpha(90),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 16.0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                RoundedIcon(
                  icon: iconList[category.symbol],
                  backgroundColor: categoryColorList[category.color],
                  padding: const EdgeInsets.all(8.0),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            category.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            "${amount.toStringAsFixed(2)} ${currencyState.selectedCurrency.symbol}",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: (amount > 0) ? green : red),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "$nTransactions transactions",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          Text(
                            "${percent.toStringAsFixed(2)}%",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                Icon(
                  (selectedCategoryIndex == index)
                      ? Icons.expand_more
                      : Icons.chevron_right,
                ),
              ],
            ),
          ),
        ),
        ExpandedSection(
          expand: selectedCategoryIndex == index,
          child: Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            height: 70.0 * nTransactions,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: nTransactions,
              separatorBuilder: (context, index) => const Divider(
                indent: 15,
                endIndent: 15,
              ),
              itemBuilder: (context, index) {
                return TransactionRow(
                  transaction: transactions[index],
                );
              },
            ),
          ),
        )
      ],
    );
  }
}

class TransactionRow extends ConsumerWidget with Functions {
  const TransactionRow({
    super.key,
    required this.transaction,
  });

  final Transaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyState = ref.watch(currencyStateNotifier);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 16.0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(width: 48.0),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      transaction.note ?? "",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      "${numToCurrency(transaction.amount)} ${currencyState.selectedCurrency.symbol}",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: (transaction.amount > 0) ? green : red),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      transaction.categoryName?.toUpperCase() ?? "",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text(
                      transaction.bankAccountName?.toUpperCase() ?? "",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
        ],
      ),
    );
  }
}

class ExpandedSection extends StatefulWidget {
  const ExpandedSection({
    super.key,
    this.expand = false,
    required this.child,
  });

  final Widget child;
  final bool expand;

  @override
  State<ExpandedSection> createState() => _ExpandedSectionState();
}

class _ExpandedSectionState extends State<ExpandedSection>
    with SingleTickerProviderStateMixin {
  late AnimationController expandController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    prepareAnimations();
  }

  ///Setting up the animation
  void prepareAnimations() {
    expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    Animation<double> curve = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
    animation = Tween(begin: 0.0, end: 1.0).animate(curve)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void didUpdateWidget(ExpandedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expand) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      axisAlignment: 1.0,
      sizeFactor: animation,
      child: widget.child,
    );
  }
}
