// Defines application's structure

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/style.dart';
import 'add_page/add_page.dart';
import 'home_page.dart';
import 'planning_page/planning_page.dart';
import 'statistics_page.dart';
import 'transactions_page/transactions_page.dart';

final StateProvider selectedIndexProvider = StateProvider<int>((ref) => 0);

class Structure extends ConsumerStatefulWidget {
  const Structure({super.key});

  @override
  ConsumerState<Structure> createState() => _StructureState();
}

class _StructureState extends ConsumerState<Structure> {
  // We could add this List in the app's state, so it isn't intialized every time.
  final List<String> _pagesTitle = [
    "Dashboard",
    "Transactions",
    "",
    "Planning",
    "Graphs",
  ];
  final List<Widget> _pages = [
    const HomePage(),
    const TransactionsPage(),
    const SizedBox(),
    const PlanningPage(),
    const StatsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    return Scaffold(
      // backgroundColor: blue7,
      resizeToAvoidBottomInset:
          false, // Prevent the fab moving up when the keyboard is opened
      appBar: AppBar(
        // Sulla dashboard (0) setto il background blue
        // backgroundColor: selectedIndex == 0 ? blue7 : Theme.of(context).colorScheme.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _pagesTitle.elementAt(selectedIndex),
          style: Theme.of(context).textTheme.headlineLarge!,
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
        child: _pages.elementAt(selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        // unselectedItemColor: grey1,
        selectedFontSize: 8,
        unselectedFontSize: 8,
        // backgroundColor: const Color(0xFFF6F6F6),
        currentIndex: selectedIndex,
        onTap: (index) => index != 2
            ? ref.read(selectedIndexProvider.notifier).state = index
            : null,
        items: [
          BottomNavigationBarItem(
            icon: Icon(selectedIndex == 0 ? Icons.home : Icons.home_outlined),
            label: "DASHBOARD",
          ),
          BottomNavigationBarItem(
            icon: Icon(selectedIndex == 1
                ? Icons.swap_horizontal_circle
                : Icons.swap_horizontal_circle_outlined),
            label: "TRANSACTIONS",
          ),
          const BottomNavigationBarItem(icon: Text(""), label: ""),
          BottomNavigationBarItem(
            icon: Icon(selectedIndex == 3
                ? Icons.calendar_today
                : Icons.calendar_today_outlined),
            label: "PLANNING",
          ),
          BottomNavigationBarItem(
            icon: Icon(selectedIndex == 4
                ? Icons.data_exploration
                : Icons.data_exploration_outlined),
            label: "GRAPHS",
          ),
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
        onPressed: () => Navigator.of(context).pushNamed("/add-page"),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
    );
  }
}
