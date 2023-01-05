// Home page.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../custom_widgets/accounts_sum.dart';

// database
import '../database/sossoldi_database.dart';

// TEMP (just to use json.encode())
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Future dbAction() async {
    print(json.encode(await SossoldiDatabase.instance.read(2)));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        const SizedBox(height: 32),
        RichText(
            textAlign: TextAlign.center,
            text: TextSpan(children: [
              TextSpan(
                text: "3.250,65",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextSpan(
                text: "€",
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.apply(fontFeatures: [FontFeature.subscripts()]),
              ),
            ])),
        Text(
          textAlign: TextAlign.center,
          "MONTHLY BALANCE",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(children: [
              RichText(
                  text: TextSpan(children: [
                TextSpan(
                  text: "+4.620,55",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                TextSpan(
                  text: "€",
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.apply(fontFeatures: [FontFeature.subscripts()]),
                )
              ])),
              Text(
                "INCOME",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ]),
            const SizedBox(width: 87),
            Column(children: [
              RichText(
                  text: TextSpan(children: [
                TextSpan(
                  text: "-1050,65",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                TextSpan(
                  text: "€",
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.apply(fontFeatures: [FontFeature.subscripts()]),
                )
              ])),
              Text(
                "EXPENSES",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ]),
          ],
        ),
        const SizedBox(height: 28),
        const SizedBox(height: 28),
        GestureDetector(
          onTap: () async {
            print(dbAction());
          },
          child: Text('TAP ME TAP ME'),
        ),
        Align(
            alignment: Alignment.centerLeft,
            child: Padding(
                padding: EdgeInsets.only(left: 16),
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
                          itemCount: 5,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemBuilder: (context, i) {
                            return ListTile(
                              leading: Container(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.settings, size: 25.0),
                                ),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color.fromRGBO(217, 217, 217, 1)),
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
