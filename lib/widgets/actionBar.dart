// From this widget, the user can access all the main pages of the app by pressing on the IconButtons.
// Modify this file if you want another page to be rendered when an icon is tapped.

import 'package:flutter/material.dart';
import 'package:sossoldi/Pages/home_page.dart';
import 'package:sossoldi/Pages/planning_budget_page.dart';
import 'package:sossoldi/Pages/statistics_page.dart';
import 'package:sossoldi/Pages/movements_page.dart';

class ActionBar extends StatefulWidget {
  @override
  _ActionBarState createState() => _ActionBarState();
}

class _ActionBarState extends State<ActionBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black, width: 3.0))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.business_center),
            onPressed: () {
              // pushrReplacement() deletes the previous view from the Navigtator's stack.
              Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        HomePage(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ));
            },
          ),
          IconButton(
            icon: Icon(Icons.money),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        PlanningPage(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ));
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        MovementsPage(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ));
            },
          ),
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        StatsPage(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ));
            },
          ),
        ],
      ),
    );
  }
}
