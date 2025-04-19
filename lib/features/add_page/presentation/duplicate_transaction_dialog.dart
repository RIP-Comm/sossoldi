import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/transaction.dart';
import '../../../providers/transactions_provider.dart';

class DuplicateTransactionDialog extends ConsumerWidget {
  const DuplicateTransactionDialog({super.key, required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text("Duplicate transaction"),
      content: const Text(
        "This transaction is already in the list. Do you want to duplicate it? You can then edit the new transaction.",
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            "Cancel",
            style: TextStyle(fontSize: 14),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          onPressed: () => ref
              .read(transactionsProvider.notifier)
              .duplicateTransaction(transaction)
              .then((t) {
            if (context.mounted) {
              Navigator.of(context)
                ..pop()
                ..pop();
            }
          }),
          child: const Text("Duplicate"),
        ),
      ],
    );
  }
}
