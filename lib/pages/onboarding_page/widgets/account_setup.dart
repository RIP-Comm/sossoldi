import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../../constants/constants.dart';
import '../../../providers/accounts_provider.dart';
import '../../../providers/currency_provider.dart';
import '/constants/style.dart';

final showAccountIconsProvider = StateProvider.autoDispose<bool>((ref) => false);

class AccountSetup extends ConsumerStatefulWidget {
  const AccountSetup({super.key});

  @override
  ConsumerState<AccountSetup> createState() => _AccountSetupState();
}

class _AccountSetupState extends ConsumerState<AccountSetup> {
  TextEditingController accountNameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  bool _validName = false;
  bool _validAmount = false;

  // Function to validate amount
  void validateAmount(String value) {
    setState(() {
      _validAmount = RegExp(r'^\d*\.?\d{0,2}$').hasMatch(value);
    });
  }

// Function to validate name
  void validateName(String value) {
    setState(() {
      _validName = RegExp(r'^[a-zA-Z\s]{3,}$').hasMatch(value);
    });
  }

  @override
  void dispose() {
    accountNameController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountIcon = ref.watch(accountIconProvider);
    final accountColor = ref.watch(accountColorProvider);

    return Scaffold(
      backgroundColor: blue7,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text("STEP 2 OF 2", style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 20),
                    Text(
                      "Set the liquidity in your main\naccount",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: blue1),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "It will be used as a baseline to which you can add\nincome, expenses and calculate your wealth.\n\nYou’ll be able to add more accounts within the app.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: blue1),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      margin: const EdgeInsets.only(left: 25.0, right: 25.0),
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 15, bottom: 15),
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
                            onChanged: validateName,
                            autofocus: true,
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp(r'^[a-zA-Z]{10,}$')),
                            ],
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
                              FocusScopeNode currentFocus = FocusScope.of(context);
                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                            },
                          ),
                          const SizedBox(height: 15),
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
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true, signed: true),
                            onChanged: validateAmount,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
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
                              FocusScopeNode currentFocus = FocusScope.of(context);
                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                            },
                          ),
                          const SizedBox(height: 8),
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
                          const SizedBox(height: 6),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: const BorderRadius.all(Radius.circular(90)),
                              onTap: () => ref.read(showAccountIconsProvider.notifier).state = true,
                              child: Ink(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: accountColorList[accountColor],
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Icon(
                                  accountIconList[accountIcon],
                                  size: 36,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 38,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              separatorBuilder: (context, index) => const SizedBox(width: 16),
                              itemBuilder: (context, index) {
                                Color color = accountColorList[index];
                                return GestureDetector(
                                  onTap: () =>
                                      ref.read(accountColorProvider.notifier).state = index,
                                  child: Container(
                                    height: accountColorList[accountColor] == color ? 38 : 32,
                                    width: accountColorList[accountColor] == color ? 38 : 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: color,
                                      border: accountColorList[accountColor] == color
                                          ? Border.all(
                                              color: Theme.of(context).colorScheme.primary,
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
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Divider(height: 1, color: grey2),
                          ),
                          SizedBox(
                            height: 38,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              separatorBuilder: (context, index) => const SizedBox(width: 16),
                              itemBuilder: (context, index) {
                                IconData accountIconData = accountIconList.values.elementAt(index);
                                String accountIconName = accountIconList.keys.elementAt(index);
                                return GestureDetector(
                                  onTap: () => ref.read(accountIconProvider.notifier).state =
                                      accountIconName,
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    margin: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: accountIconList[accountIcon] == accountIconData
                                          ? Theme.of(context).colorScheme.secondary
                                          : Theme.of(context).colorScheme.surface,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      accountIconData,
                                      color: accountIconList[accountIcon] == accountIconData
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
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    Text('Or you can skip this step and start from 0',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: blue1)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        ref.watch(currencyStateNotifier.notifier).insertAll();
                        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
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
                              Text('START FROM 0  ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: blue1)),
                              const Icon(Icons.arrow_forward, size: 15, color: blue1),
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
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
                      child: SizedBox(
                        width: MediaQuery.sizeOf(context).width,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_validName && _validAmount) {
                              ref.watch(accountsProvider.notifier).addAccount(
                                  accountNameController.text, num.tryParse(amountController.text));
                              ref.watch(currencyStateNotifier.notifier).insertAll();
                              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _validName && _validAmount ? blue5 : grey2,
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
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
