import 'package:flutter/material.dart';

class SelectorContainer extends StatelessWidget {
  final String? label;
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
            const SizedBox(height: 8),
          ],
          child ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
