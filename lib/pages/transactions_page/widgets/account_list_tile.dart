import "package:flutter/material.dart";

import '../../../constants/style.dart';

class AccountListTile extends StatelessWidget {
  const AccountListTile({
    super.key,
    required this.title,
    required this.amount,
    required this.nTransactions,
    required this.transactions,
    required this.percent,
    required this.color,
    required this.icon,
    required this.notifier,
    required this.index,
  });

  final String title;
  final double amount;
  final int nTransactions;
  final List<Map<String, dynamic>> transactions;
  final double percent;
  final Color color;
  final IconData icon;
  final ValueNotifier<int> notifier;
  final int index;

  /// Toogle the box to expand or collapse
  void _toogleExpand() {
    if (notifier.value == index) {
      notifier.value = -1;
    } else {
      notifier.value = index;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: notifier,
      builder: (context, value, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GestureDetector(
              onTap: _toogleExpand,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: color.withAlpha(90),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 16.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8.0),
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
                                "${amount.toStringAsFixed(2)} €",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                        color: (amount > 0) ? green : red),
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
                      (notifier.value == index)
                          ? Icons.expand_more
                          : Icons.chevron_right,
                    ),
                  ],
                ),
              ),
            ),
            ExpandedSection(
              expand: notifier.value == index,
              child: Container(
                color: white,
                height: 70.0 * nTransactions,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: (nTransactions > 0)
                      ? List.generate(
                          2 * nTransactions - 1,
                          (i) {
                            if (i % 2 == 0) {
                              return TransactionRow(
                                account: transactions[i ~/ 2]["account"],
                                amount: transactions[i ~/ 2]["amount"],
                                category: transactions[i ~/ 2]["category"],
                                title: transactions[i ~/ 2]["title"],
                              );
                            } else {
                              return const Divider(
                                height: 1,
                                thickness: 1,
                                indent: 15,
                                endIndent: 15,
                              );
                            }
                          },
                        )
                      : [],
                ),
              ),
            )
          ],
        );
      },
    );
  }
}

class TransactionRow extends StatelessWidget {
  const TransactionRow({
    super.key,
    required this.title,
    required this.category,
    required this.amount,
    required this.account,
  });

  final String title;
  final String category;
  final double amount;
  final String account;

  @override
  Widget build(BuildContext context) {
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
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      "${amount.toStringAsFixed(2)} €",
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
                      category.toUpperCase(),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text(
                      account.toUpperCase(),
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
