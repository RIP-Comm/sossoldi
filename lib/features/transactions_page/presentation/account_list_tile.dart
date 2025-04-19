import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/style.dart';
import '../../../ui/extensions.dart';
import '../../../ui/widgets/rounded_icon.dart';
import '../../../models/transaction.dart';
import '../../../providers/currency_provider.dart';
import '../../../ui/device.dart';
import 'accounts_tab.dart';

class AccountListTile extends ConsumerWidget {
  const AccountListTile({
    super.key,
    required this.title,
    required this.amount,
    required this.nTransactions,
    required this.transactions,
    required this.percent,
    required this.color,
    required this.icon,
    required this.index,
  });

  final String title;
  final double amount;
  final int nTransactions;
  final List<Transaction> transactions;
  final double percent;
  final Color color;
  final IconData icon;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAccountIndex = ref.watch(selectedAccountIndexProvider);
    final currencyState = ref.watch(currencyStateNotifier);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            if (selectedAccountIndex == index) {
              ref.invalidate(selectedAccountIndexProvider);
            } else {
              ref.read(selectedAccountIndexProvider.notifier).state = index;
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Sizes.borderRadiusSmall),
              color: color.withAlpha(90),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: Sizes.sm,
              vertical: Sizes.lg,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                RoundedIcon(
                  icon: icon,
                  backgroundColor: color,
                  padding: const EdgeInsets.all(Sizes.sm),
                ),
                const SizedBox(width: Sizes.sm),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
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
                const SizedBox(width: Sizes.sm),
                Icon(
                  (selectedAccountIndex == index)
                      ? Icons.expand_more
                      : Icons.chevron_right,
                ),
              ],
            ),
          ),
        ),
        ExpandedSection(
          expand: selectedAccountIndex == index,
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

class TransactionRow extends ConsumerWidget {
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
        horizontal: Sizes.sm,
        vertical: Sizes.lg,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(width: Sizes.xl * 2),
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
                      "${transaction.amount.toCurrency()} ${currencyState.selectedCurrency.symbol}",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: (transaction.amount > 0) ? green : red),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      transaction.categoryName?.toUpperCase() ??
                          "Uncategorized",
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
          const SizedBox(width: Sizes.sm),
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
