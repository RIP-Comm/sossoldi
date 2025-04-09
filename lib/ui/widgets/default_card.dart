import 'package:flutter/material.dart';

import '../device.dart';
import 'default_container.dart';

class DefaultCard extends StatelessWidget {
  const DefaultCard({required this.child, required this.onTap, super.key});

  final Widget child;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DefaultContainer(
      padding: EdgeInsets.zero,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(Sizes.borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(Sizes.borderRadius),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.all(Sizes.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(Sizes.borderRadius),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
