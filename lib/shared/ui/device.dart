import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Different categories a device screen can be associated.
// One could add more types if necessary these three should suffice for most apps
enum ScreenSize {
  mobile,
  tablet,
  desktop;

  T map<T>({required T mobile, required T desktop, required T tablet}) {
    switch (this) {
      case ScreenSize.mobile:
        return mobile;
      case ScreenSize.tablet:
        return tablet;
      case ScreenSize.desktop:
        return desktop;
    }
  }
}

extension ScreenSizeX on BuildContext {
  /// {@macro BreakPoint.screenType}
  // By altering the default value of the breakpoint, one can modify the breakpoint being used.
  ScreenSize screenSize([BreakPoint? breakpoint]) {
    breakpoint ??= BreakPoint.instance;
    return breakpoint.screenType(MediaQuery.of(this).size.shortestSide);
  }

  /// {@macro BreakPoint.isMobile}
  bool get isMobile => screenSize() == ScreenSize.mobile;

  /// {@macro BreakPoint.isTablet}
  bool get isTablet => screenSize() == ScreenSize.tablet;

  /// True if the device screen size is a tablet or desktop.
  bool get isTabletOrLarger =>
      screenSize() == ScreenSize.tablet || screenSize() == ScreenSize.desktop;

  /// {@macro BreakPoint.isDesktop}
  bool get isDesktop => screenSize() == ScreenSize.desktop;

  /// True If the keyboard is visible in the screen
  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 100;
}

/// A Breakpoint describes (in density) pixels certain points in which the UI should alter its appeal.
/// If a device screen size is greater than [desktop] it should be presented a desktop layout.
/// if its greater than [tablet] a tablet layout, else a [mobile] layout.
/// These breakpoints help to centralize in a place the different rules we apply to adapt apps
/// to different screen sizes.
///
/// See also [Device] as to segment the user experience based on the actual OS running in the device
/// not just the screen.
class BreakPoint {
  final num tablet;
  final num desktop;

  static BreakPoint? _instance;

  static BreakPoint get instance {
    return _instance ?? const BreakPoint.material();
  }

  /// Changes the default BreakPoint [instance] to [breakPoint].
  static void setDefaultBreakPoint(BreakPoint breakPoint) {
    _instance = breakPoint;
  }

  const BreakPoint({required this.tablet, required this.desktop});

  //https://developer.android.com/guide/topics/large-screens/support-different-screen-sizes
  const BreakPoint.android() : this(tablet: 600, desktop: 840);

  // https://m1.material.io/layout/responsive-ui.html#responsive-ui-breakpoints
  const BreakPoint.material() : this(tablet: 600, desktop: 960);

  // https://learn.microsoft.com/en-us/windows/apps/design/layout/screen-sizes-and-breakpoints-for-responsive-design
  const BreakPoint.windows() : this(tablet: 640, desktop: 1007);

  // https://developer.apple.com/design/human-interface-guidelines/foundations/layout/
  const BreakPoint.cupertino() : this(tablet: 767, desktop: 1024);

  /// {@template BreakPoint.isMobile}
  /// True if the device screen size is a mobile device according to a [BreakPoint]
  /// {@endtemplate}
  bool isMobile(double size) => size < tablet;

  /// {@template BreakPoint.isTablet}
  /// True if the device screen size is a tablet according to a [BreakPoint].
  /// {@endtemplate}
  bool isTablet(double size) => size > tablet && size < desktop;

  /// {@template BreakPoint.isDesktop}
  /// True if the device screen size is a tablet according to a [BreakPoint].
  /// {@endtemplate}
  bool isDesktop(double size) => size > desktop;

  /// {@template BreakPoint.screenType}
  /// Returns a devices [ScreenSize] according to it's shortest side in pixels.
  /// Note: that [ScreenSize] only refers to the screen attributes, one could have
  /// a desktop computer with a small screen. So use this only to assist UI decisions.
  /// {@endtemplate}
  ScreenSize screenType(double shortestSide) {
    if (shortestSide > desktop) return ScreenSize.desktop;
    if (shortestSide > tablet) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }
}

///Holds common sizes for icons, images, paddings, corners etc
// Change the base [unit] if necessary to accommodate to the design
class Sizes {
  static const double unit = 16;

  /// Size: 2
  static const double xxs = 0.125 * unit;

  /// Size: 4
  static const double xs = 0.25 * unit;

  /// Size: 8
  static const double sm = 0.5 * unit;

  /// Size: 12
  static const double md = 0.75 * unit;

  /// Size: 16
  static const double lg = unit;

  /// Size: 24
  static const double xl = 1.5 * unit;

  /// Size: 32
  static const double xxl = 2 * unit;

  /// Large BorderRadius: 16
  static const double borderRadiusLarge = unit;

  /// Default BorderRadius: 8
  static const double borderRadius = 0.5 * unit;

  /// Small BorderRadius: 4
  static const double borderRadiusSmall = 0.25 * unit;

  /// Edge insets and margins for phone breakpoint size.
  static const double edgeInsetsPhone = lg;

  /// Edge insets and margins for tablet breakpoint size.
  static const double edgeInsetsTablet = xl;

  /// Edge insets and margins for desktop and medium desktop breakpoint sizes.
  static const double edgeInsetsDesktop = xxl;

  static double responsiveInsets(BuildContext context) {
    final screen = context.screenSize();

    switch (screen) {
      case ScreenSize.mobile:
        return edgeInsetsPhone;
      case ScreenSize.tablet:
        return edgeInsetsTablet;
      case ScreenSize.desktop:
        return edgeInsetsDesktop;
    }
  }
}

/// Workaround to securely asses the underlying Operating System in which the flutter app is executing
// See https://github.com/flutter/flutter/issues/50845
class Device {
  static final isMobileDevice =
      !kIsWeb && (Platform.isIOS || Platform.isAndroid);
  static final isAndroid = !kIsWeb && Platform.isAndroid;
  static final isIOS = !kIsWeb && Platform.isIOS;

  static final isDesktopDevice =
      !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);
  static final isLinux = !kIsWeb && Platform.isLinux;
  static final isMacOS = !kIsWeb && Platform.isMacOS;
  static final isWindows = !kIsWeb && Platform.isWindows;

  static const isWeb = kIsWeb;
}
