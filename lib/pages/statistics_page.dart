// Satistics page.

import 'package:flutter/material.dart';
import '../constants/style.dart';
import '../custom_widgets/line_chart.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsPage extends StatefulWidget {
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  @override
  Widget build(BuildContext context) {
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
          ],
        ),
      ],
    );
  }
}
