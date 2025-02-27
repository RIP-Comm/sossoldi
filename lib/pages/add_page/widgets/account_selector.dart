import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/constants.dart';
import '../../../constants/functions.dart';
import '../../../constants/style.dart';
import '../../../custom_widgets/rounded_icon.dart';
import '../../../model/bank_account.dart';
import '../../../providers/accounts_provider.dart';
import '../../../providers/transactions_provider.dart';

class AccountSelector extends ConsumerStatefulWidget {
  const AccountSelector({
    required this.scrollController,
    this.transfer = false,
    super.key,
  });

  final ScrollController scrollController;
  final bool transfer;

  @override
  ConsumerState<AccountSelector> createState() => _AccountSelectorState();
}

class _AccountSelectorState extends ConsumerState<AccountSelector>
    with Functions {
  @override
  Widget build(BuildContext context) {
    final accountsList = ref.watch(accountsProvider);
    final fromAccount = ref.watch(bankAccountProvider);
    final toAccount = ref.watch(bankAccountTransferProvider);

    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            title: const Text("Account"),
            actions: [
              IconButton(
                onPressed: () {
                  ref.invalidate(selectedAccountProvider);
                  Navigator.of(context).pushNamed('/add-account');
                },
                icon: const Icon(Icons.add_circle),
                splashRadius: 28,
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    padding:
                        const EdgeInsets.only(left: 16, top: 32, bottom: 8),
                    child: Text(
                      "MORE FREQUENT",
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.surface,
                    height: 74,
                    width: double.infinity,
                    child: accountsList.when(
                      data: (accounts) => ListView.builder(
                        itemCount: (accounts.length > 4) ? 4 : accounts.length,
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemBuilder: (context, i) {
                          BankAccount account = accounts[i];
                          bool enabled = (widget.transfer &&
                                  account.id != fromAccount?.id) ||
                              (!widget.transfer && account.id != toAccount?.id);
                          return GestureDetector(
                            onTap: enabled
                                ? () {
                                    if (widget.transfer) {
                                      ref
                                          .read(bankAccountTransferProvider
                                              .notifier)
                                          .state = account;
                                    } else {
                                      ref
                                          .read(bankAccountProvider.notifier)
                                          .state = account;
                                    }
                                    Navigator.pop(context);
                                  }
                                : null,
                            child: Opacity(
                              opacity: enabled ? 1.0 : 0.5,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    RoundedIcon(
                                      icon: accountIconList[account.symbol],
                                      backgroundColor:
                                          accountColorListTheme[account.color],
                                    ),
                                    Text(
                                      account.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text('Error: $err'),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding:
                        const EdgeInsets.only(left: 16, top: 32, bottom: 8),
                    child: Text(
                      "ALL ACCOUNTS",
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  accountsList.when(
                    data: (accounts) => Container(
                      color: Theme.of(context).colorScheme.surface,
                      child: ListView.separated(
                        itemCount: accounts.length,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1, color: grey1),
                        itemBuilder: (context, i) {
                          BankAccount account = accounts[i];
                          bool enabled = (widget.transfer &&
                                  account.id != fromAccount?.id) ||
                              (!widget.transfer && account.id != toAccount?.id);
                          return ListTile(
                            onTap: () {
                              if (widget.transfer) {
                                ref
                                    .read(bankAccountTransferProvider.notifier)
                                    .state = account;
                              } else {
                                ref.read(bankAccountProvider.notifier).state =
                                    account;
                              }
                              Navigator.pop(context);
                            },
                            enabled: enabled,
                            leading: RoundedIcon(
                              icon: accountIconList[account.symbol],
                              backgroundColor:
                                  accountColorListTheme[account.color],
                              size: 30,
                            ),
                            title: Text(account.name),
                            trailing: (fromAccount?.id == account.id ||
                                    toAccount?.id == account.id)
                                ? Icon(Icons.check)
                                : null,
                          );
                        },
                      ),
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Text('Error: $err'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
