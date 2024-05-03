import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sossoldi/model/transaction.dart';
import 'package:intl/intl.dart';

import '../../../model/recurring_transaction.dart';
import '../../../providers/currency_provider.dart';

class OlderRecurringPayments extends ConsumerStatefulWidget {
  final RecurringTransaction transaction;
  const OlderRecurringPayments({super.key, required this.transaction});

  @override
  ConsumerState<OlderRecurringPayments> createState() => _BudgetCardState();
}

class _BudgetCardState extends ConsumerState<OlderRecurringPayments> {
  List<Transaction>? transactions;
  num sum = 0.0;

  @override
  void initState() {
    super.initState();
    TransactionMethods()
        .getRecurrenceTransactionsById(id: widget.transaction.id)
        .then((value) {
      setState(() {
        transactions = value;
        sum = value.fold(
            0.0, (previousValue, element) => previousValue + element.amount);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyState = ref.watch(currencyStateNotifier);

    return Column(children: [
      Row(children: [
        Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.transaction.note,
                    style: const TextStyle(fontSize: 25)),
                Text(widget.transaction.recurrency,
                    style: const TextStyle(fontSize: 15)),
              ],
            )),
        Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                    "-${sum.toStringAsFixed(2)}${currencyState.selectedCurrency.symbol}",
                    style: const TextStyle(fontSize: 25, color: Colors.red)),
              ],
            ))
      ]),
      if (transactions == null)
        const CircularProgressIndicator()
      else if (transactions!.isEmpty)
        const Text(
          "All recurring payments will be displayed here",
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
        )
      else
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: transactions!.map((transaction) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  children: [
                    Text(
                      DateFormat('d MMMM').format(transaction.date),
                    ),
                    const Expanded(child: SizedBox.shrink()),
                    Text(
                      "-${transaction.amount.toString()}${currencyState.selectedCurrency.symbol}",
                      style: const TextStyle(fontSize: 14, color: Colors.red)
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
    ]);
  }
}
