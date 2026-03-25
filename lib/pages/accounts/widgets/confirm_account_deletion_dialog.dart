import 'package:flutter/material.dart';

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
    return AdaptiveDialog(
      title: const Text('Delete account'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Sizes.md,
        children: [
          Text(
            'Are you sure you want to delete the account named "${account.name}"?',
          ),
          const Text(
            'All recurring transactions linked to this account will be stopped.',
          ),
          const SizedBox(height: Sizes.md),
          const Text('This action cannot be undone.'),
        ],
      ),
      actions: [
        AdaptiveDialogAction(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        AdaptiveDialogAction(
          child: const Text('Delete'),
          isDestructiveAction: true,
          onPressed: onPressed,
        ),
      ],
    );
  }
}
