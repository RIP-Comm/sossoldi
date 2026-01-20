import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../constants/constants.dart';
import '../../../model/currency.dart';
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
    this.enableSubcategories = false,
  });

  final String name;
  final IconData? icon;
  final Color color;
  final double amount;
  final List<Transaction> transactions;
  final double percent;
  final int index;
  final bool enableSubcategories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedListIndexProvider);
    final currency = ref.watch(currencyStateProvider);
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
                                "${amount.toCurrency()} ${currency.symbol}",
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
              child: enableSubcategories
                  ? _buildGroupedTransactions(context, transactions, currency)
                  : TransactionsList(
                      currency: currency,
                      transactions: transactions,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedTransactions(
    BuildContext context,
    List<Transaction> txs,
    Currency currency,
  ) {
    final Map<int?, List<Transaction>> grouped = {};
    final List<Widget> children = [];

    for (final t in txs) {
      grouped.putIfAbsent(t.idCategory, () => []).add(t);
    }

    if (grouped.length == 1) {
      return TransactionsList(currency: currency, transactions: txs);
    }

    grouped.forEach((categoryId, list) {
      double sum = 0;
      for (final t in list) {
        sum += t.type == TransactionType.income
            ? t.amount.toDouble()
            : -t.amount.toDouble();
      }

      final headerName = list.first.categoryName ?? 'Uncategorized';
      final percent = list.length * 100 / txs.length;

      children.add(
        Container(
          padding: const EdgeInsets.fromLTRB(
            Sizes.sm,
            Sizes.lg,
            Sizes.lg,
            Sizes.lg,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            border: Border(left: BorderSide(width: 3, color: color)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.only(left: Sizes.sm, right: Sizes.md),
                child: RoundedIcon(
                  icon: list.first.categorySymbol != null
                      ? iconList[list.first.categorySymbol!]
                      : Icons.category,
                  backgroundColor: categoryId != null
                      ? categoryColorList[list.first.categoryColor ?? 0]
                      : Colors.grey,
                  padding: const EdgeInsets.all(Sizes.xs),
                  size: Sizes.lg,
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            headerName,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          "${sum.toCurrency()} ${currency.symbol}",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(color: sum.toColor()),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${list.length} transactions",
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
        ),
      );

      children.add(TransactionsList(transactions: list, currency: currency));
    });

    return Column(children: children);
  }
}

class TransactionsList extends StatelessWidget {
  const TransactionsList({
    super.key,
    required this.currency,
    required this.transactions,
  });

  final Currency currency;
  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
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
          padding: const EdgeInsets.all(Sizes.lg),
          child: Row(
            children: [
              const SizedBox(width: Sizes.lg * 2),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            (transaction.note?.isEmpty ?? true)
                                ? DateFormat(
                                    "dd MMMM - HH:mm",
                                  ).format(transaction.date)
                                : transaction.note!,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          "${amount.toCurrency()} ${currency.symbol}",
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: amount.toColor()),
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
            ],
          ),
        );
      },
    );
  }
}
