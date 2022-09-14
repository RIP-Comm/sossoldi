// Modify this file to adjust theme settings and other global settings.

import 'package:flutter/material.dart';
import 'package:sossoldi/Pages/home_page.dart';
import 'package:sossoldi/widgets/CustomAppBar.dart';
import "package:sossoldi/pages/statistics_page.dart";
import "package:sossoldi/pages/movements_page.dart";
import "package:sossoldi/pages/planning_budget_page.dart";
import "package:sossoldi/pages/settings_page.dart";

void main() {
  runApp(const Launcher());
}

class Launcher extends StatelessWidget {
  const Launcher({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPageState(),
    );
  }
}

class MainPageState extends StatefulWidget {
  @override
  State<MainPageState> createState() => _MainPageState();
}

class _MainPageState extends State<MainPageState> {

  int _index = 0;

  void _setIndex(int index) {
    setState(() {
      _index = index;
    });
  }

  final List<Widget> children = [
    HomePage(),
    MovementsPage(),
    SettingsPage(), //Qua ci andrebbe la pagina di "Add" in sostituzione a settingspage
    PlanningPage(),
    StatsPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      bottomNavigationBar: createBottomNav(),
      body: _index == 2 ? HomePage() : children[_index]
    );
  }

  BottomNavigationBar createBottomNav() {
    return BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money),
            label: 'Planning',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add',
            backgroundColor: Colors.purple
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Movements',
            backgroundColor: Colors.indigo
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
            backgroundColor: Colors.orangeAccent
          ),
        ],
        selectedItemColor: Colors.black,
        currentIndex: _index,
        onTap: _setIndex,
    );
  }

}
