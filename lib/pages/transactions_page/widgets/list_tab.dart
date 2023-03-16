import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../constants/style.dart';
import '../../../model/transaction.dart';
import '../../../pages/transactions_page/widgets/transaction_list_tile.dart';

class ListTab extends StatelessWidget {
  const ListTab({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: get list of transactions from database
    List<Transaction> transactions = [
      Transaction(
        id: 0,
        recurring: false,
        date: DateTime.now(),
        amount: 300,
        type: Type.income,
        idBankAccount: 0,
        idCategory: 0,
      ),
      Transaction(
        id: 1,
        recurring: false,
        date: DateTime.now(),
        amount: 65,
        type: Type.income,
        idBankAccount: 0,
        idCategory: 0,
      ),
      Transaction(
        id: 2,
        recurring: false,
        date: DateTime.now().subtract(Duration(days: 1)),
        amount: 34,
        type: Type.income,
        idBankAccount: 0,
        idCategory: 0,
      ),
      Transaction(
        id: 3,
        recurring: false,
        date: DateTime.now().subtract(Duration(days: 3)),
        amount: -304,
        type: Type.income,
        idBankAccount: 0,
        idCategory: 0,
      ),
      Transaction(
        id: 4,
        recurring: false,
        date: DateTime.now().subtract(Duration(days: 3)),
        amount: 231,
        type: Type.income,
        idBankAccount: 0,
        idCategory: 0,
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      color: grey3,
      child: ListView.separated(
        itemCount: transactions.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            return DateSeparator(
              transaction: transactions[i],
              total: 123,
            );
          } else {
            return TransactionListTile(
              title:
                  "${transactions[i - 1].date.day}-${transactions[i - 1].date.month}",
              amount: transactions[i - 1].amount.toDouble(),
              account: "Account",
              category: "Category",
              color: Colors.red,
              icon: Icons.home,
            );
          }
        },
        separatorBuilder: (context, i) {
          if (i == 0) {
            return const SizedBox(height: 0);
          } else {
            if (!transactions[i - 1].date.isSameDate(transactions[i].date)) {
              return DateSeparator(
                transaction: transactions[i],
                total: 123,
              );
            } else {
              return const Divider(
                height: 0,
                thickness: 1,
                endIndent: 10,
                indent: 10,
              );
            }
          }
        },
      ),
    );
  }
}

class DateSeparator extends StatelessWidget {
  const DateSeparator({
    Key? key,
    required this.transaction,
    required this.total,
  }) : super(key: key);

  final Transaction transaction;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            transaction.date.formatDate(),
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(color: blue1),
          ),
          Text(
            "$total €",
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: (total > 0) ? green : red),
          )
        ],
      ),
    );
  }
}

const String dateFormatter = 'MMMM d, EEEE';

extension DateHelper on DateTime {
  String formatDate() {
    final formatter = DateFormat(dateFormatter);
    return formatter.format(this);
  }

  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
