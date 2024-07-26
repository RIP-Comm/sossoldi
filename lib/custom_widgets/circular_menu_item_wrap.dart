import 'package:circular_menu/circular_menu.dart';
import 'package:flutter/material.dart';

class CircularMenuItemWrap extends CircularMenuItem {
  final String text;

  CircularMenuItemWrap({super.key,
    required super.onTap,
    super.color,
    required this.text,
    super.icon,
    super.iconColor,  
  });
        
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
