import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/style.dart';
import '../../../../ui/device.dart';

const _kSelectedBorderWidth = 1.0;
const _kUnselectedBorderWidth = .5;

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

  /// Optional [TextStyle] to customize the appearance of the [trailing] text.
  ///
  /// If not provided, the default text style will be used.
  final TextStyle? trailingTextStyle;

  /// An optional trailing [Widget], will be displayed on the right side of the
  /// tile only if [trailing] is `null`.
  ///
  /// The widget's colors should match the [title]'s color scheme:
  /// - Use `colorScheme.onSurfaceVariant` when [isSelected] is true
  /// - Use `colorScheme.onSurface` when [isSelected] is false
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
    this.trailingTextStyle,
    this.trailingWidget,
    this.isSelected = false,
    this.onTap,
    super.key,
  }) : assert(
          trailing == null || trailingWidget == null,
          'Cannot provide both trailing and trailingWidget at the same time',
        );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(Sizes.lg),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Sizes.borderRadiusSmall),
          border: Border.all(
            width: isSelected ? _kSelectedBorderWidth : _kUnselectedBorderWidth,
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
            const SizedBox(width: Sizes.sm),
            if (trailing != null) ...[
              Text(
                trailing!,
                style: trailingTextStyle ??
                    appTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w400,
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
