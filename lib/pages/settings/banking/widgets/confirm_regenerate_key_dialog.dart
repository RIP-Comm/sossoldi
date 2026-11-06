import 'package:flutter/material.dart';

import '../../../../ui/device.dart';
import '../../../../ui/widgets/native_alert_dialog.dart';

class ConfirmRegenerateKeyDialog extends StatelessWidget {
  final VoidCallback onPressed;

  const ConfirmRegenerateKeyDialog({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveDialog(
      title: const Text('Generate a new key?'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Sizes.md,
        children: [
          Text(
            'A new key replaces any unfinished key setup. Your verified '
            'credentials stay active until you save a verified replacement.',
          ),
          Text(
            'Register the new public certificate with Enable Banking, then '
            'use the matching application ID when saving your credentials.',
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
          child: const Text('Generate'),
          isDestructiveAction: true,
          onPressed: onPressed,
        ),
      ],
    );
  }
}
