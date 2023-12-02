import "package:flutter/material.dart";
import 'package:fl_chart/fl_chart.dart';
import '../../../constants/constants.dart';
import '../../../constants/functions.dart';
import '../../../constants/style.dart';
import '../../../model/bank_account.dart';
import '../../../model/category_transaction.dart';

class AccountsPieChart extends StatelessWidget with Functions {
  const AccountsPieChart({
    required this.notifier,
    required this.accounts,
    required this.amounts,
    required this.total,
    Key? key,
  }) : super(key: key);

  final ValueNotifier<int> notifier;
  final List<BankAccount> accounts;
  final Map<int, double> amounts;
  final double total;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ValueListenableBuilder(
        valueListenable: notifier,
        builder: (context, value, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  startDegreeOffset: -90,
                  centerSpaceRadius: 70,
                  sectionsSpace: 0,
                  borderData: FlBorderData(show: false),
                  sections: showingSections(),
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      // expand category when tapped
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        return;
                      }
                      notifier.value =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    },
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  (value != -1)
                      ? Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration:  BoxDecoration(
                            shape: BoxShape.circle,
                            color: accountColorList[accounts[value].color],
                          ),
                          child: Icon(
                            accountIconList[accounts[value].symbol] ??
                                Icons.swap_horiz_rounded,
                            color: Colors.white,
                          ),
                        )
                      : const SizedBox(),
                  Text(
                    (value != -1)
                        ? "${amounts[accounts[value].id]!.toStringAsFixed(2)} €"
                        : "${total.toStringAsFixed(2)} €",
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: ((value != -1 &&
                                    amounts[accounts[value].id]! > 0) ||
                                (value == -1 && total > 0))
                            ? green
                            : red),
                  ),
                  (value != -1)
                      ? Text(accounts[value].name)
                      : const Text("Total"),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(
      amounts.values.length,
      (i) {
        final isTouched = (i == notifier.value);

        final radius = isTouched ? 30.0 : 25.0;
        return PieChartSectionData(
          color: accountColorList[accounts[i].color],
          value: 360 * amounts[accounts[i].id]!,
          radius: radius,
          showTitle: false,
        );
      },
    );
  }
}
