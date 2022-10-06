// Movements page.

import 'package:flutter/material.dart';

class MovementsPage extends StatefulWidget {
  @override
  _MovementsPageState createState() => _MovementsPageState();
}

class _MovementsPageState extends State<MovementsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Movements Page",
          style: Theme.of(context).textTheme.headline4,
        ),
      ),
    );
  }
}
