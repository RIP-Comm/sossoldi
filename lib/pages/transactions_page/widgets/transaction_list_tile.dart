import "package:flutter/material.dart";

import '../../../constants/style.dart';
import '../../../constants/functions.dart';
import '../../../model/transaction.dart';

class TransactionListTile extends StatelessWidget with Functions {
  const TransactionListTile({
    Key? key,
    required this.title,
    required this.type,
    required this.amount,
    required this.color,
    required this.category,
    required this.icon,
    required this.account,
  }) : super(key: key);

  final String title;
  final Type type;
  final double amount;
  final Color color;
  final String category;
  final IconData icon;
  final String account;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: white,
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 12.0,
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
            child: Icon(icon, color: white),
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
                      "${type == Type.expense ? '-' : ''}${numToCurrency(amount)} €",
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: typeToColor(type)),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category.toUpperCase(),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    Text(
                      account.toUpperCase(),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
