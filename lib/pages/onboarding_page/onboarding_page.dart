import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/custom_widgets/default_container.dart';
import '/model/budget.dart';
import '/providers/categories_provider.dart';
import '/constants/constants.dart';
import '/constants/style.dart';
import '/model/category_transaction.dart';
import '/providers/budgets_provider.dart';
import 'package:collection/collection.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blue7,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 80,
            ),
            Text(
              'Set up the app',
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(
              height: 80,
            ),
            Image.asset(
              'assets/openVault.png',
              height: 214,
            ),
            const SizedBox(
              height: 74,
            ),
            Text(
              'In a few steps you\'ll be ready to start keeping\ntrack of ypur personal finances (almost) like\nMr. Rip',
              textAlign: TextAlign.center,
              style:
                  Theme.of(context).textTheme.bodySmall?.copyWith(color: blue1),
            ),
            const Spacer(),
            SizedBox(
              width: 342,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Step1(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'START THE SET UP',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class Step1 extends ConsumerStatefulWidget {
  const Step1({Key? key}) : super(key: key);

  @override
  ConsumerState<Step1> createState() => _Step1State();
}

class _Step1State extends ConsumerState<Step1> {
  // sum of the budget of the selected cards
  int totalBudget = 0;

  @override
  Widget build(BuildContext context) {
    final categoriesGrid = ref.watch(categoriesProvider);
    return Scaffold(
      backgroundColor: blue7,
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text("STEP 1 OF 2", style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 20),
            Text(
              "Set up your monthly\nbudgets",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(color: blue1),
            ),
            const SizedBox(height: 20),
            Text(
              "Choose which categories you want to set a budget for",
              textAlign: TextAlign.center,
              style:
                  Theme.of(context).textTheme.bodySmall?.copyWith(color: blue1),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 0, bottom: 0, left: 16, right: 16),
                child: NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (OverscrollIndicatorNotification overscroll) {
                    overscroll.disallowIndicator();
                    return true;
                  },
                  child: categoriesGrid.when(
                    data: (categories) => GridView.builder(
                      itemCount: categories.length+1,
                      scrollDirection: Axis.vertical,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 300,
                        childAspectRatio: 3,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, i) => GestureDetector(
                        onTap: () {},
                        child: Container(
                          child: buildCard(categories.elementAt(i)),
                        ),
                      ),
                    ),
                    error: (err, stack) => Text('Error: $err'),
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
            ),

            // if the total budget (sum of the budget of the selected cards) is > 0, set the other layout. otherwise set the "continue without budget" button
            totalBudget > 0
                ? Center(
                    child: Column(
                      children: [
                        Text("Monthly budget total:",
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 10),
                        RichText(
                          textScaleFactor:
                              MediaQuery.of(context).textScaleFactor,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: totalBudget.toString(),
                                style:
                                    Theme.of(context).textTheme.displayMedium,
                              ),
                              TextSpan(
                                text: "€",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.apply(
                                  fontFeatures: [
                                    const FontFeature.subscripts()
                                  ],
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
                          ),
                        ),
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
                                bottom: BorderSide(width: 1.2, color: black))),
                        child: Row(
                          children: [
                            Text('CONTINUE WITHOUT BUDGET  ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: blue1)),
                            const Icon(Icons.arrow_forward,
                                size: 15, color: blue1),
                          ],
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildCard(CategoryTransaction category) {
    final budgetsList = ref.watch(budgetsProvider);
    Color categoryColor = categoryColorList[category.color];
    String categoryName = category.name;
    if (budgetsList is AsyncData<List<CategoryTransaction>>) {
      final budgets = budgetsList.value;

      Budget? budget =
          budgets?.firstWhereOrNull((c) => c.idCategory == category.id);

      if (budget != null && budget.active) {
        return Container(
          color: categoryColor,
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: categoryColor, width: 2.5),
                color: categoryColor,
                borderRadius: const BorderRadius.all(Radius.circular(8))),
            alignment: Alignment.center,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: categoryColor,
                  radius: 15.0,
                  child: CircleAvatar(
                    backgroundColor: white,
                    radius: 13,
                    child: Icon(Icons.check, color: categoryColor, size: 22),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 125,
                      child: Text(
                        categoryName,
                        textAlign: TextAlign.left,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.apply(color: white),
                      ),
                    ),
                    SizedBox(
                      width: 95,
                      child: Text(
                        "BUDGET: ${budget.amountLimit}€",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.apply(color: white),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      }
    }
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: categoryColor, width: 2.5),
        color: HSLColor.fromColor(categoryColor)
            .withLightness(clampDouble(0.99, 0.0, 0.9))
            .toColor(),
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      alignment: Alignment.center,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: CircleAvatar(
              backgroundColor: blue1,
              radius: 15.0,
              child: CircleAvatar(
                  backgroundColor: HSLColor.fromColor(categoryColor)
                      .withLightness(clampDouble(0.99, 0.0, 0.9))
                      .toColor(),
                  radius: 13,
                  child: const Icon(Icons.add, color: blue1)),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                  width: 95,
                  child: Text(
                    categoryName,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.bodyMedium,
                  )),
              SizedBox(
                  width: 95,
                  child: Text("ADD BUDGET",
                      style: Theme.of(context).textTheme.bodySmall)),
            ],
          )
        ],
      ),
    );
  }

  Widget buildDefaultCard() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: grey2, width: 0.5),
        color: grey3,
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
      ),
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
                child: Icon(Icons.add, color: grey1),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 125,
                child: Text(
                  "Add category",
                  textAlign: TextAlign.left,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.apply(color: grey1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text("STEP 2 OF 2", style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 20),
            Text(
              "Set the liquidity in your main\naccount",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(color: blue1),
            ),
            const SizedBox(height: 20),
            Text(
              "It will be used as a baseline to which you can add\nincome, expenses and calculate your wealth.\n\nYou’ll be able to add more accounts within the app.",
              textAlign: TextAlign.center,
              style:
                  Theme.of(context).textTheme.bodySmall?.copyWith(color: blue1),
            ),
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
                          style: Theme.of(context).textTheme.labelSmall),
                      const Icon(Icons.edit, size: 10)
                    ],
                  ),
                  TextField(
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.apply(color: black),
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
                              ?.copyWith(color: blue1)),
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
                              ?.copyWith(color: blue1)),
                      const Icon(Icons.edit, size: 10)
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    // TO DO - icona modificabile
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(10),
                      backgroundColor: blue5,
                    ),
                    child: const Icon(
                      Icons.account_balance,
                      size: 40,
                      color: white,
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
            const Spacer(),
            Text('Or you can skip this step and start from 0',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: blue1)),
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
                      bottom: BorderSide(width: 1.2, color: black),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'START FROM 0  ',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: blue1),
                      ),
                      const Icon(Icons.arrow_forward, size: 15, color: blue1),
                    ],
                  ),
                ),
              ),
            ),
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
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
