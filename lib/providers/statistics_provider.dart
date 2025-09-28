import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/transaction.dart';
import 'accounts_provider.dart';

final currentYearMontlyTransactionsProvider =
    StateProvider<List<FlSpot>>((ref) => const []);

final statisticsProvider = FutureProvider<void>((ref) async {
  final currentYearMontlyTransaction =
      await TransactionMethods().currentYearMontlyTransactions();

  final accountsAsync = ref.read(accountsProvider);
  final accounts = accountsAsync.value ?? [];
  double currentBalance =
      accounts.fold(0.0, (sum, account) => sum + (account.total ?? 0));

  List<FlSpot> spots = [];
  double runningBalance = currentBalance;

  final reversedTransactions = currentYearMontlyTransaction.reversed.toList();

  for (int i = 0; i < reversedTransactions.length; i++) {
    final monthData = reversedTransactions[i];
    final monthIndex = double.parse(monthData['month'].substring(5)) - 1;

    spots.add(
        FlSpot(monthIndex, double.parse(runningBalance.toStringAsFixed(2))));

    if (i < reversedTransactions.length - 1) {
      runningBalance =
          runningBalance - monthData['income'] + monthData['expense'];
    }
  }

  spots.sort((a, b) => a.x.compareTo(b.x));

  ref.read(currentYearMontlyTransactionsProvider.notifier).state = spots;
});
