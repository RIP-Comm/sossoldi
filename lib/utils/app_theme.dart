import 'package:flutter/material.dart';

import '../constants/style.dart';

class AppTheme {
  static final lightTheme = ThemeData(
      colorScheme: customColorScheme,
      scaffoldBackgroundColor: blue7,
      appBarTheme: const AppBarTheme(
        color: grey3,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: blue5),
        titleTextStyle: TextStyle(
          color: blue1,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: blue7,
        unselectedItemColor: grey1,
      ),
      iconTheme: const IconThemeData(
        color: blue1,
      ),
      fontFamily: 'SF Pro Text',
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
      ));

  static final darkTheme = ThemeData(
    colorScheme: darkCustomColorScheme,
    scaffoldBackgroundColor: darkBlue7,
    appBarTheme: const AppBarTheme(
      color: darkGrey3,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: darkBlue5),
      titleTextStyle: TextStyle(
        color: darkBlue1,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkBlue7,
      unselectedItemColor: darkGrey1,
    ),

    tabBarTheme: const TabBarTheme(indicator: BoxDecoration(color: darkBlue5)),

    iconTheme: const IconThemeData(
      color: darkBlue1,
    ),

    //Text style
    fontFamily: 'SF Pro Text',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontSize: 34.0, fontWeight: FontWeight.w700, color: darkBlack),
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
  );
}

ColorScheme customColorScheme = const ColorScheme(
  primary: blue1,
  primaryContainer: white,
  secondary: blue5,
  secondaryContainer: Colors.white70,
  tertiary: blue4,
  surface: grey3,
  background: white,
  error: red,
  onPrimary: white,
  onSecondary: white,
  onSurface: blue1,
  onBackground: blue1,
  onError: black,
  onTertiaryContainer: grey3,
  outline: grey1,
  brightness: Brightness.light,
);

ColorScheme darkCustomColorScheme = const ColorScheme(
  primary: darkBlue1,
  primaryContainer: darkGrey4,
  secondary: darkBlue5,
  secondaryContainer: darkGrey1,
  tertiary: darkBlack,
  surface: darkBlue7, //darkBlue3
  background: darkWhite,
  error: darkRed,
  onPrimary: darkWhite,
  onSecondary: darkWhite,
  onBackground: darkBlue1,
  onSurface: darkBlue1,
  onError: darkBlack,
  onTertiaryContainer: grey3,
  outline: darkGrey1,
  brightness: Brightness.dark,
);
