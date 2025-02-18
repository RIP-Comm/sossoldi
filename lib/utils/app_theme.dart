import 'package:flutter/material.dart';

import '../constants/style.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    colorScheme: customColorScheme,
    scaffoldBackgroundColor: white,
    useMaterial3: false,
    appBarTheme: const AppBarTheme(
      color: white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: blue5),
      titleTextStyle: TextStyle(
        color: blue1,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: grey3,
      unselectedItemColor: grey1,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: blue5,
    ),
    tabBarTheme: TabBarTheme(
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: blue5,
      ),
      labelColor: white,
      unselectedLabelColor: blue5,
    ),
    iconTheme: const IconThemeData(
      color: blue1,
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.all(16)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        textStyle: WidgetStatePropertyAll(
          TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w700,
            color: white,
          ),
        ),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      tileColor: grey3,
      contentPadding: EdgeInsets.all(16),
    ),
    disabledColor: grey2,
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
    ),
  );

  static final darkTheme = ThemeData(
    colorScheme: darkCustomColorScheme,
    scaffoldBackgroundColor: darkGrey4,
    useMaterial3: false,
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
      selectedItemColor: darkBlue1,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: darkBlue1,
    ),
    tabBarTheme: TabBarTheme(
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: darkBlue5,
      ),
      labelColor: white,
      unselectedLabelColor: grey2,
    ),
    iconTheme: const IconThemeData(
      color: darkBlue1,
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        textStyle: WidgetStatePropertyAll(
          TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w700,
            color: white,
          ),
        ),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      tileColor: darkBlue7,
      contentPadding: EdgeInsets.all(16),
    ),

    disabledColor: darkGrey2,
    //Text style
    fontFamily: 'SF Pro Text',
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
  onSecondary: darkWhite,
  onSurface: darkBlue1,
  onError: darkBlack,
  brightness: Brightness.dark,
);
