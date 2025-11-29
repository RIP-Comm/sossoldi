import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../constants/constants.dart';
import '../../constants/style.dart';
import '../../model/transaction.dart';
import '../../providers/currency_provider.dart';
import '../../providers/transactions_provider.dart';
import '../device.dart';
import '../extensions.dart';
import 'blur_widget.dart';
import 'default_container.dart';
import 'rounded_icon.dart';

class TransactionsList extends StatefulWidget {
  const TransactionsList({
    super.key,
    required this.transactions,
    this.margin = const EdgeInsets.symmetric(horizontal: Sizes.lg),
    this.padding,
    this.ignoreBlur = true,
  });

  final List<Transaction> transactions;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final bool ignoreBlur;

  @override
  State<TransactionsList> createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {
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
      final date = transaction.date.formatYMD();
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
              separatorBuilder: (_, _) => const SizedBox(height: Sizes.lg),
              itemBuilder: (context, monthIndex) {
                // Group transactions by month
                final dates = totals.keys.toList()
                  ..sort((a, b) => b.compareTo(a));
                final currentDate = dates[monthIndex];
                final dateTransactions = transactions
                    .where((t) => t.date.formatYMD() == currentDate)
                    .toList();

                return Column(
                  children: [
                    TransactionTitle(
                      ignoreBlur: widget.ignoreBlur,
                      date: DateTime.parse(currentDate),
                      total: totals[currentDate] ?? 0,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(Sizes.borderRadius),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(Sizes.borderRadius),
                        child: ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: dateTransactions.length,
                          separatorBuilder: (_, _) => Divider(
                            indent: 12,
                            endIndent: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.4),
                          ),
                          itemBuilder: (context, index) => TransactionTile(
                            ignoreBlur: widget.ignoreBlur,
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
        : const Center(child: Text("No transactions available"));
  }
}

class TransactionTile extends ConsumerWidget {
  const TransactionTile({
    required this.transaction,
    required this.ignoreBlur,
    super.key,
  });

  final bool ignoreBlur;

  final Transaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyState = ref.watch(currencyStateNotifier);
    return Material(
      child: ListTile(
        visualDensity: VisualDensity.compact,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Sizes.md,
          vertical: Sizes.xs,
        ),
        onTap: () async {
          ref
              .read(transactionsProvider.notifier)
              .transactionUpdateState(transaction)
              .whenComplete(() {
                if (context.mounted) {
                  Navigator.of(context).pushNamed(
                    "/add-page",
                    arguments: {
                      'recurrencyEditingPermitted': !transaction.recurring,
                    },
                  );
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
          padding: const EdgeInsets.all(Sizes.sm),
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
          transaction.type == TransactionType.transfer
              ? ""
              : transaction.categoryName ?? "Uncategorized",
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            BlurWidget(
              ignore: ignoreBlur,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${transaction.type == TransactionType.expense ? "-" : ""}${transaction.amount.toCurrency()}',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: transaction.type.toColor(
                        brightness: Theme.of(context).brightness,
                      ),
                    ),
                  ),
                  Text(
                    currencyState.selectedCurrency.symbol,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: transaction.type.toColor(
                        brightness: Theme.of(context).brightness,
                      ),
                    ),
                  ),
                ],
              ),
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

class TransactionTitle extends ConsumerWidget {
  final DateTime date;
  final num total;
  final bool ignoreBlur;

  const TransactionTitle({
    super.key,
    required this.date,
    required this.total,
    required this.ignoreBlur,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyState = ref.watch(currencyStateNotifier);
    final color = total < 0 ? red : (total > 0 ? green : blue3);
    return Padding(
      padding: const EdgeInsets.only(bottom: Sizes.md),
      child: Row(
        children: [
          Text(
            date.formatEDMY(),
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Spacer(),
          BlurWidget(
            ignore: ignoreBlur,
            child: Text(
              total.toCurrency(),
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.copyWith(color: color),
            ),
          ),
          BlurWidget(
            ignore: ignoreBlur,
            child: Text(
              currencyState.selectedCurrency.symbol,
              style: Theme.of(
                context,
              ).textTheme.labelMedium!.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
