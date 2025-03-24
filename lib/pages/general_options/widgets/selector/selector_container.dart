import 'package:flutter/material.dart';

/// A container widget that provides a consistent layout for selector components.
///
/// This widget is typically used as a wrapper for [SelectorTile] components to provide
/// a consistent layout and styling. It can optionally display a label above its child widget.
///
/// Example:
/// ```dart
/// SelectorContainer(
///   label: 'Options',
///   child: SelectorTile(
///     title: 'Option 1',
///   ),
/// )
/// ```
class SelectorContainer extends StatelessWidget {
  /// An optional label to display above the child widget.
  ///
  /// When provided, this text will be displayed as a header above the container's
  /// main content using the theme's label style.
  final String? label;

  /// The widget to be displayed inside the container.
  ///
  /// Typically this would be a [SelectorTile] or a list of selector tiles, but
  /// it can be any widget that fits the selector pattern's use case.
  final Widget? child;

  const SelectorContainer({
    this.label,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: appTheme.colorScheme.surface,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null && label!.isNotEmpty) ...[
            Text(
              label!.toUpperCase(),
              style: appTheme.textTheme.labelMedium,
            ),
            const SizedBox(height: 8.0),
          ],
          child ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
