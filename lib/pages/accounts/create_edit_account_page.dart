import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/accounts_provider.dart';
import '../../constants/constants.dart';
import '../../constants/style.dart';
import '../../providers/currency_provider.dart';
import '../../ui/formatters/decimal_text_input_formatter.dart';
import '../../ui/device.dart';
import '../../ui/extensions.dart';
import 'widgets/confirm_account_deletion_dialog.dart';

class CreateEditAccountPage extends ConsumerStatefulWidget {
  const CreateEditAccountPage({super.key});

  @override
  ConsumerState<CreateEditAccountPage> createState() =>
      _CreateEditAccountPage();
}

class _CreateEditAccountPage extends ConsumerState<CreateEditAccountPage> {
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
      balanceController.text = selectedAccount.total?.toCurrency() ?? "";
      accountIcon = selectedAccount.symbol;
      accountColor = selectedAccount.color;
      countNetWorth = selectedAccount.countNetWorth;
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
    final currencyState = ref.watch(currencyStateProvider);
    var l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedAccount == null ? l10n.newAccount : l10n.editAccount),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      persistentFooterDecoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 5.0,
            offset: const Offset(0, -1.0),
          ),
        ],
      ),
      persistentFooterButtons: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Sizes.sm,
            Sizes.xs,
            Sizes.sm,
            Sizes.sm,
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              boxShadow: [defaultShadow],
              borderRadius: BorderRadius.circular(Sizes.borderRadius),
            ),
            child: ElevatedButton(
              onPressed: () async {
                if (selectedAccount != null) {
                  await ref
                      .read(accountsProvider.notifier)
                      .updateAccount(
                        name: nameController.text,
                        icon: accountIcon,
                        color: accountColor,
                        balance: balanceController.text.toNum(),
                        countNetWorth: countNetWorth,
                        mainAccount: mainAccount,
                      );
                } else {
                  await ref
                      .read(accountsProvider.notifier)
                      .addAccount(
                        name: nameController.text,
                        icon: accountIcon,
                        color: accountColor,
                        countNetWorth: countNetWorth,
                        mainAccount: mainAccount,
                        startingValue: balanceController.text.toNum(),
                      );
                }
                if (context.mounted) Navigator.of(context).pop();
              },
              child: Text(
                selectedAccount == null ? l10n.createAccount.toUpperCase() : l10n.editAccount.toUpperCase()
              ),
            ),
          ),
        ),
      ],
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: Sizes.lg,
              ),
              padding: const EdgeInsets.fromLTRB(
                Sizes.lg,
                Sizes.md,
                Sizes.lg,
                0,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(Sizes.borderRadiusSmall),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.name.toUpperCase(), style: Theme.of(context).textTheme.labelLarge),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(hintText: l10n.accountName),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: Sizes.lg),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(Sizes.borderRadiusSmall),
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.iconAndColor,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  const SizedBox(height: Sizes.xl),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        Sizes.borderRadius * 10,
                      ),
                      onTap: () => setState(() => showAccountIcons = true),
                      child: Ink(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accountColorListTheme[accountColor],
                        ),
                        padding: const EdgeInsets.all(Sizes.lg),
                        child: Icon(
                          accountIconList[accountIcon],
                          size: 48,
                          color: white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: Sizes.sm),
                  Text(
                    l10n.chooseColor,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: Sizes.md),
                  if (showAccountIcons) const Divider(color: grey2),
                  if (showAccountIcons)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Sizes.lg,
                        vertical: Sizes.sm,
                      ),
                      color: Theme.of(context).colorScheme.surface,
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: TextButton(
                              onPressed: () =>
                                  setState(() => showAccountIcons = false),
                              child: Text(
                                l10n.done,
                                style: Theme.of(context).textTheme.bodyLarge!
                                    .copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                    ),
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
                              IconData accountIconData = accountIconList.values
                                  .elementAt(index);
                              String accountIconName = accountIconList.keys
                                  .elementAt(index);
                              return GestureDetector(
                                onTap: () => setState(
                                  () => accountIcon = accountIconName,
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(Sizes.xs),
                                  decoration: BoxDecoration(
                                    color:
                                        accountIconList[accountIcon] ==
                                            accountIconData
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.secondary
                                        : Theme.of(context).colorScheme.surface,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    accountIconData,
                                    color:
                                        accountIconList[accountIcon] ==
                                            accountIconData
                                        ? white
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
                  const SizedBox(height: Sizes.md),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: Sizes.lg),
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: Sizes.lg),
                      itemBuilder: (context, index) {
                        Color color = accountColorListTheme[index];
                        return GestureDetector(
                          onTap: () => setState(() => accountColor = index),
                          child: Container(
                            height: accountColorListTheme[accountColor] == color
                                ? 38
                                : 32,
                            width: accountColorListTheme[accountColor] == color
                                ? 38
                                : 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                              border:
                                  accountColorListTheme[accountColor] == color
                                  ? Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
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
                  const SizedBox(height: Sizes.sm),
                  Text(
                    l10n.chooseColor.toUpperCase(),
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: Sizes.lg),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(
                Sizes.lg,
                Sizes.xl,
                Sizes.lg,
                0,
              ),
              padding: const EdgeInsets.fromLTRB(
                Sizes.lg,
                Sizes.md,
                Sizes.lg,
                0,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(Sizes.borderRadiusSmall),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedAccount == null ? l10n.initialBalance.toUpperCase(): l10n.currentBalance.toUpperCase(),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  TextField(
                    controller: balanceController,
                    decoration: InputDecoration(
                      hintText:
                      selectedAccount == null ? l10n.initialBalance: l10n.currentBalance,
                      suffixText: currencyState.symbol,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      DecimalTextInputFormatter(decimalDigits: 2),
                    ],
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: Sizes.lg,
                vertical: Sizes.lg,
              ),
              padding: const EdgeInsets.symmetric(horizontal: Sizes.lg),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(Sizes.borderRadiusSmall),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: Sizes.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.setAsMainAccount,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Switch.adaptive(
                          value: mainAccount,
                          onChanged: (value) =>
                              setState(() => mainAccount = value),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: grey2),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: Sizes.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.countsForNetWorth,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Switch.adaptive(
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
                padding: const EdgeInsets.all(Sizes.lg),
                child: TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return ConfirmAccountDeletionDialog(
                          account: selectedAccount,
                          onPressed: () => ref
                              .read(accountsProvider.notifier)
                              .removeAccount(selectedAccount)
                              .whenComplete(() {
                                if (context.mounted) {
                                  // Navigate back to the /account-list route.
                                  Navigator.popUntil(
                                    context,
                                    ModalRoute.withName('/account-list'),
                                  );
                                }
                              }),
                        );
                      },
                    );
                  },
                  style: TextButton.styleFrom(
                    side: const BorderSide(color: red, width: 1),
                  ),
                  icon: const Icon(Icons.delete_outlined, color: red),
                  label: Text(
                    l10n.deleteAccount,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge!.copyWith(color: red),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
