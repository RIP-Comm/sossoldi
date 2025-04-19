import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/constants.dart';
import '../../../shared/providers/accounts_provider.dart';
import '../../../utils/decimal_text_input_formatter.dart';
import '../../../ui/device.dart';
import '/constants/style.dart';

class AccountSetup extends ConsumerStatefulWidget {
  const AccountSetup({super.key});

  @override
  ConsumerState<AccountSetup> createState() => _AccountSetupState();
}

class _AccountSetupState extends ConsumerState<AccountSetup> {
  TextEditingController accountNameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  String accountIcon = accountIconList.keys.first;
  int accountColor = 0;

  bool _validAmount = false;

  // Function to validate amount
  void validateAmount(String value) {
    setState(() {
      _validAmount = RegExp(r'^\d*\.?\d{0,2}$').hasMatch(value);
    });
  }

  Future<void> _flagOnBoardingCompleted() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setBool('onboarding_completed', true);
  }

  @override
  void dispose() {
    accountNameController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blue7,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.lg),
          child: Column(
            children: [
              Text("STEP 2 OF 2",
                  style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: Sizes.xl),
              Text(
                "Set the liquidity in your main account",
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(color: blue1),
              ),
              const SizedBox(height: Sizes.xl),
              Text(
                "It will be used as a baseline to which you can add income, expenses and calculate your wealth.",
                textAlign: TextAlign.center,
                maxLines: 3,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: blue1),
              ),
              const SizedBox(height: Sizes.sm),
              Text(
                "You'll be able to add more accounts within the app.",
                textAlign: TextAlign.center,
                maxLines: 3,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: blue1),
              ),
              const SizedBox(height: Sizes.sm),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: Sizes.xl, vertical: Sizes.lg),
                    padding: const EdgeInsets.symmetric(
                        horizontal: Sizes.xl, vertical: Sizes.lg),
                    decoration: BoxDecoration(
                        color: white,
                        shape: BoxShape.rectangle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.5),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(2, 2),
                          ),
                        ],
                        borderRadius:
                            BorderRadius.circular(Sizes.borderRadiusLarge)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("ACCOUNT NAME ",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: grey1)),
                            const Icon(Icons.edit, size: 10)
                          ],
                        ),
                        TextField(
                          textAlign: TextAlign.center,
                          controller: accountNameController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: "Main Account",
                            errorStyle: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontSize: 10, color: red),
                            hintStyle: Theme.of(context).textTheme.bodySmall,
                            border: const UnderlineInputBorder(
                              borderSide: BorderSide(color: grey2, width: 0.2),
                            ),
                          ),
                          onTapOutside: (_) {
                            FocusScopeNode currentFocus =
                                FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                          },
                        ),
                        const SizedBox(height: Sizes.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("SET AMOUNT ",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: grey1)),
                            const Icon(Icons.edit, size: 10)
                          ],
                        ),
                        TextField(
                          textAlign: TextAlign.center,
                          controller: amountController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                            signed: Platform.isAndroid,
                          ),
                          onChanged: validateAmount,
                          inputFormatters: [
                            DecimalTextInputFormatter(decimalDigits: 2),
                          ],
                          decoration: InputDecoration(
                            hintText: "e.g 1300 €",
                            suffixText: "€",
                            errorStyle: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontSize: 10, color: red),
                            hintStyle: Theme.of(context).textTheme.bodySmall,
                            border: const UnderlineInputBorder(
                              borderSide: BorderSide(color: grey2, width: 0.2),
                            ),
                          ),
                          onTapOutside: (_) {
                            FocusScopeNode currentFocus =
                                FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                          },
                        ),
                        const SizedBox(height: Sizes.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("EDIT ICON AND COLOR ",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: grey1)),
                            const Icon(Icons.edit, size: 10)
                          ],
                        ),
                        const SizedBox(height: Sizes.xs),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accountColorList[accountColor],
                          ),
                          padding: const EdgeInsets.all(Sizes.lg),
                          child: Icon(
                            accountIconList[accountIcon],
                            size: 36,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(height: Sizes.md),
                        SizedBox(
                          height: 38,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: Sizes.lg),
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: Sizes.lg),
                            itemBuilder: (context, index) {
                              Color color = accountColorList[index];
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => accountColor = index),
                                child: Container(
                                  height:
                                      accountColorList[accountColor] == color
                                          ? 38
                                          : 32,
                                  width: accountColorList[accountColor] == color
                                      ? 38
                                      : 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: color,
                                    border:
                                        accountColorList[accountColor] == color
                                            ? Border.all(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                width: 3,
                                              )
                                            : null,
                                  ),
                                ),
                              );
                            },
                            itemCount: accountColorList.length,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: Sizes.sm),
                          child: Divider(height: 1, color: grey2),
                        ),
                        SizedBox(
                          height: 38,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: Sizes.lg),
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: Sizes.lg),
                            itemBuilder: (context, index) {
                              IconData accountIconData =
                                  accountIconList.values.elementAt(index);
                              String accountIconName =
                                  accountIconList.keys.elementAt(index);
                              return GestureDetector(
                                onTap: () => setState(
                                    () => accountIcon = accountIconName),
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  margin: const EdgeInsets.all(Sizes.xxs),
                                  decoration: BoxDecoration(
                                    color: accountIconList[accountIcon] ==
                                            accountIconData
                                        ? Theme.of(context)
                                            .colorScheme
                                            .secondary
                                        : Theme.of(context).colorScheme.surface,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    accountIconData,
                                    color: accountIconList[accountIcon] ==
                                            accountIconData
                                        ? Colors.white
                                        : Theme.of(context).colorScheme.primary,
                                    size: 24,
                                  ),
                                ),
                              );
                            },
                            itemCount: accountIconList.length,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  SizedBox(height: Sizes.lg),
                  Text('Or you can skip this step and start from 0',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: blue1)),
                  const SizedBox(height: Sizes.sm),
                  ElevatedButton(
                    onPressed: () {
                      _flagOnBoardingCompleted();
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('/', (route) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      shadowColor: Colors.transparent,
                      backgroundColor: Colors.transparent,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'START FROM 0  ',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: blue1),
                            ),
                            const Icon(
                              Icons.arrow_forward,
                              size: 15,
                              color: blue1,
                            ),
                          ],
                        ),
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width / 3,
                          child: const Divider(
                            color: blue1,
                            thickness: 1,
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Sizes.xl,
                      vertical: Sizes.lg,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_validAmount) {
                          ref.watch(accountsProvider.notifier).addAccount(
                                name: accountNameController.text,
                                icon: accountIcon,
                                color: accountColor,
                                mainAccount: true,
                                startingValue:
                                    num.tryParse(amountController.text) ?? 0,
                              );
                          _flagOnBoardingCompleted();
                          Navigator.of(context)
                              .pushNamedAndRemoveUntil('/', (route) => false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _validAmount ? blue5 : grey2,
                      ),
                      child: Center(
                        child: Text(
                          'START TRACKING YOUR EXPENSES',
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
