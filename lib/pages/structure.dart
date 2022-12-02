// Defines application's structure

import 'package:flutter/material.dart';
import 'package:sossoldi/pages/add_page.dart';
import 'package:sossoldi/pages/home_page.dart';
import 'package:sossoldi/pages/movements_page/movements_page.dart';
import 'package:sossoldi/pages/planning_budget_page.dart';
import 'package:sossoldi/pages/settings_page.dart';
import 'package:sossoldi/pages/statistics_page.dart';

// database
import 'package:sossoldi/database/sossoldi_database.dart';
import 'package:sossoldi/model/example.dart';
import 'package:circular_menu/circular_menu.dart';

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
    MovementsPage(),
    AddPage(),
    PlanningPage(),
    StatsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(204, 204, 204, 1),
        centerTitle: true,
        title: Text(
          "DASHBOARD",
          style: Theme.of(context).textTheme.displayMedium,
        ),
        leading: IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {}),
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
        backgroundColor: const Color.fromRGBO(204, 204, 204, 1),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.business_center), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.attach_money), label: "Transaction"),
          BottomNavigationBarItem(icon: Text(""), label: ""),
          BottomNavigationBarItem(
              icon: Icon(Icons.arrow_back), label: "Planning"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Graphs"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          elevation: 0,
          highlightElevation: 0,
          backgroundColor: const Color.fromRGBO(179, 179, 179, 1),
          child: const Icon(
            Icons.add,
            size: 55,
            color: Color.fromRGBO(93, 93, 93, 1),
          ),
          onPressed: () {
            Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => AddPage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ));
          }),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      if (index != 2) {
        _selectedIndex = index;
      }
    });
  }
}
