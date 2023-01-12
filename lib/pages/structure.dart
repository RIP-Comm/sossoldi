// Defines application's structure

import 'package:flutter/material.dart';
import '../constants/style.dart';
import '../pages/add_page.dart';
import '../pages/home_page.dart';
import '../pages/transactions_page/transactions_page.dart';
import '../pages/planning_budget_page.dart';
import '../pages/settings_page.dart';
import '../pages/statistics_page.dart';

class Structure extends StatefulWidget {
  const Structure({super.key});

  @override
  State<Structure> createState() => _StructureState();
}

class _StructureState extends State<Structure> {
  int _selectedIndex = 0;

  // We could add this List in the app's state, so it isn't intialized every time.
  final List<String> _pagesTitle = [
    "Dashboard",
    "Transactions",
    "",
    "Planning",
    "Graphs",
  ];
  final List<Widget> _pages = <Widget>[
    HomePage(),
    TransactionsPage(),
    const SizedBox(),
    PlanningPage(),
    StatsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blue7,
      appBar: AppBar(
        // Sulla dashboard (0) setto il background blue
        backgroundColor: _selectedIndex == 0 ? blue7 : Theme.of(context).colorScheme.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _pagesTitle.elementAt(_selectedIndex),
          style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(8),
              backgroundColor: Theme.of(context).colorScheme.primary,
              // foregroundColor: Colors.red, // <-- Splash color
            ),
            child: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/settings'),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(8),
                backgroundColor: Theme.of(context).colorScheme.primary,
                // foregroundColor: Colors.red, // <-- Splash color
              ),
              child: Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
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
          BottomNavigationBarItem(icon: Icon(Icons.business_center), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: "Transaction"),
          BottomNavigationBarItem(icon: Text(""), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.arrow_back), label: "Planning"),
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
        onPressed: () => Navigator.of(context).pushNamed('/add'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
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
