import 'package:flutter/material.dart';

import '../../constants/style.dart';
import '../device.dart';

class RoundedIcon extends StatelessWidget {
  const RoundedIcon({
    this.icon,
    this.backgroundColor,
    this.size = 24,
    this.padding = const EdgeInsets.all(Sizes.md),
    super.key,
  });

  final IconData? icon;
  final Color? backgroundColor;
  final double? size;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
