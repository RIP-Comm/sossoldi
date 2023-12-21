import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/constants.dart';
import '../constants/functions.dart';
import '../constants/style.dart';
import '../model/bank_account.dart';
import '../model/category_transaction.dart';
import '../model/transaction.dart';
import '../providers/accounts_provider.dart';
import '../providers/categories_provider.dart';
import '../providers/transactions_provider.dart';
import '../utils/date_helper.dart';

class TransactionsList extends ConsumerStatefulWidget {
  final List<Transaction> transactions;

  const TransactionsList({
    super.key,
    required this.transactions,
  });

  @override
  ConsumerState<TransactionsList> createState() => _TransactionsListState();
}

class _TransactionsListState extends ConsumerState<TransactionsList> with Functions {
  Map<String, double> totals = {};
  List<Transaction> get transactions => widget.transactions;

  @override
  void initState() {
    for (var transaction in transactions) {
      String date = transaction.date.toYMD();
      if (totals.containsKey(date)) {
        if (transaction.type == TransactionType.expense) {
          totals[date] = totals[date]! - transaction.amount.toDouble();
        } else if (transaction.type == TransactionType.income) {
          totals[date] = totals[date]! + transaction.amount.toDouble();
        }
      } else {
        if (transaction.type == TransactionType.expense) {
          totals.putIfAbsent(date, () => -transaction.amount.toDouble());
        } else if (transaction.type == TransactionType.income) {
          totals.putIfAbsent(date, () => transaction.amount.toDouble());
        }
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final accountsList = ref.watch(accountsProvider);
    final categoriesList = ref.watch(categoriesProvider);

    return transactions.isNotEmpty
        ? SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [defaultShadow],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: transactions.map((transaction) {
                  int index = transactions.indexOf(transaction);
                  bool first =
                      index == 0 || !transaction.date.isSameDate(transactions[index - 1].date);
                  bool last = index == transactions.length - 1 ||
                      !transaction.date.isSameDate(transactions[index + 1].date);

                  return Column(
                    children: [
                      if (first)
                        TransactionTitle(
                          date: transaction.date,
                          total: totals[transaction.date.toYMD()] ?? 0,
                          first: index == 0,
                        ),
                      TransactionRow(transaction, accountsList, categoriesList, first: first, last: last),
                    ],
                  );
                }).toList(),
              ),
            ),
        )
        : Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            width: double.infinity,
            child: const Center(
              child: Text("No transactions available"),
            ),
          );
  }
}

class TransactionTitle extends StatelessWidget with Functions {
  final DateTime date;
  final num total;
  final bool first;

  const TransactionTitle({
    super.key,
    required this.date,
    this.total = 0,
    this.first = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = total < 0 ? red : (total > 0 ? green : blue3);
    return Padding(
      padding: EdgeInsets.only(top: first ? 0 : 24),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                dateToString(date),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: Theme.of(context).colorScheme.primary),
              ),
              const Spacer(),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: numToCurrency(total),
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: color),
                    ),
                    TextSpan(
                      text: "€",
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium!
                          .copyWith(color: color)
                          .apply(fontFeatures: [const FontFeature.subscripts()]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class TransactionRow extends ConsumerWidget with Functions {
  const TransactionRow(this.transaction, this.accountsList, this.categoriesList, {this.first = false, this.last = false, super.key});

  final Transaction transaction;
  final AsyncValue<List<BankAccount>> accountsList;
  final AsyncValue<List<CategoryTransaction>> categoriesList;
  final bool first;
  final bool last;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Iterable<CategoryTransaction>? categories =
        transaction.type != TransactionType.transfer && categoriesList.value != null
            ? categoriesList.value!.where((element) => element.id == transaction.idCategory)
            : [];
    CategoryTransaction? category = categories.isNotEmpty ? categories.first : null;
    BankAccount account =
        accountsList.value!.firstWhere((element) => element.id == transaction.idBankAccount);
    BankAccount? accountTransfer = transaction.type == TransactionType.transfer
        ? accountsList.value!
            .firstWhere((element) => element.id == transaction.idBankAccountTransfer)
        : null;
    return Column(
      children: [
        Material(
          borderRadius: BorderRadius.vertical(
            top: first ? const Radius.circular(8) : Radius.zero,
            bottom: last ? const Radius.circular(8) : Radius.zero,
          ),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: InkWell(
            onTap: () {
              ref
                  .read(transactionsProvider.notifier)
                  .transactionUpdateState(transaction)
                  .whenComplete(() => Navigator.of(context).pushNamed("/add-page"));
            },
            borderRadius: BorderRadius.vertical(
              top: first ? const Radius.circular(8) : Radius.zero,
              bottom: last ? const Radius.circular(8) : Radius.zero,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: category?.color != null
                          ? categoryColorListTheme[category!.color]
                          : Theme.of(context).colorScheme.secondary,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        category?.symbol != null
                            ? iconList[category!.symbol]
                            : Icons.swap_horiz_rounded,
                        size: 25.0,
                        color: white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 11),
                        Row(
                          children: [
                            if (transaction.note != null)
                              Text(
                                transaction.note!,
                                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            const Spacer(),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        '${transaction.type == TransactionType.expense ? "-" : ""}${numToCurrency(transaction.amount)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge!
                                        .copyWith(color: typeToColor(transaction.type)),
                                  ),
                                  TextSpan(
                                    text: "€",
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall!
                                        .copyWith(color: typeToColor(transaction.type))
                                        .apply(
                                      fontFeatures: [const FontFeature.subscripts()],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (category != null)
                              Text(
                                category.name,
                                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            const Spacer(),
                            Text(
                              transaction.type == TransactionType.transfer
                                  ? "${account.name}→${accountTransfer!.name}"
                                  : account.name,
                              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 11),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!last)
          Container(
            color: Theme.of(context).colorScheme.background,
            child: Divider(
              height: 1,
              indent: 12,
              endIndent: 12,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
            ),
          ),
      ],
    );
  }
}
