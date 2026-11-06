import 'package:flutter/material.dart';

import '../../../../ui/device.dart';
import '../../../../ui/widgets/native_alert_dialog.dart';

class ConfirmClearCredentialsDialog extends StatelessWidget {
  final VoidCallback onPressed;

  const ConfirmClearCredentialsDialog({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveDialog(
      title: const Text('Clear credentials'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Sizes.md,
        children: [
          Text(
            'Are you sure you want to remove your Enable Banking application '
            'ID and private key from this device?',
          ),
          Text(
            'Imported accounts and their transactions are kept, but they '
            'cannot be synced until you enter the credentials again.',
          ),
          SizedBox(height: Sizes.md),
          Text(
            'A key generated on this device cannot be recovered after removal. You may need to create a new application and reconnect your banks.',
          ),
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
          child: const Text('Clear'),
          isDestructiveAction: true,
          onPressed: onPressed,
        ),
      ],
    );
  }
}
