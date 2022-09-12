// Planning page.

import 'package:flutter/material.dart';
import 'package:sossoldi/widgets/CustomAppBar.dart';
import 'package:sossoldi/widgets/actionBar.dart';

class PlanningPage extends StatefulWidget {
  @override
  _PlanningPageState createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              // Replace Center() and put the ListView here
              child: Center(
                child: Text(
                  "Planning Page",
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
            ),
            ActionBar()
          ],
        ),
      ),
    );
  }
}
