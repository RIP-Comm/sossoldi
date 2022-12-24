// Home page.

import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:sossoldi/custom_widgets/accounts_sum.dart';
import 'package:sossoldi/custom_widgets/chart_home.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Card(
          color: const Color(0xffF1F5F9),
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.only(top: 8.0),),
              Row(
                children: [
                  const Padding(padding: EdgeInsets.only(left: 8.0),),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "MONTHLY BALANCE",
                        style: TextStyle(
                          color: Color(0xff00152D),
                          fontSize: 12.0,
                          fontFamily: 'SF Pro Text',
                          ),
                        ),
                      Text(
                        "1.536,65€",
                        style: TextStyle(
                          color: Color(0xff00152D),
                          fontSize: 27.0,
                          fontFamily: 'SF Pro Text',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.only(right: 30.0),),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "INCOME",
                        style: TextStyle(
                            color: Color(0xff00152D),
                            fontSize: 10.0,
                            fontFamily: 'SF Pro Text',
                          ),
                        ),
                      Text(
                        "+2620,55€",
                        style: TextStyle(
                            color: Color(0xff248731),
                            fontSize: 16.0,
                            fontFamily: 'SF Pro Text',
                          ),
                        ),
                    ],),
                  const Padding(padding: EdgeInsets.only(right: 30.0),),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "EXPENSES",
                        style: TextStyle(
                            color: Color(0xff00152D),
                            fontSize: 10.0,
                            fontFamily: 'SF Pro Text',
                          ),
                        ),
                      Text(
                        "-1.050,65€",
                        style: TextStyle(
                            color: Color(0xffC52626),
                            fontSize: 16.0,
                            fontFamily: 'SF Pro Text',
                          ),
                        ),
                    ],),
                ],
              ),
              const Padding(padding: EdgeInsets.all(8.0),),
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
                colorLine1Data: Color(0xff00152D),
                line2Data: [
                  FlSpot(0, -3),
                  FlSpot(1, -1.3),
                  FlSpot(2, 2),
                  FlSpot(3, 4.5),
                  FlSpot(4, 5),
                  FlSpot(5, 2.2),
                  FlSpot(6, 3.1),
                  FlSpot(7, 0.2),
                  FlSpot(8, 4),
                  FlSpot(9, 3),
                  FlSpot(10, 2),
                  FlSpot(11, 4),
                  FlSpot(12, -3),
                  FlSpot(13, -1.3),
                  FlSpot(14, 2),
                  FlSpot(15, 4.5),
                  FlSpot(16, 5),
                  FlSpot(17, 2.2),
                  FlSpot(18, 3.1),
                  FlSpot(19, 0.2),
                  FlSpot(20, 4),
                  FlSpot(21, 3),
                  FlSpot(22, 2),
                  FlSpot(23, 4),
                  FlSpot(24, -3),
                  FlSpot(25, -1.3),
                  FlSpot(26, 2),
                  FlSpot(27, 4.5),
                  FlSpot(28, 5),
                  FlSpot(29, 5),
                ],
                colorLine2Data: Color(0xffB9BABC),
                colorBackground: Color(0xffF1F5F9),
              ),
              Row(
                children: <Widget>[
                  const Padding(padding: EdgeInsets.only(left: 8.0),),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xff00152D),
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  const Text(
                    "Spese mese corrente",
                    style: TextStyle(
                      fontSize: 8,
                      color: Color(0xff00152D),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(left: 8.0),),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xffB9BABC),
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  const Text(
                    "Spese mese precedente",
                    style: TextStyle(
                      fontSize: 8,
                      color: Color(0xff00152D),
                    ),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.only(bottom: 9.0),),
            ],
          )
        ),
        Align(
            alignment: Alignment.centerLeft,
            child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  "Your accounts",
                  style: Theme.of(context).textTheme.displayMedium,
                ))),
        const SizedBox(height: 16),
        Container(
          height: 85.0,
          margin: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: ListView.builder(
              itemCount: 5,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, i) {
                return const AccountsSum(
                    accountName: 'Cash', amount: '1.234,56');
              }),
        ),
        const SizedBox(height: 28),
        Align(
            alignment: Alignment.centerLeft,
            child: Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text(
                  "Last transactions",
                  style: Theme.of(context).textTheme.displayMedium,
                ))),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.only(left: 16.0, right: 16.0),
          color: Color.fromRGBO(242, 242, 242, 1),
          child: Padding(
              padding:
                  EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text("Monday 12 september"),
                      const Spacer(),
                      RichText(
                          text: TextSpan(children: [
                        TextSpan(
                            text: "-285,99",
                            style: Theme.of(context).textTheme.labelSmall),
                        TextSpan(
                          text: "€",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.apply(fontFeatures: [FontFeature.subscripts()]),
                        ),
                      ])),
                    ],
                  ),
                  Container(
                      margin: const EdgeInsets.only(top: 8.0),
                      color: Color.fromRGBO(231, 231, 231, 1),
                      height: 220,
                      child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(), // <-- this will disable scroll
                          itemCount: 5,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemBuilder: (context, i) {
                            return ListTile(
                              leading: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color.fromRGBO(217, 217, 217, 1)),
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
                                      Text('Affitto',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium),
                                      const Spacer(),
                                      RichText(
                                          text: TextSpan(children: [
                                        TextSpan(
                                            text: "-280,00",
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall),
                                        TextSpan(
                                          text: "€",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.apply(fontFeatures: [
                                            FontFeature.subscripts()
                                          ]),
                                        ),
                                      ])),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Text('HOME',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium),
                                      const Spacer(),
                                      Text('CASH',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium),
                                    ],
                                  ),
                                  const SizedBox(height: 11),
                                ],
                              ),
                              onTap: () {},
                            );
                          }))
                ],
              )),
        ),
        const SizedBox(height: 28),
        Align(
            alignment: Alignment.centerLeft,
            child: Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text(
                  "Your budgets",
                  style: Theme.of(context).textTheme.displayMedium,
                ))),
        const SizedBox(height: 16),
        Container(
          child: Row(
            children: <Widget>[
              Column(
                children: [
                  CircularPercentIndicator(
                    radius: 50.0,
                    animation: true,
                    animationDuration: 1200,
                    lineWidth: 10.0,
                    percent: 0.25,
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      //Center Row contents horizontally,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      //Center Row contents vertically,
                      children: [
                        RichText(
                            text: TextSpan(children: [
                          TextSpan(
                              text: "320",
                              style: Theme.of(context).textTheme.labelMedium),
                          TextSpan(
                            text: "€",
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.apply(
                                    fontFeatures: [FontFeature.subscripts()]),
                          ),
                        ])),
                        RichText(
                            text: TextSpan(children: [
                          TextSpan(
                              text: "25",
                              style: Theme.of(context).textTheme.labelSmall),
                          TextSpan(
                            text: "%",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.apply(
                                    fontFeatures: [FontFeature.subscripts()]),
                          ),
                        ])),
                      ],
                    ),
                    circularStrokeCap: CircularStrokeCap.butt,
                    backgroundColor: Color.fromRGBO(217, 217, 217, 1),
                    progressColor: Color.fromRGBO(150, 150, 150, 1),
                  ),
                  const SizedBox(height: 10),
                  Text("Totale",
                      style: Theme.of(context).textTheme.labelMedium),
                ],
              ),
              Spacer(),
              Column(
                children: [
                  CircularPercentIndicator(
                    radius: 50.0,
                    animation: true,
                    animationDuration: 1200,
                    lineWidth: 10.0,
                    percent: 0.5,
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      //Center Row contents horizontally,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      //Center Row contents vertically,
                      children: [
                        RichText(
                            text: TextSpan(children: [
                          TextSpan(
                              text: "500",
                              style: Theme.of(context).textTheme.labelMedium),
                          TextSpan(
                            text: "€",
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.apply(
                                    fontFeatures: [FontFeature.subscripts()]),
                          ),
                        ])),
                        RichText(
                            text: TextSpan(children: [
                          TextSpan(
                              text: "50",
                              style: Theme.of(context).textTheme.labelSmall),
                          TextSpan(
                            text: "%",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.apply(
                                    fontFeatures: [FontFeature.subscripts()]),
                          ),
                        ])),
                      ],
                    ),
                    circularStrokeCap: CircularStrokeCap.butt,
                    backgroundColor: Color.fromRGBO(217, 217, 217, 1),
                    progressColor: Color.fromRGBO(150, 150, 150, 1),
                  ),
                  const SizedBox(height: 10),
                  Text("Spese", style: Theme.of(context).textTheme.labelMedium),
                ],
              ),
              Spacer(),
              Column(
                children: [
                  CircularPercentIndicator(
                    radius: 50.0,
                    animation: true,
                    animationDuration: 1200,
                    lineWidth: 10.0,
                    percent: 0.88,
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      //Center Row contents horizontally,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      //Center Row contents vertically,
                      children: [
                        RichText(
                            text: TextSpan(children: [
                          TextSpan(
                              text: "178,67",
                              style: Theme.of(context).textTheme.labelMedium),
                          TextSpan(
                            text: "€",
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.apply(
                                    fontFeatures: [FontFeature.subscripts()]),
                          ),
                        ])),
                        RichText(
                            text: TextSpan(children: [
                          TextSpan(
                              text: "88%",
                              style: Theme.of(context).textTheme.labelSmall),
                          TextSpan(
                            text: "%",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.apply(
                                    fontFeatures: [FontFeature.subscripts()]),
                          ),
                        ])),
                      ],
                    ),
                    circularStrokeCap: CircularStrokeCap.butt,
                    backgroundColor: Color.fromRGBO(217, 217, 217, 1),
                    progressColor: Color.fromRGBO(150, 150, 150, 1),
                  ),
                  const SizedBox(height: 10),
                  Text("Svago", style: Theme.of(context).textTheme.labelMedium),
                ],
              ),
            ],
          ),
          margin: const EdgeInsets.only(left: 16.0, right: 16.0),
        ),
        const SizedBox(height: 50),
      ],
    );
  }
}