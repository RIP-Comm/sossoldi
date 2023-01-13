// Defines application's structure

import 'package:flutter/material.dart';
import '../constants/style.dart';
import '../pages/add_page.dart';
import '../pages/home_page.dart';
import '../pages/transactions_page/transactions_page.dart';
import '../pages/planning_budget_page.dart';
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
    const HomePage(),
    TransactionsPage(),
    const SizedBox(),
    PlanningPage(),
    StatsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blue7,
      resizeToAvoidBottomInset: false, // Prevent the fab moving up when the keyboard is opened
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
            ),
            child: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.background,
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
              ),
              child: Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.background,
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
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: grey1,
        selectedFontSize: 8,
        unselectedFontSize: 8,
        backgroundColor: const Color(0xFFF6F6F6),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(_selectedIndex == 0 ? Icons.home : Icons.home_outlined), label: "DASHBOARD"),
          BottomNavigationBarItem(icon: Icon(_selectedIndex == 1 ? Icons.swap_horizontal_circle : Icons.swap_horizontal_circle_outlined), label: "TRANSACTIONS"),
          const BottomNavigationBarItem(icon: Text(""), label: ""),
          BottomNavigationBarItem(icon: Icon(_selectedIndex == 3 ? Icons.calendar_today : Icons.calendar_today_outlined), label: "PLANNING"),
          BottomNavigationBarItem(icon: Icon(_selectedIndex == 4 ? Icons.data_exploration : Icons.data_exploration_outlined), label: "GRAPHS"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 4,
        highlightElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: Icon(
          Icons.add_rounded,
          size: 55,
          color: Theme.of(context).colorScheme.background,
        ),
        onPressed: () {
          showModalBottomSheet(
            backgroundColor: Colors.transparent,
            context: context,
            isScrollControlled: true,
            isDismissible: true,
            builder: (BuildContext buildContext) {
              return DraggableScrollableSheet(
                builder: (_, controller) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Theme.of(context).colorScheme.background,
                  ),
                  child: SingleChildScrollView(controller: controller, child: AddPage(controller: controller)),
                ),
                initialChildSize: 0.92,
                minChildSize: 0.92,
                maxChildSize: 1,
              );
            },
          );
        },
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
