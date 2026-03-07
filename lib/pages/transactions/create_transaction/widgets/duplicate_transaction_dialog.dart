import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../model/transaction.dart';
import '../../../../providers/transactions_provider.dart';
import '../../../../ui/device.dart';

class DuplicateTransactionDialog extends ConsumerWidget {
  const DuplicateTransactionDialog({super.key, required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.duplicateTransactionTitle),
      content: Text(
        AppLocalizations.of(context)!.duplicateTransactionContent,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(fontSize: 14)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.lg),
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
          child: Text(AppLocalizations.of(context)!.duplicate),
        ),
      ],
    );
  }
}
