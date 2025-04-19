// Defines application's structure

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/transactions_provider.dart';
import '../../../shared/ui/device.dart';
import '../../graphs_page/presentation/graphs_page.dart';
import '../../../utils/snack_bars/transactions_snack_bars.dart';
import '../../dashboard_page/presentation/dashboard_page.dart';
import '../../planning_page/presentation/planning_page.dart';
import '../../transactions_page/presentation/transactions_page.dart';
import '../data/duplicated_transactions_provider.dart';
import '../data/selected_index_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
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
  void initState() {
    super.initState();

    ref.listenManual(duplicatedTransactoinProvider, (_, next) {
      showDuplicatedTransactionSnackBar(
        context,
        transaction: next,
        ref: ref,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    return Scaffold(
      // Prevent the fab moving up when the keyboard is opened
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor:
            selectedIndex == 0 ? Theme.of(context).colorScheme.tertiary : null,
        title: Text(
          _pagesTitle.elementAt(selectedIndex),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: Sizes.lg),
          child: FilledButton(
            onPressed: () => Navigator.of(context).pushNamed('/search'),
            style: FilledButton.styleFrom(shape: const CircleBorder()),
            child: Icon(Icons.search),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(Sizes.sm),
            child: FilledButton(
              onPressed: () => Navigator.of(context).pushNamed('/settings'),
              style: FilledButton.styleFrom(shape: const CircleBorder()),
              child: Icon(Icons.settings),
            ),
          ),
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
