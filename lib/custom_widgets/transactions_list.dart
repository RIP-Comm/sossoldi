import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../constants/constants.dart';
import '../constants/functions.dart';
import '../constants/style.dart';
import '../model/transaction.dart';
import '../pages/planning_page/manage_budget_page.dart';
import '../pages/transactions_page/widgets/transaction_empty_state_widget.dart';
import '../providers/currency_provider.dart';
import '../providers/transactions_provider.dart';
import '../utils/date_helper.dart';
import 'default_container.dart';
import 'rounded_icon.dart';

class TransactionsList extends StatefulWidget {
  const TransactionsList({
    super.key,
    required this.transactions,
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
    this.padding,
  });

  final List<Transaction> transactions;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  @override
  State<TransactionsList> createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> with Functions {
  Map<String, double> totals = {};
  List<Transaction> get transactions => widget.transactions;

  @override
  void initState() {
    updateTotal();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant TransactionsList oldWidget) {
    updateTotal();
    super.didUpdateWidget(oldWidget);
  }

  void updateTotal() {
    totals = {};
    for (final transaction in transactions) {
      final date = transaction.date.toYMD();
      final currentTotal = totals[date] ?? 0.0;

      final amount = switch (transaction.type) {
        TransactionType.expense => -transaction.amount.toDouble(),
        TransactionType.income => transaction.amount.toDouble(),
        TransactionType.transfer => 0.0, // Explicitly handle transfers
      };

      totals[date] = currentTotal + amount;
    }
  }

  @override
  Widget build(BuildContext context) {
    return transactions.isNotEmpty
        ? DefaultContainer(
            margin: widget.margin,
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: widget.padding,
              shrinkWrap: true,
              itemCount: totals.keys.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, monthIndex) {
                // Group transactions by month
                final dates = totals.keys.toList()
                  ..sort((a, b) => b.compareTo(a));
                final currentDate = dates[monthIndex];
                final dateTransactions = transactions
                    .where((t) => t.date.toYMD() == currentDate)
                    .toList();

                return Column(
                  children: [
                    TransactionTitle(
                      date: DateTime.parse(currentDate),
                      total: totals[currentDate] ?? 0,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: dateTransactions.length,
                          separatorBuilder: (_, __) => Divider(
                            indent: 12,
                            endIndent: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.4),
                          ),
                          itemBuilder: (context, index) => TransactionTile(
                            transaction: dateTransactions[index],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        : TransactionEmptyStateWidget();
  }
}

class TransactionTile extends ConsumerWidget with Functions {
  const TransactionTile({required this.transaction, super.key});

  final Transaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyState = ref.watch(currencyStateNotifier);
    return Material(
      child: ListTile(
        visualDensity: VisualDensity.compact,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        onTap: () async {
          ref
              .read(transactionsProvider.notifier)
              .transactionUpdateState(transaction)
              .whenComplete(() {
            if (context.mounted) {
              Navigator.of(context).pushNamed("/add-page", arguments: {
                'recurrencyEditingPermitted': !transaction.recurring
              });
            }
          });
        },
        leading: RoundedIcon(
          icon: transaction.categorySymbol != null
              ? iconList[transaction.categorySymbol]
              : Icons.swap_horiz_rounded,
          backgroundColor: transaction.categoryColor != null
              ? categoryColorListTheme[transaction.categoryColor!]
              : Theme.of(context).colorScheme.secondary,
          size: 25,
          padding: const EdgeInsets.all(8.0),
        ),
        title: Text(
          (transaction.note?.isEmpty ?? true)
              ? DateFormat("dd MMMM - HH:mm").format(transaction.date)
              : transaction.note!,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        subtitle: Text(
          transaction.categoryName ?? "Uncategorized",
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${transaction.type == TransactionType.expense ? "-" : ""}${numToCurrency(transaction.amount)}',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: typeToColor(
                          transaction.type,
                          brightness: Theme.of(context).brightness,
                        ),
                      ),
                ),
                Text(
                  currencyState.selectedCurrency.symbol,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: typeToColor(
                          transaction.type,
                          brightness: Theme.of(context).brightness,
                        ),
                      ),
                ),
              ],
            ),
            Text(
              transaction.type == TransactionType.transfer
                  ? "${transaction.bankAccountName ?? ''}→${transaction.bankAccountTransferName ?? ''}"
                  : transaction.bankAccountName ?? '',
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionTitle extends ConsumerWidget with Functions {
  final DateTime date;
  final num total;

  const TransactionTitle({
    super.key,
    required this.date,
    required this.total,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyState = ref.watch(currencyStateNotifier);
    final color = total < 0 ? red : (total > 0 ? green : blue3);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            dateToString(date),
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          const Spacer(),
          Text(
            numToCurrency(total),
            style:
                Theme.of(context).textTheme.bodyLarge!.copyWith(color: color),
          ),
          Text(
            currencyState.selectedCurrency.symbol,
            style:
                Theme.of(context).textTheme.labelMedium!.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
