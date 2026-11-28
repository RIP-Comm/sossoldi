import 'package:flutter/material.dart';

import '../../../model/bank_connection.dart';
import '../../../ui/device.dart';
import '../../../ui/widgets/native_alert_dialog.dart';

class ConfirmDisconnectDialog extends StatelessWidget {
  final BankConnection connection;
  final VoidCallback onPressed;

  const ConfirmDisconnectDialog({
    required this.connection,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveDialog(
      title: const Text('Disconnect bank'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Sizes.md,
        children: [
          Text(
            'Are you sure you want to disconnect '
            '"${connection.institutionName}"?',
          ),
          const Text(
            'Your imported accounts and transaction history stay in Sossoldi. '
            'The accounts become manual accounts and stop syncing.',
          ),
          const SizedBox(height: Sizes.md),
          const Text('This also revokes this bank connection’s consent.'),
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
          child: const Text('Disconnect'),
          isDestructiveAction: true,
          onPressed: onPressed,
        ),
      ],
    );
  }
}
