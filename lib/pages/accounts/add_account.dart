import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/accounts_provider.dart';
import '../../constants/constants.dart';
import '../../constants/functions.dart';
import '../../constants/style.dart';
import '../../providers/currency_provider.dart';

final showAccountIconsProvider = StateProvider.autoDispose<bool>((ref) => false);

class AddAccount extends ConsumerStatefulWidget {
  const AddAccount({super.key});

  @override
  ConsumerState<AddAccount> createState() => _AddAccountState();
}

class _AddAccountState extends ConsumerState<AddAccount> with Functions {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController startingValueController = TextEditingController();

  @override
  void initState() {
    nameController.text = ref.read(selectedAccountProvider)?.name ?? '';
    startingValueController.text =
        ref.read(selectedAccountProvider)?.startingValue.toString() ?? '';
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedAccount = ref.watch(selectedAccountProvider);
    final accountIcon = ref.watch(accountIconProvider);
    final accountColor = ref.watch(accountColorProvider);
    final showAccountIcons = ref.watch(showAccountIconsProvider);
    final accountMainSwitch = ref.watch(accountMainSwitchProvider);
    final countNetWorth = ref.watch(countNetWorthSwitchProvider);
    final currencyState = ref.watch(currencyStateNotifier);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(title: Text("${selectedAccount == null ? "New" : "Edit"} account")),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge!
                            .copyWith(color: Theme.of(context).colorScheme.primary),
                      ),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: "Account name",
                          hintStyle: Theme.of(context).textTheme.titleLarge!.copyWith(color: grey2),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(0),
                        ),
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(color: grey1),
                      )
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .copyWith(color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: const BorderRadius.all(Radius.circular(90)),
                          onTap: () => ref.read(showAccountIconsProvider.notifier).state = true,
                          child: Ink(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accountColorListTheme[accountColor],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Icon(
                              accountIconList[accountIcon],
                              size: 48,
                              color: Theme.of(context).colorScheme.background,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "CHOOSE ICON",
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(height: 12),
                      if (showAccountIcons) const Divider(height: 1, color: grey2),
                      if (showAccountIcons)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: Theme.of(context).colorScheme.surface,
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: TextButton(
                                  onPressed: () =>
                                      ref.read(showAccountIconsProvider.notifier).state = false,
                                  child: Text(
                                    "Done",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(color: Theme.of(context).colorScheme.secondary),
                                  ),
                                ),
                              ),
                              GridView.builder(
                                itemCount: accountIconList.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 6),
                                itemBuilder: (context, index) {
                                  IconData accountIconData =
                                      accountIconList.values.elementAt(index);
                                  String accountIconName = accountIconList.keys.elementAt(index);
                                  return GestureDetector(
                                    onTap: () => ref.read(accountIconProvider.notifier).state =
                                        accountIconName,
                                    child: Container(
                                      margin: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                          color: accountIconList[accountIcon] == accountIconData
                                              ? Theme.of(context).colorScheme.secondary
                                              : Theme.of(context).colorScheme.surface,
                                          // borderRadius: const BorderRadius.all(Radius.circular(4)),
                                          shape: BoxShape.circle),
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
                          separatorBuilder: (context, index) => const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            Color color = accountColorListTheme[index];
                            return GestureDetector(
                              onTap: () => ref.read(accountColorProvider.notifier).state = index,
                              child: Container(
                                height: accountColorListTheme[accountColor] == color ? 38 : 32,
                                width: accountColorListTheme[accountColor] == color ? 38 : 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color,
                                  border: accountColorListTheme[accountColor] == color
                                      ? Border.all(
                                          color: Theme.of(context).colorScheme.primary,
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
                            .copyWith(color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                if (selectedAccount == null)
                  Container(
                    width: double.infinity,
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
                          "STARTING VALUE",
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .copyWith(
                                  color: Theme.of(context).colorScheme.primary),
                        ),
                        TextField(
                          controller: startingValueController,
                          decoration: InputDecoration(
                            hintText: "Initial balance",
                            suffixText: currencyState.selectedCurrency.symbol,
                            hintStyle: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(color: grey2),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(0),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9,]')),
                          ],
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(color: grey1),
                        )
                      ],
                    ),
                  ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(color: Theme.of(context).colorScheme.primary),
                            ),
                            CupertinoSwitch(
                              value: accountMainSwitch,
                              onChanged: (value) =>
                                  ref.read(accountMainSwitchProvider.notifier).state = value,
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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(color: Theme.of(context).colorScheme.primary),
                            ),
                            CupertinoSwitch(
                              value: countNetWorth,
                              onChanged: (value) =>
                                  ref.read(countNetWorthSwitchProvider.notifier).state = value,
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: TextButton.icon(
                      onPressed: () => ref
                          .read(accountsProvider.notifier)
                          .removeAccount(selectedAccount.id!)
                          .whenComplete(() => Navigator.of(context).pop()),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: red, width: 1),
                      ),
                      icon: const Icon(Icons.delete_outlined, color: red),
                      label: Text(
                        "Delete account",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: red),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: blue1.withOpacity(0.15),
                    blurRadius: 5.0,
                    offset: const Offset(0, -1.0),
                  )
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  boxShadow: [defaultShadow],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: () async {
                    if (selectedAccount != null) {
                      ref
                          .read(accountsProvider.notifier)
                          .updateAccount(nameController.text)
                          .whenComplete(() => Navigator.of(context).pop());
                    } else {
                      ref
                          .read(accountsProvider.notifier)
                          .addAccount(nameController.text, startingValueController.text.isEmpty ? null : currencyToNum(startingValueController.text))
                          .whenComplete(() => Navigator.of(context).pop());
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    "${selectedAccount == null ? "CREATE" : "UPDATE"} ACCOUNT",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Theme.of(context).colorScheme.background),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
