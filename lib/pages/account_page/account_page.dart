import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/functions.dart';
import '../../constants/style.dart';
import '../../custom_widgets/line_chart.dart';
import '../../providers/accounts_provider.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AccountPage();
}

class _AccountPage extends ConsumerState<AccountPage> with Functions {
  @override
  Widget build(BuildContext context) {
    final accountName = ref.read(accountNameProvider);
    final accountAmount = ref.read(accountStartingValueProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(accountName ?? "", style: const TextStyle(color: white)),
        backgroundColor: blue5,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              color: blue5,
              child: Column(
                children: [
                  Text(
                    numToCurrency(accountAmount),
                    style: const TextStyle(
                      color: white,
                      fontSize: 32.0,
                      fontFamily: 'SF Pro Text',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Padding(padding: EdgeInsets.all(8.0)),
                  const LineChartWidget(
                    line1Data: [
                      FlSpot(0, 3),
                      FlSpot(1, 1.3),
                      FlSpot(2, -2),
                      FlSpot(3, -4.5),
                      FlSpot(4, -5),
                      FlSpot(5, -2.2),
                      FlSpot(6, -3.1),
                      FlSpot(7, -0.2),
                      FlSpot(8, -4),
                      FlSpot(9, -3),
                      FlSpot(10, -2),
                      FlSpot(11, -4),
                      FlSpot(12, 3),
                      FlSpot(13, 1.3),
                      FlSpot(14, -2),
                      FlSpot(15, -4.5),
                      FlSpot(16, 2.5),
                    ],
                    colorLine1Data: Color(0xffffffff),
                    line2Data: <FlSpot>[],
                    colorLine2Data: Color(0xffffffff),
                    colorBackground: blue5,
                    maxDays: 30.0,
                  ),
                ],
              ),
            ),
            // TODO: add list of transactions
          ],
        ),
      ),
    );
  }
}
