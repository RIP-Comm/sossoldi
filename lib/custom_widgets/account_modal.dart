import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../constants/functions.dart';
import 'line_chart.dart';

class AccountDialog extends StatelessWidget with Functions {
  final String accountName;
  final num amount;

  const AccountDialog({super.key, required this.accountName, required this.amount});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            color: const Color(0xff356CA3),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 12.0),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          accountName,
                          style: const TextStyle(
                            color: Color(0xffffffff),
                            fontSize: 18.0,
                            fontFamily: 'SF Pro Text',
                          ),
                        ),
                        const Padding(padding: EdgeInsets.all(12)),
                        Text(
                          numToCurrency(amount),
                          style: const TextStyle(
                            color: Color(0xffffffff),
                            fontSize: 32.0,
                            fontFamily: 'SF Pro Text',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 30.0),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                ),
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
                  colorBackground: Color(0xff356CA3),
                  maxY: 5.0,
                  minY: -5.0,
                  maxDays: 30.0,
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 14.0),
                ),
              ],
            ),
          ),
          Card(
            color: const Color(0xffffffff),
            child: Container(
              margin: const EdgeInsets.only(left: 16.0, right: 16.0),
              color: const Color.fromRGBO(242, 242, 242, 1),
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text("Monday 12 september"),
                        const Spacer(),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                  text: "-285,99", style: Theme.of(context).textTheme.labelSmall),
                              TextSpan(
                                text: "€",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.apply(fontFeatures: [const FontFeature.subscripts()]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 8.0),
                      color: const Color.fromRGBO(231, 231, 231, 1),
                      height: 220,
                      child: ListView.builder(
                        physics:
                            const NeverScrollableScrollPhysics(), // <-- this will disable scroll
                        itemCount: 5,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemBuilder: (context, i) {
                          return ListTile(
                            leading: Container(
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: Color.fromRGBO(217, 217, 217, 1)),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.settings, size: 25.0),
                              ),
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 11),
                                Row(
                                  children: [
                                    Text('Affitto', style: Theme.of(context).textTheme.labelMedium),
                                    const Spacer(),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                              text: "-280,00",
                                              style: Theme.of(context).textTheme.labelSmall),
                                          TextSpan(
                                            text: "€",
                                            style: Theme.of(context).textTheme.headlineSmall?.apply(
                                              fontFeatures: [const FontFeature.subscripts()],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      'HOME',
                                      style: Theme.of(context).textTheme.headlineMedium,
                                    ),
                                    const Spacer(),
                                    Text(
                                      'CASH',
                                      style: Theme.of(context).textTheme.headlineMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 11),
                              ],
                            ),
                            onTap: () {},
                          );
                        },
                      ),
                    ),
                    //Container da togliere
                    Container(
                      margin: const EdgeInsets.only(top: 8.0),
                      color: const Color.fromRGBO(231, 231, 231, 1),
                      height: 220,
                      child: ListView.builder(
                        physics:
                            const NeverScrollableScrollPhysics(), // <-- this will disable scroll
                        itemCount: 5,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemBuilder: (context, i) {
                          return ListTile(
                            leading: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromRGBO(217, 217, 217, 1),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.settings, size: 25.0),
                              ),
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 11),
                                Row(
                                  children: [
                                    Text(
                                      'Affitto',
                                      style: Theme.of(context).textTheme.labelMedium,
                                    ),
                                    const Spacer(),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "-280,00",
                                            style: Theme.of(context).textTheme.labelSmall,
                                          ),
                                          TextSpan(
                                            text: "€",
                                            style: Theme.of(context).textTheme.headlineSmall?.apply(
                                              fontFeatures: [const FontFeature.subscripts()],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      'HOME',
                                      style: Theme.of(context).textTheme.headlineMedium,
                                    ),
                                    const Spacer(),
                                    Text(
                                      'CASH',
                                      style: Theme.of(context).textTheme.headlineMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 11),
                              ],
                            ),
                            onTap: () {},
                          );
                        },
                      ),
                    ),
                    //fine
                    //Container da togliere
                    Container(
                      margin: const EdgeInsets.only(top: 8.0),
                      color: const Color.fromRGBO(231, 231, 231, 1),
                      height: 220,
                      child: ListView.builder(
                        physics:
                            const NeverScrollableScrollPhysics(), // <-- this will disable scroll
                        itemCount: 5,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemBuilder: (context, i) {
                          return ListTile(
                            leading: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromRGBO(217, 217, 217, 1),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.settings, size: 25.0),
                              ),
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 11),
                                Row(
                                  children: [
                                    Text(
                                      'Affitto',
                                      style: Theme.of(context).textTheme.labelMedium,
                                    ),
                                    const Spacer(),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "-280,00",
                                            style: Theme.of(context).textTheme.labelSmall,
                                          ),
                                          TextSpan(
                                            text: "€",
                                            style: Theme.of(context).textTheme.headlineSmall?.apply(
                                              fontFeatures: [const FontFeature.subscripts()],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      'HOME',
                                      style: Theme.of(context).textTheme.headlineMedium,
                                    ),
                                    const Spacer(),
                                    Text(
                                      'CASH',
                                      style: Theme.of(context).textTheme.headlineMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 11),
                              ],
                            ),
                            onTap: () {},
                          );
                        },
                      ),
                    )
                    //fine
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
