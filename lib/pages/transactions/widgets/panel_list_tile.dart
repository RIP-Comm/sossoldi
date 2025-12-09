import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../model/transaction.dart';
import '../../../providers/transactions_provider.dart';
import '../../../providers/currency_provider.dart';
import '../../../ui/device.dart';
import '../../../ui/extensions.dart';
import '../../../ui/widgets/rounded_icon.dart';

class PanelListTile extends ConsumerWidget {
  const PanelListTile({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
    required this.amount,
    required this.transactions,
    required this.percent,
    required this.index,
  });

  final String name;
  final IconData? icon;
  final Color color;
  final double amount;
  final List<Transaction> transactions;
  final double percent;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedListIndexProvider);
    final currencyState = ref.watch(currencyStateProvider);
    return ClipRRect(
      borderRadius: BorderRadius.circular(Sizes.borderRadius),
      child: ExpansionPanelList(
        elevation: 0,
        expandedHeaderPadding: EdgeInsets.zero,
        expansionCallback: (_, isExpanded) {
          if (isExpanded) {
            ref.read(selectedListIndexProvider.notifier).setIndex(index);
          } else {
            ref.invalidate(selectedListIndexProvider);
          }
        },
        children: [
          ExpansionPanel(
            isExpanded: selectedIndex == index,
            canTapOnHeader: true,
            backgroundColor: color.withAlpha(90),
            headerBuilder: (context, isExpanded) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Sizes.sm,
                  vertical: Sizes.lg,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  spacing: Sizes.sm,
                  children: [
                    RoundedIcon(
                      icon: icon,
                      backgroundColor: color,
                      padding: const EdgeInsets.all(Sizes.sm),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                "${amount.toCurrency()} ${currencyState.symbol}",
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(color: amount.toColor()),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${transactions.length} transactions",
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
                  ],
                ),
              );
            },
            body: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                separatorBuilder: (context, index) =>
                    const Divider(indent: 15, endIndent: 15),
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  final amount = transaction.type == TransactionType.income
                      ? transaction.amount
                      : -transaction.amount;
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      (transaction.note?.isEmpty ?? true)
                                          ? DateFormat(
                                              "dd MMMM - HH:mm",
                                            ).format(transaction.date)
                                          : transaction.note!,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ),
                                  Text(
                                    "${amount.toCurrency()} ${currencyState.symbol}",
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(color: amount.toColor()),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    transaction.categoryName?.toUpperCase() ??
                                        "Uncategorized",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelLarge,
                                  ),
                                  Text(
                                    transaction.bankAccountName
                                            ?.toUpperCase() ??
                                        "",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelLarge,
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
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
