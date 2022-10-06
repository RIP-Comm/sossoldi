// Planning page.

import 'package:flutter/material.dart';

class PlanningPage extends StatefulWidget {
  @override
  _PlanningPageState createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Planning Page",
          style: Theme.of(context).textTheme.headline4,
        ),
      ),
    );
  }
}
