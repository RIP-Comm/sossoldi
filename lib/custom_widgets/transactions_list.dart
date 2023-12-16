import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/constants.dart';
import '../providers/transactions_provider.dart';
import '../constants/functions.dart';
import '../model/bank_account.dart';
import '../model/category_transaction.dart';
import '../model/transaction.dart';
import '../providers/accounts_provider.dart';
import '../providers/categories_provider.dart';
import '../constants/style.dart';

class TransactionsList extends StatefulWidget {
  final List<Transaction> transactions;

  const TransactionsList({
    super.key,
    required this.transactions,
  });

  @override
  State<TransactionsList> createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> with Functions {
  List<Widget> list = [];

  @override
  void initState() {
    num sum = 0;
    DateTime? date;
    List<Transaction> transactionList = [];
    for (var transaction in widget.transactions) {
      if (transaction != widget.transactions.first &&
          dateToString(transaction.date) != dateToString(date!)) {
        final title = TransactionTitle(date: date, sum: sum, first: list.isEmpty ? true : false);
        final transactionRow = TransactionRow(transactions: transactionList);
        list = [...list, title, transactionRow];
        transactionList = [];
        sum = 0;
      }
      date = transaction.date;
      transactionList = [...transactionList, transaction];
      if (transaction.type == Type.expense) {
        sum -= transaction.amount;
      } else if (transaction.type == Type.income) {
        sum += transaction.amount;
      }
      if (transaction == widget.transactions.last) {
        final title = TransactionTitle(date: date, sum: sum, first: list.isEmpty ? true : false);
        final transactionRow = TransactionRow(transactions: transactionList);
        list = [...list, title, transactionRow];
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return list.isNotEmpty
        ? Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [defaultShadow],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: list,
            ),
          )
        : Container(
            margin: const EdgeInsets.all(16),
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: const Center(
              child: Text("No transactions available"),
            ),
          );
  }
}

class TransactionTitle extends StatelessWidget with Functions {
  final DateTime date;
  final num sum;
  final bool first;

  const TransactionTitle({
    super.key,
    required this.date,
    required this.sum,
    required this.first,
  });

  @override
  Widget build(BuildContext context) {
    final color = sum >= 0 ? green : red;
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
                textScaleFactor: MediaQuery.of(context).textScaleFactor,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: numToCurrency(sum),
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
  final List<Transaction> transactions;

  const TransactionRow({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountList = ref.watch(accountsProvider);
    final categoriesList = ref.watch(categoriesProvider);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (context, i) {
          Transaction transaction = transactions[i];
          Iterable<CategoryTransaction>? categories =
              transaction.type != Type.transfer && categoriesList.value != null
                  ? categoriesList.value!.where((element) => element.id == transaction.idCategory)
                  : [];
          CategoryTransaction? category = categories.isNotEmpty ? categories.first : null;
          BankAccount account =
              accountList.value!.firstWhere((element) => element.id == transaction.idBankAccount);
          BankAccount? accountTransfer = transaction.type == Type.transfer
              ? accountList.value!
                  .firstWhere((element) => element.id == transaction.idBankAccountTransfer)
              : null;
          return Column(
            children: [
              Material(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: InkWell(
                  onTap: () {
                    ref.read(selectedTransactionUpdateProvider.notifier).state =
                        transaction;
                    ref
                        .read(transactionsProvider.notifier)
                        .transactionUpdateState();
                    ref
                        .read(transactionsProvider.notifier)
                        .transactionUpdateState()
                        .whenComplete(
                          () => Navigator.of(context).pushNamed("/add-page"),
                        );
                  },
                  borderRadius: BorderRadius.vertical(
                    top: i == 0 ? const Radius.circular(8) : Radius.zero,
                    bottom: transactions.length == i + 1 ? const Radius.circular(8) : Radius.zero,
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
                                    textScaleFactor: MediaQuery.of(context).textScaleFactor,
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              '${transaction.type == Type.expense ? "-" : ""}${numToCurrency(transaction.amount)}',
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
                              transaction.type == Type.transfer
                                  ? Row(
                                      children: [
                                        Text(
                                          account.name,
                                          style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          accountTransfer!.name,
                                          style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        if (category != null)
                                          Text(
                                            category.name,
                                            style:
                                                Theme.of(context).textTheme.labelMedium!.copyWith(
                                                      color: Theme.of(context).colorScheme.primary,
                                                    ),
                                          ),
                                        const Spacer(),
                                        Text(
                                          account.name,
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
              if (transactions.length != i + 1)
                Divider(
                  height: 1,
                  indent: 12,
                  endIndent: 12,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                ),
            ],
          );
        },
      ),
    );
  }
}
