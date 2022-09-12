// Modify this file to adjust theme settings and other global settings.

import 'package:flutter/material.dart';
import 'package:sossoldi/Pages/home_page.dart';
import 'package:sossoldi/widgets/actionBar.dart';

void main() {
  runApp(const Launcher());
}

class Launcher extends StatelessWidget {
  const Launcher({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
