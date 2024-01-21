import 'package:flutter/material.dart';

import 'default_container.dart';

class DefaultCard extends StatefulWidget {
  const DefaultCard({required this.child, required this.onTap, super.key});

  final Widget child;
  final GestureTapCallback? onTap;

  @override
  State<DefaultCard> createState() => _DefaultCardState();
}

class _DefaultCardState extends State<DefaultCard> {
  @override
  Widget build(BuildContext context) {
    return DefaultContainer(
      padding: const EdgeInsets.all(0),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: widget.onTap,
          child: Ink(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
