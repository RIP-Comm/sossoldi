// Modify this file to adjust theme settings and other global settings.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sossoldi/pages/structure.dart';

// sqflite
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

// database
import 'package:sossoldi/database/sossoldi_database.dart';
import 'package:sossoldi/model/example.dart';

import 'constants/style.dart';

void main() {
  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
  }
  // Change the default factory. On iOS/Android, if not using `sqlite_flutter_lib` you can forget
  // this step, it will use the sqlite version available on the system.
  databaseFactory = databaseFactoryFfi;

  runApp(const Launcher());
}

ColorScheme customColorScheme = const ColorScheme(
  primary: blue1,
  secondary: blue5,
  surface: grey3,
  background: white,
  error: red,
  onPrimary: white,
  onSecondary: white,
  onSurface: blue1,
  onBackground: blue1,
  onError: black,
  brightness: Brightness.light,
);

ThemeData customThemeData = ThemeData(
  colorScheme: customColorScheme,
  backgroundColor: const Color(0xFFFFFFFF),
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

class Launcher extends StatelessWidget {
  const Launcher({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sossoldi',
      theme: customThemeData,
      home: const Structure(),
    );
  }
}
