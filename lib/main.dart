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

class Launcher extends StatelessWidget {
  const Launcher({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sossoldi',
      theme: ThemeData(
          accentColor: Color.fromRGBO(217, 217, 217, 1),
          textTheme: const TextTheme(
            displayMedium: TextStyle(
                fontSize: 20.0,
                color: Colors.black,
                fontFamily: 'SF Pro Text',
                fontWeight: FontWeight.bold),
            titleMedium: TextStyle(
                fontSize: 32.0,
                fontFamily: 'SF Pro Text',
                fontWeight: FontWeight.bold),
            titleSmall: TextStyle(fontSize: 18.0, fontFamily: 'SF Pro Text'),
            headlineMedium:
                TextStyle(fontSize: 10.0, fontFamily: 'SF Pro Text'),
            headlineSmall: TextStyle(fontSize: 8.0, fontFamily: 'SF Pro Text'),
            labelMedium: TextStyle(
                fontSize: 16.0,
                fontFamily: 'SF Pro Text',
                fontWeight: FontWeight.bold),
            labelSmall: TextStyle(fontSize: 12.0, fontFamily: 'SF Pro Text'),
          )),
      home: const Structure(),
    );
  }
}
