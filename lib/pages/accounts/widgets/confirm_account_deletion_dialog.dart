import 'package:flutter/material.dart';

import '../../../custom_widgets/native_alert_dialog.dart';
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
      title: Text('Delete account'),
      content: Text(
          'Are you sure you want to delete the account named "${account.name}"?\n\nThis action cannot be undone.'),
      actions: [
        AdaptiveDialogAction(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        AdaptiveDialogAction(
          child: Text('Delete'),
          isDestructiveAction: true,
          onPressed: onPressed,
        ),
      ],
    );
  }
}
