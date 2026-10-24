import 'package:flutter/material.dart';

import '../../../model/category_transaction.dart';
import '../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    return AdaptiveDialog(
      title: Text(l10n.deleteCategory),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Sizes.md,
        children: [
          Text(l10n.deleteCategoryConfirm(category.name)),
          Text(l10n.deleteCategoryLinkedWarning),
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
