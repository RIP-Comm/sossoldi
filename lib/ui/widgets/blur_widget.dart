import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../pages/structure.dart';

class BlurWidget extends ConsumerWidget {
  const BlurWidget({super.key, required this.child, this.blur = true});

  final Widget child;

  final bool blur;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!blur) return child;

    final isVisible = ref.watch(visibilityAmountProvider);
    if (isVisible) return child;

    return ClipRRect(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 4.5, sigmaY: 4.5),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
          child: child,
        ),
      ),
    );
  }
}
