import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/device.dart';
import '../../../ui/widgets/native_alert_dialog.dart';
import '../../../model/bank_account.dart';

class ConfirmAccountDeletionDialog extends StatelessWidget {
  final BankAccount account;
  final VoidCallback onPressed;

  const ConfirmAccountDeletionDialog({
    required this.account,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AdaptiveDialog(
      title: Text(l10n.deleteAccount),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Sizes.md,
        children: [
          Text(l10n.deleteAccountConfirm(account.name)),
          Text(l10n.deleteAccountRecurringWarning),
          const SizedBox(height: Sizes.md),
          Text(l10n.actionCannotBeUndone),
        ],
      ),
      actions: [
        AdaptiveDialogAction(
          child: Text(l10n.cancel),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        AdaptiveDialogAction(
          child: Text(l10n.delete),
          isDestructiveAction: true,
          onPressed: onPressed,
        ),
      ],
    );
  }
}
