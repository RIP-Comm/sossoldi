import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/transaction.dart';
import '../../providers/transactions_provider.dart';
import 'snack_bar.dart';

showDuplicatedTransactionSnackBar(BuildContext context,
        {required Transaction? transaction, required WidgetRef ref}) =>
    showSnackBar(context,
        actionLabel: "Edit",
        onAction: transaction != null
            ? () {
                if (context.mounted) {
                  ref
                      .read(transactionsProvider.notifier)
                      .transactionUpdateState(transaction);
                  Navigator.of(context).pushNamed("/add-page");
                }
              }
            : null,
        message: transaction != null
            ? "${transaction.note} has been created"
            : "Error duplicating transaction");
