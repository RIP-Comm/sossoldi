import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sossoldi/pages/structure.dart';

import '../constants/style.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: blue7,
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(height: 80),
            Text(
              "Set up the app",
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 80),
            Image.asset(
              'images/openVault.png',
              height: 214,
            ),
            const SizedBox(height: 74),
            Text(
                "In a few steps you'll be ready to start keeping\ntrack of your personal finances (almost) like\nMr. Rip",
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: blue1)),
            const Spacer(),
            SizedBox(
                width: 342,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Step1()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('START THE SET UP',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white)),
                )),
            const SizedBox(height: 20),
          ]),
        ));
  }
}

class Step1 extends StatefulWidget {
  const Step1({super.key});

  @override
  State<Step1> createState() => _Step1State();
}

class _Step1State extends State<Step1> {
  // static budget list for testing only
  List<BudgetWrap> budgets = [
    BudgetWrap("Home", 400, Colors.orange),
    BudgetWrap("Free time", 100, Colors.blue),
    BudgetWrap("Health", 100, Colors.pinkAccent),
    BudgetWrap("Savings", 150, Colors.red),
    BudgetWrap("Travel", 50, Colors.lightBlueAccent),
    BudgetWrap("Shopping", 50, Colors.yellow),
  ];

  // sum of the budget of the selected cards
  int totalBudget = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: blue7,
        body: Center(
            child: Column(children: [
          const SizedBox(height: 40),
          Text("STEP 1 OF 2", style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 20),
          Text("Set up your monthly\nbudgets",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(color: black)),
              const SizedBox(height: 20),
          Text("Choose which categories you want to set a budget for",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: black)),
          const SizedBox(height: 5),
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(
                      top: 0, bottom: 0, left: 16, right: 16),
                  child: NotificationListener<OverscrollIndicatorNotification>(
                      onNotification:
                          (OverscrollIndicatorNotification overscroll) {
                        overscroll.disallowIndicator();
                        return true;
                      },
                      child: GridView.builder(
                          itemCount: budgets.length + 1,
                          // +1 is for adding a default card ("add category)
                          scrollDirection: Axis.vertical,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 300,
                                  childAspectRatio: 3,
                                  crossAxisSpacing: 18,
                                  mainAxisSpacing: 12),
                          itemBuilder: (context, index) {
                            // if it is the last element of the builder (budget.length + 1 elements) it creates a default card to add more categories
                            if (index < budgets.length) {
                              return GestureDetector(
                                  onTap: () {
                                    BudgetWrap budget =
                                        budgets.elementAt(index);

                                    // if the budget is clicked decrease the total budget and set its status to not clicked
                                    if (budget.isClicked) {
                                      totalBudget -= budget.amount;
                                    } else {
                                      totalBudget += budget.amount;
                                    }

                                    budget.isClicked = !budget.isClicked;

                                    // update the page
                                    setState(() {});
                                  },
                                  child: buildCard(budgets.elementAt(index)));
                            } else {
                              return GestureDetector(
                                  onTap: () {}, child: buildDefaultCard());
                            }
                          })))),

          // if the total budget (sum of the budget of the selected cards) is > 0, set the other layout. otherwise set the "continue without budget" button
          totalBudget > 0
              ? Center(
                  child: Column(
                    children: [
                      Text("Monthly budget total:",
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 10),
                      RichText(
                        textScaleFactor: MediaQuery.of(context).textScaleFactor,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: totalBudget.toString(),
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                            TextSpan(
                              text: "€",
                              style:
                                  Theme.of(context).textTheme.bodyMedium?.apply(
                                fontFeatures: [const FontFeature.subscripts()],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                          width: 342,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Step2()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: blue5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('NEXT STEP',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.white)),
                          )),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(left: 75, right: 75),
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Step2()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        shadowColor: Colors.transparent,
                        backgroundColor: Colors.transparent,
                      ),
                      child: Container(
                          padding: const EdgeInsets.only(bottom: 1.0),
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom:
                                      BorderSide(width: 1.2, color: black))),
                          child: Row(
                            children: [
                              Text('CONTINUE WITHOUT BUDGET  ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: black)),
                              const Icon(Icons.arrow_forward,
                                  size: 15, color: black),
                            ],
                          )))),
          const SizedBox(height: 20),
        ])));
  }

  Widget buildCard(BudgetWrap budget) {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(color: budget.color, width: 2.5),
            color: budget.isClicked
                ? budget.color
                : HSLColor.fromColor(budget.color)
                    .withLightness(clampDouble(0.99, 0.0, 0.9))
                    .toColor(),
            borderRadius: const BorderRadius.all(Radius.circular(8))),
        alignment: Alignment.center,
        child: Row(
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 10),
                child: CircleAvatar(
                  backgroundColor:
                      budget.isClicked ? budget.color : Colors.black,
                  radius: 15.0,
                  child: CircleAvatar(
                      backgroundColor: budget.isClicked
                          ? white
                          : HSLColor.fromColor(budget.color)
                              .withLightness(clampDouble(0.99, 0.0, 0.9))
                              .toColor(),
                      radius: 13,
                      child: budget.isClicked
                          ? Icon(Icons.check, color: budget.color, size: 22)
                          : const Icon(Icons.add, color: black)),
                )),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                    width: 125,
                    child: Text(
                      budget.title,
                      textAlign: TextAlign.left,
                      style: budget.isClicked
                          ? Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.apply(color: white)
                          : Theme.of(context).textTheme.bodyMedium,
                    )),
                SizedBox(
                    width: 125,
                    child: budget.isClicked
                        ? Text("BUDGET: ${budget.amount}€",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.apply(color: white))
                        : Text("ADD BUDGET",
                            style: Theme.of(context).textTheme.bodySmall)),
              ],
            )
          ],
        ));
  }

  Widget buildDefaultCard() {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(color: grey2, width: 2.5),
            color: grey3,
            borderRadius: const BorderRadius.all(Radius.circular(8))),
        alignment: Alignment.center,
        child: Row(
          children: [
            const Padding(
                padding: EdgeInsets.only(left: 10),
                child: CircleAvatar(
                  backgroundColor: grey1,
                  radius: 15.0,
                  child: CircleAvatar(
                      backgroundColor: grey3,
                      radius: 13,
                      child: Icon(Icons.add, color: grey1)),
                )),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                    width: 125,
                    child: Text("Add category",
                        textAlign: TextAlign.left,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.apply(color: grey1))),
              ],
            )
          ],
        ));
  }
}

class Step2 extends StatefulWidget {
  const Step2({super.key});

  @override
  State<Step2> createState() => _Step2State();
}

class _Step2State extends State<Step2> {
  TextEditingController accountNameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    accountNameController.text = "Main account";

    return Scaffold(
        backgroundColor: blue7,
        body: Center(
            child: Column(children: [
          const SizedBox(height: 40),
          Text("STEP 2 OF 2", style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 20),
          Text("Set the liquidity in your main\naccount",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(color: black)),
          const SizedBox(height: 20),
          Text(
              "It will be used as a baseline to which you can add\nincome, expenses and calculate your wealth.\n\nYou’ll be able to add more accounts within the app.",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: black)),
          const SizedBox(height: 10),
          Container(
              margin: const EdgeInsets.only(left: 25.0, right: 25.0),
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              decoration: BoxDecoration(
                  color: white,
                  shape: BoxShape.rectangle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 20,
                      offset: const Offset(2, 2),
                    ),
                  ],
                  borderRadius: const BorderRadius.all(Radius.circular(20))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("ACCOUNT NAME ",
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall),
                      const Icon(Icons.edit, size: 10)
                    ],
                  ),
                  TextField(
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium?.apply(color: black),
                    textAlign: TextAlign.center,
                    controller: accountNameController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("SET AMOUNT ",
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: black)),
                      const Icon(Icons.edit, size: 10)
                    ],
                  ),
                  TextField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    controller: amountController,
                    decoration: InputDecoration(
                      hintText: "e.g 1300 €",
                      hintStyle: Theme.of(context).textTheme.bodySmall,
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("EDIT ICON AND COLOR ",
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: black)),
                      const Icon(Icons.edit, size: 10)
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(10),
                      backgroundColor: blue5,
                    ),
                    child:const Icon(Icons.account_balance, size: 40, color: white,),
                  ),
                  const SizedBox(height: 15),
                ],
              )),
              const Spacer(),
              Text('Or you can skip this step and start from 0',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: black)),
          const SizedBox(height: 5),
          SizedBox(
              width: 156,
              height: 48,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/');
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0.0,
                    shadowColor: Colors.transparent,
                    backgroundColor: Colors.transparent,
                  ),
                  child: Container(
                      padding: const EdgeInsets.only(bottom: 1.0),
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(width: 1.2, color: black))),
                      child: Row(
                        children: [
                          Text('START FROM 0  ',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: black)),
                          const Icon(Icons.arrow_forward,
                              size: 15, color: black),
                        ],
                      )))),
          const SizedBox(height: 20),
          SizedBox(
              width: 342,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: grey2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('START TRACKING YOUR EXPENSES',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white)),
              )),
          const SizedBox(height: 20),
        ])));
  }
}

// class for testing only (will be changed when database is implemented)
class BudgetWrap {
  final String title;
  final int amount;
  final Color color;
  var isClicked = false;

  BudgetWrap(this.title, this.amount, this.color);
}
