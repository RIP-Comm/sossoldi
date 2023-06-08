import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/model/budget.dart';
import '/providers/categories_provider.dart';
import '/constants/constants.dart';
import '/constants/style.dart';
import '/model/category_transaction.dart';
import '/providers/budgets_provider.dart';
import 'package:collection/collection.dart';

class AccountSetup extends ConsumerStatefulWidget {
  const AccountSetup({Key? key}) : super(key: key);

  @override
  ConsumerState<AccountSetup> createState() => _AccountSetupState();
}

class _AccountSetupState extends ConsumerState<AccountSetup> {
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
