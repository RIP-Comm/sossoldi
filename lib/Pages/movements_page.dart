// Movements page.

import 'package:flutter/material.dart';
import 'package:sossoldi/widgets/CustomAppBar.dart';
import 'package:sossoldi/widgets/actionBar.dart';

class MovementsPage extends StatefulWidget {
  @override
  _MovementsPageState createState() => _MovementsPageState();
}

class _MovementsPageState extends State<MovementsPage> {
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
                  "Movements Page",
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
