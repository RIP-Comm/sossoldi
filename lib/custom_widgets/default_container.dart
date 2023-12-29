import 'package:flutter/material.dart';

import '../constants/style.dart';

class DefaultContainer extends StatefulWidget {
  const DefaultContainer({required this.child, this.padding = const EdgeInsets.all(16.0), super.key});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  State<DefaultContainer> createState() => _DefaultContainerState();
}

class _DefaultContainerState extends State<DefaultContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [defaultShadow],
      ),
      child: widget.child,
    );
  }
}
