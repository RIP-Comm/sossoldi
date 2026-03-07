import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../model/transaction.dart';
import '../../providers/transactions_provider.dart';
import 'snack_bar.dart';

void showDuplicatedTransactionSnackBar(
  BuildContext context, {
  required Transaction? transaction,
  required WidgetRef ref,
}) {
  var l10n = AppLocalizations.of(context)!;
  return  showSnackBar(
  context,
  actionLabel: l10n.edit,
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
      ? l10n.transactionCreated(transaction.note.toString())
      : l10n.errorDuplicatingTransaction,
);}
