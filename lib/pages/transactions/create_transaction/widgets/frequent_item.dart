import 'package:flutter/material.dart';

import '../../../../constants/style.dart';
import '../../../../ui/device.dart';
import '../../../../ui/widgets/rounded_icon.dart';

/// Item of the "MORE FREQUENT" row: the icon bounces when tapped and a check
/// badge pops in while the item is selected
class FrequentItem extends StatefulWidget {
  const FrequentItem({
    required this.label,
    this.icon,
    this.color,
    this.selected = false,
    this.onTap,
    super.key,
  });

  static const animationDuration = Duration(milliseconds: 300);

  final String label;
  final IconData? icon;
  final Color? color;
  final bool selected;
  final VoidCallback? onTap;

  @override
  State<FrequentItem> createState() => _FrequentItemState();
}

class _FrequentItemState extends State<FrequentItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: FrequentItem.animationDuration,
  );
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 0.85,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 30,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 0.85,
        end: 1.12,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 40,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.12,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeIn)),
      weight: 30,
    ),
  ]).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!MediaQuery.disableAnimationsOf(context)) {
      _controller.forward(from: 0);
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: widget.onTap != null ? _onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Sizes.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  RoundedIcon(icon: widget.icon, backgroundColor: widget.color),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: AnimatedScale(
                      scale: widget.selected ? 1 : 0,
                      duration: FrequentItem.animationDuration,
                      curve: widget.selected
                          ? Curves.easeOutBack
                          : Curves.easeIn,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primary,
                          border: Border.all(
                            color: colorScheme.surface,
                            width: 2,
                          ),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: const Icon(Icons.check, size: 12, color: white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              widget.label,
              style: Theme.of(
                context,
              ).textTheme.labelLarge!.copyWith(color: colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}
