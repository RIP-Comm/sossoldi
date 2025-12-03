import 'package:fl_chart/fl_chart.dart';
import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/constants.dart';
import '../../../constants/style.dart';
import '../../../ui/widgets/rounded_icon.dart';
import '../../../model/bank_account.dart';
import '../../../providers/currency_provider.dart';
import '../../../ui/device.dart';
import '../../../ui/widgets/transaction_type_button.dart';

class AccountsPieChart extends ConsumerWidget {
  const AccountsPieChart({
    required this.accounts,
    required this.amounts,
    required this.total,
    super.key,
  });

  final List<BankAccount> accounts;
  final Map<int, double> amounts;
  final double total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedListIndexProvider);
    final currencyState = ref.watch(currencyStateNotifier);
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              startDegreeOffset: -90,
              centerSpaceRadius: 70,
              sectionsSpace: 0,
              borderData: FlBorderData(show: false),
              sections: showingSections(selectedIndex),
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  // expand category when tapped
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    return;
                  }
                  ref.read(selectedListIndexProvider.notifier).state =
                      pieTouchResponse.touchedSection!.touchedSectionIndex;
                },
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selectedIndex != -1)
                RoundedIcon(
                  icon:
                      accountIconList[accounts[selectedIndex].symbol] ??
                      Icons.swap_horiz_rounded,
                  backgroundColor:
                      accountColorList[accounts[selectedIndex].color],
                  padding: const EdgeInsets.all(Sizes.sm),
                ),
              Text(
                (selectedIndex != -1)
                    ? "${amounts[accounts[selectedIndex].id]!.toStringAsFixed(2)} ${currencyState.selectedCurrency.symbol}"
                    : "${total.toStringAsFixed(2)} ${currencyState.selectedCurrency.symbol}",
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color:
                      ((selectedIndex != -1 &&
                              amounts[accounts[selectedIndex].id]! > 0) ||
                          (selectedIndex == -1 && total > 0))
                      ? green
                      : red,
                ),
              ),
              (selectedIndex != -1)
                  ? Text(accounts[selectedIndex].name)
                  : const Text("Total"),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections(int index) {
    return List.generate(amounts.values.length, (i) {
      final isTouched = (i == index);

      final radius = isTouched ? 30.0 : 25.0;
      return PieChartSectionData(
        color: accountColorList[accounts[i].color],
        value: 360 * amounts[accounts[i].id]!,
        radius: radius,
        showTitle: false,
      );
    });
  }
}
