// Defines application's structure

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/transactions_provider.dart';
import '../ui/device.dart';
import 'graphs/graphs_page.dart';
import 'dashboard/dashboard_page.dart';
import 'planning/planning_page.dart';
import 'transactions/transactions_page.dart';

final StateProvider selectedIndexProvider = StateProvider<int>((ref) => 0);

final StateProvider<bool> visibilityAmountProvider =
    StateProvider<bool>((ref) => false);

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
    const DashboardPage(),
    const TransactionsPage(),
    const SizedBox(),
    const PlanningPage(),
    const GraphsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedIndexProvider);

    final isVisible = ref.watch(visibilityAmountProvider);

    return Scaffold(
      // Prevent the fab moving up when the keyboard is opened
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor:
            selectedIndex == 0 ? Theme.of(context).colorScheme.tertiary : null,
        title: switch (selectedIndex) {
          0 => null,
          _ => Text(_pagesTitle.elementAt(selectedIndex))
        },
        leading: Padding(
          padding: const EdgeInsets.only(left: Sizes.lg),
          child: FilledButton(
            onPressed: () => Navigator.of(context).pushNamed('/search'),
            style: FilledButton.styleFrom(shape: const CircleBorder()),
            child: Icon(Icons.search),
          ),
        ),
        actions: [
          switch (selectedIndex) {
            0 => FilledButton(
                onPressed: () {
                  ref.read(visibilityAmountProvider.notifier).state =
                      !isVisible;
                },
                style: FilledButton.styleFrom(shape: const CircleBorder()),
                child:
                    Icon(isVisible ? Icons.visibility : Icons.visibility_off),
              ),
            _ => const SizedBox.shrink(),
          },
          FilledButton(
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
            style: FilledButton.styleFrom(shape: const CircleBorder()),
            child: Icon(Icons.settings),
          ),
          SizedBox.square(dimension: Sizes.xs),
        ],
      ),
      body: Center(
        child: _pages[selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 8,
        unselectedFontSize: 8,
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
        child: Icon(
          Icons.add_rounded,
          size: 55,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        onPressed: () {
          ref.read(transactionsProvider.notifier).reset();
          Navigator.of(context).pushNamed("/add-page");
        },
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
    );
  }
}
