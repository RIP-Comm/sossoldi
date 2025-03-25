import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/style.dart';
import '../ui/device.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    adaptations: [SwitchThemeAdaptation()],
    cupertinoOverrideTheme: const CupertinoThemeData(
      brightness: Brightness.light,
    ),
    colorScheme: customColorScheme,
    scaffoldBackgroundColor: white,
    appBarTheme: const AppBarTheme(
      color: white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: blue5),
      titleTextStyle: TextStyle(
        fontFamily: 'NunitoSans',
        color: blue1,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: grey3,
      unselectedItemColor: grey1,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: blue5,
      shape: CircleBorder(),
    ),
    tabBarTheme: TabBarTheme(
      indicator: BoxDecoration(
        shape: BoxShape.circle,
        color: blue5,
      ),
      dividerHeight: 0,
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: white,
      unselectedLabelColor: blue5,
    ),
    iconTheme: const IconThemeData(color: blue1),
    dividerTheme: DividerThemeData(
      color: grey1,
      space: 0.5,
      thickness: 0.5,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: white,
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: const WidgetStatePropertyAll(blue5),
        iconColor: const WidgetStatePropertyAll(blue5),
        padding: const WidgetStatePropertyAll(EdgeInsets.all(12)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius)),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'NunitoSans',
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: const WidgetStatePropertyAll(white),
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return grey2;
          }
          return blue5;
        }),
        elevation: WidgetStatePropertyAll(0),
        padding: WidgetStatePropertyAll(EdgeInsets.all(16)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius)),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'NunitoSans',
            fontSize: 14.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.all(4)),
        iconSize: WidgetStatePropertyAll(28),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius)),
        ),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      tileColor: white,
      contentPadding: EdgeInsets.all(16),
    ),
    disabledColor: grey2,
    switchTheme: SwitchThemeData(
      trackOutlineColor: WidgetStateColor.resolveWith(
        (state) {
          if (state.contains(WidgetState.selected)) {
            return customColorScheme.secondary;
          }

          return grey1;
        },
      ),
      thumbColor: WidgetStateColor.resolveWith(
        (state) {
          if (state.contains(WidgetState.selected)) {
            return customColorScheme.surface;
          }

          return grey1;
        },
      ),
      trackColor: WidgetStateColor.resolveWith(
        (state) {
          if (state.contains(WidgetState.selected)) {
            return customColorScheme.secondary;
          }

          return grey3;
        },
      ),
    ),
    fontFamily: 'NunitoSans',
    textTheme: const TextTheme(
      // display
      displayLarge: TextStyle(
        fontSize: 34.0,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: TextStyle(
        fontSize: 34.0,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),

      // headline
      headlineLarge: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.w600,
      ),

      // title
      titleLarge: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w400,
      ),

      // body
      bodyLarge: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w700,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
      ),
      bodySmall: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
      ),

      // label
      labelLarge: TextStyle(
        fontSize: 10.0,
        fontWeight: FontWeight.w700,
      ),
      labelMedium: TextStyle(
        fontSize: 10.0,
        fontWeight: FontWeight.w400,
      ),
      labelSmall: TextStyle(
        fontSize: 8.0,
        fontWeight: FontWeight.w700,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: InputBorder.none,
      contentPadding: const EdgeInsets.all(0),
      hintStyle: TextStyle(color: grey2),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: customColorScheme.primaryContainer,
      contentTextStyle: TextStyle(
        color: customColorScheme.onSurface,
        fontSize: 16,
      ),
      behavior: SnackBarBehavior.floating,
      insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );

  static final darkTheme = ThemeData(
    adaptations: [SwitchThemeAdaptation()],
    cupertinoOverrideTheme: const CupertinoThemeData(
      brightness: Brightness.dark,
    ),
    colorScheme: darkCustomColorScheme,
    scaffoldBackgroundColor: darkGrey4,
    appBarTheme: const AppBarTheme(
      color: darkGrey3,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: darkBlue5),
      titleTextStyle: TextStyle(
        fontFamily: 'NunitoSans',
        color: darkBlue1,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkBlue7,
      unselectedItemColor: darkGrey1,
      selectedItemColor: darkBlue1,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: darkBlue1,
      shape: CircleBorder(),
    ),
    tabBarTheme: TabBarTheme(
      indicator: BoxDecoration(
        shape: BoxShape.circle,
        color: darkBlue5,
      ),
      dividerHeight: 0,
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: white,
      unselectedLabelColor: grey2,
    ),
    iconTheme: const IconThemeData(color: darkBlue1),
    dividerTheme: DividerThemeData(
      color: darkGrey1,
      space: 0.5,
      thickness: 0.5,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: darkGrey4,
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: const WidgetStatePropertyAll(white),
        iconColor: const WidgetStatePropertyAll(white),
        padding: const WidgetStatePropertyAll(EdgeInsets.all(12)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius)),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'NunitoSans',
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: const WidgetStatePropertyAll(white),
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return grey2;
          }
          return darkBlue5;
        }),
        elevation: WidgetStatePropertyAll(0),
        padding: WidgetStatePropertyAll(EdgeInsets.all(16)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius)),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'NunitoSans',
            fontSize: 14.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.all(4)),
        iconSize: WidgetStatePropertyAll(28),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.borderRadius)),
        ),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      tileColor: darkGrey4,
      contentPadding: EdgeInsets.all(16),
    ),

    disabledColor: darkGrey2,
    switchTheme: SwitchThemeData(
      trackOutlineColor: WidgetStateColor.resolveWith(
        (state) {
          if (state.contains(WidgetState.selected)) {
            return darkCustomColorScheme.secondary;
          }

          return darkGrey1;
        },
      ),
      thumbColor: WidgetStateColor.resolveWith(
        (state) {
          if (state.contains(WidgetState.selected)) {
            return darkCustomColorScheme.surface;
          }

          return darkGrey1;
        },
      ),
      trackColor: WidgetStateColor.resolveWith(
        (state) {
          if (state.contains(WidgetState.selected)) {
            return darkCustomColorScheme.secondary;
          }

          return darkGrey3;
        },
      ),
    ),
    //Text style
    fontFamily: 'NunitoSans',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 34.0,
        fontWeight: FontWeight.w700,
        color: darkBlack,
      ),
      displayMedium: TextStyle(
        fontSize: 34.0,
        fontWeight: FontWeight.w600,
        color: darkBlack,
      ),
      // headline
      headlineLarge: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.w700,
        color: darkBlack,
      ),
      headlineMedium: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.w600,
        color: darkBlack,
      ),

      // title
      titleLarge: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w700,
        color: darkBlack,
      ),
      titleMedium: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: darkBlack,
      ),
      titleSmall: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w400,
        color: darkBlack,
      ),

      // body
      bodyLarge: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w700,
        color: darkBlack,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        color: darkBlack,
      ),
      bodySmall: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        color: darkBlack,
      ),

      // label
      labelLarge: TextStyle(
        fontSize: 10.0,
        fontWeight: FontWeight.w700,
        color: darkBlack,
      ),
      labelMedium: TextStyle(
        fontSize: 10.0,
        fontWeight: FontWeight.w400,
        color: darkBlack,
      ),
      labelSmall: TextStyle(
        fontSize: 8.0,
        fontWeight: FontWeight.w700,
        color: darkBlack,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: InputBorder.none,
      contentPadding: const EdgeInsets.all(0),
      hintStyle: TextStyle(color: grey2),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkCustomColorScheme.primaryContainer,
      contentTextStyle: TextStyle(
        color: darkCustomColorScheme.onSurface,
        fontSize: 16,
      ),
      behavior: SnackBarBehavior.floating,
      insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );
}

ColorScheme customColorScheme = const ColorScheme(
  primary: blue1,
  primaryContainer: white,
  onPrimaryContainer: blue2,
  secondary: blue5,
  tertiary: blue7,
  surface: grey3,
  error: red,
  onPrimary: white,
  onSecondary: white,
  onSurface: blue1,
  onError: black,
  brightness: Brightness.light,
);

ColorScheme darkCustomColorScheme = const ColorScheme(
  primary: darkBlue1,
  primaryContainer: darkGrey4,
  onPrimaryContainer: darkBlue1,
  secondary: darkBlue5,
  tertiary: darkBlue7,
  surface: darkBlue7, //darkBlue3
  error: darkRed,
  onPrimary: darkWhite,
  onSecondary: white,
  onSurface: darkBlue1,
  onError: darkBlack,
  brightness: Brightness.dark,
);

class SwitchThemeAdaptation extends Adaptation<SwitchThemeData> {
  const SwitchThemeAdaptation();

  @override
  SwitchThemeData adapt(ThemeData theme, SwitchThemeData defaultValue) {
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return defaultValue;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return SwitchThemeData(
          trackColor: WidgetStateProperty.fromMap(
            {
              WidgetState.selected: theme.colorScheme.secondary,
            },
          ),
        );
    }
  }
}
