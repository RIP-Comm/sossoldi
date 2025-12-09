import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/transaction.dart';
import '../../providers/transactions_provider.dart';
import 'snack_bar.dart';

void showDuplicatedTransactionSnackBar(
  BuildContext context, {
  required Transaction? transaction,
  required WidgetRef ref,
}) => showSnackBar(
  context,
  actionLabel: "Edit",
  onAction: transaction != null
      ? () async {
          await ref
              .read(transactionsProvider.notifier)
              .transactionSelect(transaction);
          if (context.mounted) {
            Navigator.of(context).pushNamed("/add-page");
          }
        }
      : null,
  message: transaction != null
      ? "${transaction.note} has been created"
      : "Error duplicating transaction",
);
