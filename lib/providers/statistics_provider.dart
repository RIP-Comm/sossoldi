import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/models/transaction.dart';

final currentYearMontlyTransactionsProvider =
    StateProvider<List<FlSpot>>((ref) => const []);

final statisticsProvider = FutureProvider<void>((ref) async {
  final currentYearMontlyTransaction =
      await TransactionMethods().currentYearMontlyTransactions();

  double runningTotal = 0;
  ref.read(currentYearMontlyTransactionsProvider.notifier).state =
      currentYearMontlyTransaction.map((e) {
    runningTotal += e['income'] - e['expense'];
    return FlSpot(double.parse(e['month'].substring(5)) - 1,
        double.parse(runningTotal.toStringAsFixed(2)));
  }).toList();
});
