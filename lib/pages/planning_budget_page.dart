// Planning page.

import 'dart:ui';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/material.dart';

import '../model/budget.dart';

class PlanningPage extends StatefulWidget {
  @override
  _PlanningPageState createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage> {
  // Static categoies
  final List<Budget> categories = <Budget>[
    Budget(
      name: 'Risparmi',
      amountLimit: 300,
    ),
    Budget(
      name: 'Spese',
      amountLimit: 200,
    ),
    Budget(
      name: 'Svago',
      amountLimit: 250,
    ),
    Budget(
      name: 'Casa',
      amountLimit: 200,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
            padding: const EdgeInsets.only(left: 16, right: 16),
            children: <Widget>[
          const SizedBox(height: 32),
          Text(
            "Budget",
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 16),
          Container(
            color: const Color.fromRGBO(242, 242, 242, 1),
            child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    CircularPercentIndicator(
                      radius: 80.0,
                      animation: true,
                      animationDuration: 1200,
                      lineWidth: 10.0,
                      percent: 0.88,
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          RichText(
                              text: TextSpan(children: [
                            TextSpan(
                                text: "960",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'SF Pro Text')),
                            TextSpan(
                              text: "€",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.apply(
                                      fontFeatures: [FontFeature.subscripts()]),
                            ),
                          ])),
                          const SizedBox(height: 8),
                          Text("Monthly Budget",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelSmall),
                        ],
                      ),
                      circularStrokeCap: CircularStrokeCap.butt,
                      backgroundColor: Color.fromRGBO(217, 217, 217, 1),
                      progressColor: Color.fromRGBO(150, 150, 150, 1),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: categories.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                              margin: const EdgeInsets.only(top: 16.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    color: Color.fromRGBO(140, 140, 140, 1),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(categories[index].name,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16.0,
                                          fontFamily: 'SF Pro Text')),
                                  const SizedBox(width: 8),
                                  RichText(
                                      text: TextSpan(children: [
                                    TextSpan(
                                        text: "23",
                                        // temporary value                                      .toString(),
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12.0,
                                            fontFamily: 'SF Pro Text')),
                                    TextSpan(
                                      text: "%",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12.0,
                                          fontFamily: 'SF Pro Text',
                                          fontFeatures: [
                                            const FontFeature.subscripts()
                                          ]),
                                    ),
                                  ])),
                                  const SizedBox(width: 5),
                                  Expanded(
                                      child: Text(
                                    " _ " * 100,
                                    maxLines: 1,
                                    overflow: TextOverflow.clip,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 5.0,
                                        fontFamily: 'SF Pro Text',
                                        fontFeatures: [
                                          const FontFeature.subscripts()
                                        ]),
                                  )),
                                  const SizedBox(width: 5),
                                  RichText(
                                      text: TextSpan(children: [
                                    TextSpan(
                                        text: categories[index]
                                            .amountLimit
                                            .toString(),
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16.0,
                                            fontFamily: 'SF Pro Text')),
                                    TextSpan(
                                      text: "€",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 8.0,
                                          fontFamily: 'SF Pro Text',
                                          fontFeatures: [
                                            const FontFeature.subscripts()
                                          ]),
                                    ),
                                  ])),
                                ],
                              ));
                        }),
                  ],
                )),
          ),
          Container(
            margin: const EdgeInsets.only(top: 16.0),
            height: 96,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      margin: index != categories.length - 1
                          ? const EdgeInsets.only(right: 16.0)
                          : const EdgeInsets.only(),
                      color: const Color.fromRGBO(242, 242, 242, 1),
                      child: Padding(
                        padding: EdgeInsets.only(right: 8.0, left: 8.0),
                        child: Row(
                          children: [
                            CircularPercentIndicator(
                              radius: 40.0,
                              animation: true,
                              animationDuration: 1200,
                              lineWidth: 12.0,
                              percent: 0.23,
                              center: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  RichText(
                                      text: TextSpan(children: [
                                    TextSpan(
                                        text: "23",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18.0,
                                            fontFamily: 'SF Pro Text',
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(
                                      text: "%",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 8.0,
                                          fontFamily: 'SF Pro Text',
                                          fontFeatures: [
                                            const FontFeature.subscripts()
                                          ]),
                                    ),
                                  ])),
                                ],
                              ),
                              circularStrokeCap: CircularStrokeCap.butt,
                              backgroundColor: Color.fromRGBO(217, 217, 217, 1),
                              progressColor: Color.fromRGBO(150, 150, 150, 1),
                            ),
                            const SizedBox(width: 6),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(categories[index].name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontFamily: 'SF Pro Text')),
                                const SizedBox(height: 12),
                                RichText(
                                    text: TextSpan(children: [
                                  TextSpan(
                                      text: "233",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'SF Pro Text')),
                                  TextSpan(
                                      text: "/" +
                                          categories[index]
                                              .amountLimit
                                              .toString(),
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14.0,
                                          fontFamily: 'SF Pro Text')),
                                  TextSpan(
                                    text: "€",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 8.0,
                                        fontFamily: 'SF Pro Text',
                                        fontFeatures: [
                                          const FontFeature.subscripts()
                                        ]),
                                  ),
                                ])),
                              ],
                            )
                          ],
                        ),
                      ));
                }),
          ),
          const SizedBox(height: 32),
          Text("Planned payments",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'SF Pro Text',
              )),
          const SizedBox(height: 16),
          Container(
            height: 250,
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    margin: index != 0 ? const EdgeInsets.only(top: 10.0) : const EdgeInsets.only(),
                    color: Color.fromRGBO(231, 231, 231, 1),
                    child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Padding(
                                padding: EdgeInsets.only(top: 14.0),
                                child: Container(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(Icons.settings, size: 25.0),
                                  ),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color.fromRGBO(217, 217, 217, 1)),
                                )),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("1 Ottobre",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12.0,
                                            fontFamily: 'SF Pro Text')),
                                    const SizedBox(height: 9),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Affitto",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'SF Pro Text')),
                                        RichText(
                                          text: TextSpan(children: [
                                            TextSpan(
                                                text: "-280,00",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 10.0,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'SF Pro Text')),
                                            TextSpan(
                                              text: "€",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 6.0,
                                                  fontFamily: 'SF Pro Text',
                                                  fontFeatures: [
                                                    const FontFeature.subscripts()
                                                  ]),
                                            ),
                                          ]),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Casa",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 10.0,
                                                  fontFamily: 'SF Pro Text')),
                                          Text("Buddybank",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 10.0,
                                                  fontFamily: 'SF Pro Text')),
                                        ]),
                                  ],
                                )),
                          ],
                        )),
                  );
                }),
          ),

          const SizedBox(height: 30),
        ]);
  }
}
