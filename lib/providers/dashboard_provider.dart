import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/transaction.dart';

final incomeProvider = StateProvider<num>((ref) => 0);
final expenseProvider = StateProvider<num>((ref) => 0);
final currentMonthListProvider = StateProvider<List<FlSpot>>((ref) => const []);
final lastMonthListProvider = StateProvider<List<FlSpot>>((ref) => const []);

final dashboardProvider = FutureProvider<void>((ref) async {
  final currentMonth = await TransactionMethods().currentMonthDailyTransactions();
  final lastMonth = await TransactionMethods().lastMonthDailyTransactions();

  ref.read(incomeProvider.notifier).state =
      currentMonth.fold(0, (previousValue, element) => previousValue + element['income']);
  ref.read(expenseProvider.notifier).state =
      currentMonth.fold(0, (previousValue, element) => previousValue - element['expense']);

  double runningTotal = 0;
  ref.read(currentMonthListProvider.notifier).state = currentMonth.map((e) {
    runningTotal += e['income'] - e['expense'];
    return FlSpot(double.parse(e['day'].substring(8)) - 1, double.parse(runningTotal.toStringAsFixed(2)));
  }).toList();

  runningTotal = 0; // Reset the running total for the next calculation

  ref.read(lastMonthListProvider.notifier).state = lastMonth.map((e) {
    runningTotal += e['income'] - e['expense'];
    return FlSpot(double.parse(e['day'].substring(8)) - 1, double.parse(runningTotal.toStringAsFixed(2)));
  }).toList();
});
