import 'package:flutter/material.dart';

import '../constants/style.dart';
import '../ui/device.dart';

class DefaultContainer extends StatelessWidget {
  const DefaultContainer({
    required this.child,
    this.padding = const EdgeInsets.all(Sizes.lg),
    this.margin = const EdgeInsets.symmetric(horizontal: Sizes.lg),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(Sizes.borderRadius),
        boxShadow: [defaultShadow],
      ),
      child: child,
    );
  }
}
