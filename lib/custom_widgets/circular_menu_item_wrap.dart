import 'package:circular_menu/circular_menu.dart';
import 'package:flutter/material.dart';

class CircularMenuItemWrap extends CircularMenuItem {
  final VoidCallback onTap;
  final String text;
  final Color? iconColor;
  final Color? color;
  final IconData? icon;

  CircularMenuItemWrap({
    required this.onTap,
    this.color,
    required this.text,
    this.icon,
    this.iconColor,
  }) : super(onTap: onTap, icon: icon, iconColor: iconColor, color: color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        super.build(context),
        Text(text,
            style: const TextStyle(
                color: Colors.black,
                fontSize: 12.0,
                fontFamily: 'SF Pro Text')),
      ],
    );
  }
}
