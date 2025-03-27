import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;

const _kAnimationDuration = Duration(milliseconds: 200);
const _kAnimationCurve = Curves.easeInOut;

/// A container widget that provides a consistent layout for selector components.
///
/// This widget is typically used as a wrapper for [SelectorTile] components to provide
/// a consistent layout and styling. It can optionally display a label above its child widget.
///
/// The container can be expanded or collapsed by tapping on the header area,
/// with a chevron indicator showing the current expansion state. The chevron can be toggled
/// on or off. It defaults to on.
///
/// Example:
/// ```dart
/// SelectorContainer(
///   label: 'Options',
///   child: SelectorTile(
///     title: 'Option 1',
///   ),
/// )
/// ```
class SelectorContainer extends StatefulWidget {
  /// An optional label to display above the child widget.
  ///
  /// When provided, this text will be displayed as a header above the container's
  /// main content using the theme's label style.
  final String? label;

  /// The widget to be displayed inside the container.
  ///
  /// Typically this would be a [SelectorTile] or a list of selector tiles, but
  /// it can be any widget that fits the selector pattern's use case.
  final Widget? child;

  /// Whether the container should start in an expanded state.
  ///
  /// Defaults to `false`.
  final bool initiallyExpanded;

  /// Whether a rotating chevron should be shown on the right side of the container.
  ///
  /// Defaults to `true`.
  final bool hasTrailingChevron;

  const SelectorContainer({
    this.label,
    this.child,
    this.initiallyExpanded = false,
    this.hasTrailingChevron = true,
    super.key,
  });

  @override
  State<SelectorContainer> createState() => _SelectorContainerState();
}

class _SelectorContainerState extends State<SelectorContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: _kAnimationDuration,
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: _kAnimationCurve,
    );

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context);

    final childContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.child ?? const SizedBox.shrink(),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: appTheme.colorScheme.surface,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null && widget.label!.isNotEmpty)
            InkWell(
              onTap: _toggleExpanded,
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _expandAnimation,
                      builder: (context, _) {
                        // Interpolates between collapsed and expanded textTheme.
                        //
                        // Base styles from theme.
                        final baseStyle = appTheme.textTheme.labelMedium;

                        // The expanded size uses the baseStyle, the fontSize for labelMedium is 12.
                        final expandedSize = baseStyle?.fontSize ?? 12.0;

                        // Collapsed size is slightly bigger, uses titleMedium which has fontSize 14.
                        final collapsedSize =
                            appTheme.textTheme.bodyMedium?.fontSize ?? 14.0;

                        // Use lerp function to smoothly interpolate between sizes.
                        //
                        // lerpDouble handles the transition based on the animation value.
                        // We use (1 - value) to invert the animation direction
                        final interpolatedSize = lerpDouble(expandedSize,
                            collapsedSize, 1 - _expandAnimation.value);

                        // Create the interpolated text style
                        final textStyle = baseStyle?.copyWith(
                          fontSize: interpolatedSize,
                          fontWeight: FontWeight.lerp(
                            FontWeight.w600,
                            FontWeight.w400,
                            _expandAnimation.value,
                          ),
                        );

                        return Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(
                            vertical: _isExpanded ? 0 : 4,
                          ),
                          child: Text(
                            widget.label!,
                            style: textStyle,
                          ),
                        );
                      },
                    ),
                  ),
                  if (widget.hasTrailingChevron)
                    AnimatedRotation(
                      turns: _isExpanded ? 0.0 : -0.25,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: appTheme.colorScheme.onSurface,
                        size: 24,
                      ),
                    ),
                ],
              ),
            ),
          AnimatedBuilder(
            animation: _expandAnimation,
            child: childContent,
            builder: (context, child) {
              // When expanded, use a small gap, when collapsed use no gap
              final gapHeight = _expandAnimation.value * 8.0;

              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _expandAnimation.value,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.label != null && widget.label!.isNotEmpty)
                        SizedBox(height: gapHeight),
                      Opacity(
                        opacity: _expandAnimation.value,
                        child: child,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
