import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/style.dart';

/// A list tile like component that can be used for handling selection.
///
/// Should be used together with [SelectorContainer] but can work as a standalone
/// component as well.
///
/// Only required property is [title].
class SelectorTile extends ConsumerWidget {
  /// The title [String] of the tile, will be displayed on the left side of the tile.
  final String title;

  /// An optional trailing [String], will be displayed on the right side of the tile.
  final String? trailing;

  /// An optional trailing [Widget], will be displayed on the right side of the
  /// tile only if [trailing] is `null`.
  final Widget? trailingWidget;

  /// Whether or not this tile is selected.
  ///
  /// When selected, [title], [trailing] and the [Container] borders will be
  /// colored of [colorScheme.onSurfaceVariant].
  final bool isSelected;

  /// Callback function that is called when the tile is tapped.
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
            const SizedBox(width: 8.0),
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
