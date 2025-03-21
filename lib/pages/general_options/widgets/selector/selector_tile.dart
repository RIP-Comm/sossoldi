import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/style.dart';

class SelectorTile extends ConsumerWidget {
  final String title;
  final String? trailing;
  final Widget? trailingWidget;
  final bool isSelected;
  final VoidCallback? onTap;

  const SelectorTile({
    required this.title,
    this.trailing,
    this.trailingWidget,
    this.isSelected = false,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            width: isSelected ? 1.0 : .5,
            color: isSelected ? appTheme.colorScheme.onSurfaceVariant : grey2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: appTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected
                      ? appTheme.colorScheme.onSurfaceVariant
                      : appTheme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (trailing != null) ...[
              Text(
                trailing!,
                style: appTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected
                      ? appTheme.colorScheme.onSurfaceVariant
                      : appTheme.colorScheme.onSurface,
                ),
              ),
            ],
            if (trailing == null && trailingWidget != null) trailingWidget!,
          ],
        ),
      ),
    );
  }
}
