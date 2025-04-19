import 'package:flutter/material.dart';

import '../../constants/style.dart';

class RoundedIcon extends StatelessWidget {
  const RoundedIcon({
    this.icon,
    this.backgroundColor,
    this.size = 24,
    this.padding = const EdgeInsets.all(10.0),
    this.markedAsDeleted = false,
    this.onDelete,
    super.key,
  });

  final IconData? icon;
  final Color? backgroundColor;
  final double? size;
  final EdgeInsets? padding;
  final bool markedAsDeleted;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundColor,
          ),
          padding: padding,
          child: icon != null
              ? Icon(
                  icon,
                  size: size,
                  color: white,
                )
              : const SizedBox(),
        ),
        if (markedAsDeleted)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: category0,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Icon(
                Icons.dangerous,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}
