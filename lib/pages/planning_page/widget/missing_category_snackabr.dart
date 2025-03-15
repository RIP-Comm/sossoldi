import 'package:flutter/material.dart';

/// SnackBar content for lib\pages\planning_page\manage_budget_page.dart:50.
/// 
/// Used to prompt the user to add a category before adding a category budget.
class MissingCategorySnackBarContent extends StatelessWidget {
  final VoidCallback onActionPressed;

  const MissingCategorySnackBarContent({
    required this.onActionPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
              "At least one category must be created before adding a category budget."),
        ),
        TextButton.icon(
          onPressed: onActionPressed,
          label: Text(
            'ADD',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
        ),
      ],
    );
  }
}
