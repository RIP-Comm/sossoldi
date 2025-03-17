import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/accounts_provider.dart';
import '../../constants/constants.dart';
import '../../constants/functions.dart';
import '../../constants/style.dart';
import '../../providers/currency_provider.dart';

class AddAccount extends ConsumerStatefulWidget {
  const AddAccount({super.key});

  @override
  ConsumerState<AddAccount> createState() => _AddAccountState();
}

class _AddAccountState extends ConsumerState<AddAccount> with Functions {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();
  String accountIcon = accountIconList.keys.first;
  int accountColor = 0;
  bool countNetWorth = true;
  bool mainAccount = false;

  bool showAccountIcons = false;

  @override
  void initState() {
    final selectedAccount = ref.read(selectedAccountProvider);
    if (selectedAccount != null) {
      nameController.text = selectedAccount.name;
      balanceController.text = numToCurrency(selectedAccount.total);
      accountIcon = selectedAccount.symbol;
      accountColor = selectedAccount.color;
      countNetWorth = selectedAccount.active;
      mainAccount = selectedAccount.mainAccount;
    }
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedAccount = ref.watch(selectedAccountProvider);
    final currencyState = ref.watch(currencyStateNotifier);

    return Scaffold(
      appBar: AppBar(
        title: Text("${selectedAccount == null ? "New" : "Edit"} account"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "NAME",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(hintText: "Account name"),
                          style: Theme.of(context).textTheme.titleLarge,
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "ICON AND COLOR",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(90)),
                            onTap: () =>
                                setState(() => showAccountIcons = true),
                            child: Ink(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accountColorListTheme[accountColor],
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Icon(
                                accountIconList[accountIcon],
                                size: 48,
                                color: white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "CHOOSE ICON",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: 12),
                        if (showAccountIcons) const Divider(color: grey2),
                        if (showAccountIcons)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            color: Theme.of(context).colorScheme.surface,
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: TextButton(
                                    onPressed: () => setState(
                                        () => showAccountIcons = false),
                                    child: Text(
                                      "Done",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary),
                                    ),
                                  ),
                                ),
                                GridView.builder(
                                  itemCount: accountIconList.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 6,
                                  ),
                                  itemBuilder: (context, index) {
                                    IconData accountIconData =
                                        accountIconList.values.elementAt(index);
                                    String accountIconName =
                                        accountIconList.keys.elementAt(index);
                                    return GestureDetector(
                                      onTap: () => setState(
                                          () => accountIcon = accountIconName),
                                      child: Container(
                                        margin: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: accountIconList[accountIcon] ==
                                                  accountIconData
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .surface,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          accountIconData,
                                          color: accountIconList[accountIcon] ==
                                                  accountIconData
                                              ? white
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                          size: 24,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        const Divider(height: 1, color: grey2),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 38,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              Color color = accountColorListTheme[index];
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => accountColor = index),
                                child: Container(
                                  height: accountColorListTheme[accountColor] ==
                                          color
                                      ? 38
                                      : 32,
                                  width: accountColorListTheme[accountColor] ==
                                          color
                                      ? 38
                                      : 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: color,
                                    border:
                                        accountColorListTheme[accountColor] ==
                                                color
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
                            itemCount: accountColorListTheme.length,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "CHOOSE COLOR",
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium!
                              .copyWith(
                                  color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${selectedAccount == null ? "INITIAL" : "CURRENT"} BALANCE",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        TextField(
                          controller: balanceController,
                          decoration: InputDecoration(
                            hintText:
                                "${selectedAccount == null ? "Initial" : "Current"} Balance",
                            suffixText: currencyState.selectedCurrency.symbol,
                          ),
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Set as main account",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              CupertinoSwitch(
                                value: mainAccount,
                                onChanged: (value) =>
                                    setState(() => mainAccount = value),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: grey2),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Counts for the net worth",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              CupertinoSwitch(
                                value: countNetWorth,
                                onChanged: (value) =>
                                    setState(() => countNetWorth = value),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selectedAccount != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: TextButton.icon(
                        onPressed: () => ref
                            .read(accountsProvider.notifier)
                            .removeAccount(selectedAccount.id!)
                            .whenComplete(() {
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        }),
                        style: TextButton.styleFrom(
                          side: const BorderSide(color: red, width: 1),
                        ),
                        icon: const Icon(Icons.delete_outlined, color: red),
                        label: Text(
                          "Delete account",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: red),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.15),
                  blurRadius: 5.0,
                  offset: const Offset(0, -1.0),
                )
              ],
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                boxShadow: [defaultShadow],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  if (selectedAccount != null) {
                    await ref.read(accountsProvider.notifier).updateAccount(
                          name: nameController.text,
                          icon: accountIcon,
                          color: accountColor,
                          active: countNetWorth,
                          mainAccount: mainAccount,
                        );
                    if (currencyToNum(balanceController.text) !=
                        selectedAccount.total) {
                      await ref
                          .read(accountsProvider.notifier)
                          .reconcileAccount(
                            newBalance: currencyToNum(balanceController.text),
                            account: selectedAccount,
                          );
                    }
                  } else {
                    await ref.read(accountsProvider.notifier).addAccount(
                          name: nameController.text,
                          icon: accountIcon,
                          color: accountColor,
                          active: countNetWorth,
                          mainAccount: mainAccount,
                          startingValue: currencyToNum(balanceController.text),
                        );
                  }
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: Text(
                  "${selectedAccount == null ? "CREATE" : "UPDATE"} ACCOUNT",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
