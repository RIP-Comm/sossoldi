import 'package:flutter/material.dart';

import '../../../model/category_transaction.dart';
import '../../../ui/device.dart';
import '../../../ui/widgets/native_alert_dialog.dart';

class ConfirmCategoryDeletionDialog extends StatelessWidget {
  final CategoryTransaction category;
  final VoidCallback onPressed;

  const ConfirmCategoryDeletionDialog({
    required this.category,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveDialog(
      title: const Text('Delete category'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Sizes.md,
        children: [
          Text(
            'Are you sure you want to delete the category named "${category.name}"?',
          ),
          const Text(
            'All recurring transactions linked to this category will be stopped.',
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
