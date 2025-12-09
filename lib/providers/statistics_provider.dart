import 'package:fl_chart/fl_chart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/database/repositories/transactions_repository.dart';
import 'accounts_provider.dart';

part 'statistics_provider.g.dart';

@Riverpod(keepAlive: true)
class HighlightedMonth extends _$HighlightedMonth {
  @override
  int build() => DateTime.now().month - 1;

  void setValue(int value) => state = value;
}

@Riverpod(keepAlive: true)
class CurrentYearMontlyTransactions extends _$CurrentYearMontlyTransactions {
  @override
  List<FlSpot> build() => const [];

  void setValue(List<FlSpot> value) => state = value;
}

@Riverpod(keepAlive: true)
class Statistics extends _$Statistics {
  @override
  Future<void> build() async {
    await updateStatistics();
  }

  Future<void> updateStatistics() async {
    final currentYearMontlyTransaction = await ref
        .read(transactionsRepositoryProvider)
        .currentYearMontlyTransactions();

    final accountsAsync = ref.read(accountsProvider);
    final accounts = accountsAsync.value ?? [];
    double currentBalance = accounts.fold(
      0.0,
      (sum, account) => sum + (account.total ?? 0),
    );

    List<FlSpot> spots = [];
    double runningBalance = currentBalance;

    final reversedTransactions = currentYearMontlyTransaction.reversed.toList();

    for (int i = 0; i < reversedTransactions.length; i++) {
      final monthData = reversedTransactions[i];
      final monthIndex = double.parse(monthData['month'].substring(5)) - 1;

      spots.add(
        FlSpot(monthIndex, double.parse(runningBalance.toStringAsFixed(2))),
      );

      if (i < reversedTransactions.length - 1) {
        runningBalance =
            runningBalance - monthData['income'] + monthData['expense'];
      }
    }

    spots.sort((a, b) => a.x.compareTo(b.x));

    ref.read(currentYearMontlyTransactionsProvider.notifier).setValue(spots);
  }
}
