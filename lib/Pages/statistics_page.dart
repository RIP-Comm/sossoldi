// Satistics page.

import 'package:flutter/material.dart';
import 'package:sossoldi/widgets/CustomAppBar.dart';
import 'package:sossoldi/widgets/actionBar.dart';

class StatsPage extends StatefulWidget {
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
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
                  "Statistics Page",
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
