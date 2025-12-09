import 'package:fl_chart/fl_chart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/database/repositories/transactions_repository.dart';

part 'dashboard_provider.g.dart';

@Riverpod(keepAlive: true)
class Income extends _$Income {
  @override
  num build() => 0;

  void setValue(num value) => state = value;
}

@Riverpod(keepAlive: true)
class Expense extends _$Expense {
  @override
  num build() => 0;

  void setValue(num value) => state = value;
}

@Riverpod(keepAlive: true)
class CurrentMonthList extends _$CurrentMonthList {
  @override
  List<FlSpot> build() => [];

  void setValue(List<FlSpot> value) => state = value;
}

@Riverpod(keepAlive: true)
class LastMonthList extends _$CurrentMonthList {
  @override
  List<FlSpot> build() => [];

  void setValue(List<FlSpot> value) => state = value;
}

@riverpod
Future<void> dashboard(Ref ref) async {
  final currentMonth = await ref
      .read(transactionsRepositoryProvider)
      .currentMonthDailyTransactions();
  final lastMonth = await ref
      .read(transactionsRepositoryProvider)
      .lastMonthDailyTransactions();
  ref
      .read(incomeProvider.notifier)
      .setValue(
        currentMonth.fold(
          0,
          (previousValue, element) => previousValue + element['income'],
        ),
      );
  ref
      .read(expenseProvider.notifier)
      .setValue(
        currentMonth.fold(
          0,
          (previousValue, element) => previousValue - element['expense'],
        ),
      );

  double runningTotal = 0;
  ref
      .read(currentMonthListProvider.notifier)
      .setValue(
        currentMonth.map((e) {
          runningTotal += e['income'] - e['expense'];
          return FlSpot(
            double.parse(e['day'].substring(8)) - 1,
            double.parse(runningTotal.toStringAsFixed(2)),
          );
        }).toList(),
      );

  runningTotal = 0; // Reset the running total for the next calculation

  ref
      .read(lastMonthListProvider.notifier)
      .setValue(
        lastMonth.map((e) {
          runningTotal += e['income'] - e['expense'];
          return FlSpot(
            double.parse(e['day'].substring(8)) - 1,
            double.parse(runningTotal.toStringAsFixed(2)),
          );
        }).toList(),
      );
}
