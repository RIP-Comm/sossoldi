// Home page.

import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../constants/style.dart';
import '../model/bank_account.dart';

import '../custom_widgets/accounts_sum.dart';
import '../custom_widgets/line_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const List<BankAccount> accountList = [
    BankAccount(name: 'Main account', value: 1235.10),
    BankAccount(name: 'N26', value: 3823.56),
    BankAccount(name: 'Fineco', value: 0.07),
  ];

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
                      "MONTHLY BALANCE",
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: Theme.of(context).colorScheme.primary),
                    ),
                    Text(
                      "1.536,65€",
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.only(right: 30.0)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "INCOME",
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    Text(
                      "+2620,55€",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: green),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.only(right: 30.0)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "EXPENSES",
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    RichText(
                      textScaleFactor: MediaQuery.of(context).textScaleFactor,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: (-1050.65).toStringAsFixed(2),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: red),
                          ),
                          TextSpan(
                            text: "€",
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: red),
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
              maxY: 5.0,
              minY: -5.0,
              maxDays: 30.0,
            ),
            Row(
              children: [
                const SizedBox(width: 16),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  "Current month",
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: grey2,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  "Last month",
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 22),
          ],
        ),
        Container(
          decoration: const BoxDecoration(
            color: white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    "Your accounts",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              Container(
                height: 85.0,
                margin: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: ListView.builder(
                  itemCount: accountList.length + 1,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, i) {
                    if (i == accountList.length) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 4, 16),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: cardShadow,
                                blurRadius: 2.0,
                                offset: const Offset(1.0, 1.0),
                              ),
                            ],
                          ),
                          child: TextButton.icon(
                            style: ButtonStyle(
                              maximumSize: MaterialStateProperty.all(const Size(130, 48)),
                              backgroundColor:
                                  MaterialStateProperty.all(Theme.of(context).colorScheme.surface),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                            icon: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: grey1,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Icon(
                                  Icons.add_rounded,
                                  size: 24.0,
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                              ),
                            ),
                            label: Text(
                              "New Account",
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: grey1),
                              maxLines: 2,
                            ),
                            onPressed: () {
                              // Perform action
                            },
                          ),
                        ),
                      );
                    } else {
                      BankAccount account = accountList[i];
                      return AccountsSum(accountName: account.name, amount: account.value);
                    }
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
                  child: Text(
                    "Last transactions",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: cardShadow,
                      blurRadius: 2.0,
                      offset: const Offset(1.0, 1.0),
                    ),
                  ],
                ),
                margin: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "Monday 12 september",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(color: Theme.of(context).colorScheme.primary),
                          ),
                          const Spacer(),
                          RichText(
                            textScaleFactor: MediaQuery.of(context).textScaleFactor,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "-285,99",
                                  style:
                                      Theme.of(context).textTheme.bodyLarge!.copyWith(color: red),
                                ),
                                TextSpan(
                                  text: "€",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(color: red)
                                      .apply(fontFeatures: [const FontFeature.subscripts()]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          // disable scroll
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 2,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemBuilder: (context, i) {
                            return Container(
                              padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context).colorScheme.secondary,
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(Icons.settings, size: 25.0, color: white),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        const SizedBox(height: 11),
                                        Row(
                                          children: [
                                            Text(
                                              'Affitto',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge!
                                                  .copyWith(
                                                      color: Theme.of(context).colorScheme.primary),
                                            ),
                                            const Spacer(),
                                            RichText(
                                              textScaleFactor:
                                                  MediaQuery.of(context).textScaleFactor,
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: "-280,00",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelLarge!
                                                        .copyWith(color: red),
                                                  ),
                                                  TextSpan(
                                                    text: "€",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelSmall!
                                                        .copyWith(color: red)
                                                        .apply(
                                                      fontFeatures: [
                                                        const FontFeature.subscripts()
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Text(
                                              'HOME',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium!
                                                  .copyWith(
                                                      color: Theme.of(context).colorScheme.primary),
                                            ),
                                            const Spacer(),
                                            Text(
                                              'CASH',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium!
                                                  .copyWith(
                                                      color: Theme.of(context).colorScheme.primary),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 11),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    "Your budgets",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: Row(
                  children: [
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
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "320",
                                      style: Theme.of(context).textTheme.labelMedium,
                                    ),
                                    TextSpan(
                                      text: "€",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.apply(fontFeatures: [const FontFeature.subscripts()]),
                                    ),
                                  ],
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "25",
                                      style: Theme.of(context).textTheme.labelSmall,
                                    ),
                                    TextSpan(
                                      text: "%",
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
                          circularStrokeCap: CircularStrokeCap.butt,
                          backgroundColor: const Color.fromRGBO(217, 217, 217, 1),
                          progressColor: const Color.fromRGBO(150, 150, 150, 1),
                        ),
                        const SizedBox(height: 10),
                        Text("Totale", style: Theme.of(context).textTheme.labelMedium),
                      ],
                    ),
                    const Spacer(),
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
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "500",
                                      style: Theme.of(context).textTheme.labelMedium,
                                    ),
                                    TextSpan(
                                      text: "€",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.apply(fontFeatures: [const FontFeature.subscripts()]),
                                    ),
                                  ],
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "50",
                                      style: Theme.of(context).textTheme.labelSmall,
                                    ),
                                    TextSpan(
                                      text: "%",
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
                          circularStrokeCap: CircularStrokeCap.butt,
                          backgroundColor: const Color.fromRGBO(217, 217, 217, 1),
                          progressColor: const Color.fromRGBO(150, 150, 150, 1),
                        ),
                        const SizedBox(height: 10),
                        Text("Spese", style: Theme.of(context).textTheme.labelMedium),
                      ],
                    ),
                    const Spacer(),
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
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text: "178,67",
                                        style: Theme.of(context).textTheme.labelMedium),
                                    TextSpan(
                                      text: "€",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.apply(fontFeatures: [const FontFeature.subscripts()]),
                                    ),
                                  ],
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text: "88%", style: Theme.of(context).textTheme.labelSmall),
                                    TextSpan(
                                      text: "%",
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
                          circularStrokeCap: CircularStrokeCap.butt,
                          backgroundColor: const Color.fromRGBO(217, 217, 217, 1),
                          progressColor: const Color.fromRGBO(150, 150, 150, 1),
                        ),
                        const SizedBox(height: 10),
                        Text("Svago", style: Theme.of(context).textTheme.labelMedium),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ],
    );
  }
}
