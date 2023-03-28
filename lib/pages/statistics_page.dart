// Satistics page.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/functions.dart';
import '../constants/style.dart';
import '../custom_widgets/accounts_sum.dart';
import '../custom_widgets/line_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import '../custom_widgets/bar_chart/bar_chart.dart';
import '../model/bank_account.dart';
import '../providers/accounts_provider.dart';

class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage> with Functions {

  @override
  Widget build(BuildContext context) {
    final accountList = ref.watch(accountsProvider);
    return ListView(
      children: [
        Column(
          children: [
            const Padding(padding: EdgeInsets.only(top: 24)),
            Row(
              children: [
                const Padding(padding: EdgeInsets.only(left: 8.0)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Available liquidity",
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            ),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.only(right: 120.0)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RichText(
                      textScaleFactor: MediaQuery.of(context).textScaleFactor,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "10.635",
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: blue4),
                          ),
                          TextSpan(
                            text: "€",
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: blue4)
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      textScaleFactor: MediaQuery.of(context).textScaleFactor,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "+6%",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: green, fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text: " VS last month",
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w300),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
            ),
            const LineChartWidget(
              line1Data: [
                FlSpot(0, 1),
                FlSpot(1, 1.3),
                FlSpot(2, 1.1),
                FlSpot(3, 1.7),
                FlSpot(4, 2.2),
                FlSpot(5, 2.2),
                FlSpot(6, 3.1),
                FlSpot(7, 4.2),
              ],
              colorLine1Data: Color(0xff00152D),
              line2Data: <FlSpot>[],
              colorLine2Data: Color(0xffB9BABC),
              colorBackground: Color(0xffF1F5F9),
              maxY: 5.0,
              minY: -5.0,
              maxDays: 12.0,
            ),
            Card(
              child: SizedBox(
                height: 86.0,
                child: accountList.when(
                  data: (accounts) => ListView.builder(
                    itemCount: accounts.length,
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, i) {
                      if (i == accounts.length) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [defaultShadow],
                            ),
                          ),
                        );
                      } else {
                        BankAccount account = accounts[i];
                        return SizedBox(
                          height: 20.0,
                          child: Row(
                            children: [
                              Text(account.name),
                              Expanded(
                                child: Text(
                                  account.value.toString(),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          )
                        );
                      }
                    },
                  ),
                  loading: () => const SizedBox(),
                  error: (err, stack) => Text('Error: $err'),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}
