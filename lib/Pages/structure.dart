// Defines application's structure

import 'package:flutter/material.dart';
import 'package:sossoldi/Pages/add_page.dart';
import 'package:sossoldi/Pages/home_page.dart';
import 'package:sossoldi/Pages/movements_page.dart';
import 'package:sossoldi/Pages/planning_budget_page.dart';
import 'package:sossoldi/Pages/settings_page.dart';
import 'package:sossoldi/Pages/statistics_page.dart';

class Structure extends StatefulWidget {
  const Structure({super.key});

  @override
  State<Structure> createState() => _StructureState();
}

class _StructureState extends State<Structure> {
  int _selectedIndex = 0;

  // We could add this List in the app's state, so it isn't intialized every time.
  final List<Widget> _pages = <Widget>[
    HomePage(),
    PlanningPage(),
    const Text("Add"),
    MovementsPage(),
    StatsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Sossoldi"),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          SettingsPage(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ));
              },
              icon: const Icon(Icons.settings),
            )
          ],
        ),
        body: Center(
          child: _pages.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          backgroundColor: Colors.blue,
          currentIndex: _selectedIndex,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.business_center), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.attach_money), label: "Budget"),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: "Add"),
            BottomNavigationBarItem(
                icon: Icon(Icons.arrow_back), label: "Movements"),
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart), label: "Statistics"),
          ],
        ));
  }

  void _onItemTapped(int index) {
    setState(() {
      if (index != 2) {
        _selectedIndex = index;
      } else {
        Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => const AddPage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ));
      }
    });
  }
}
