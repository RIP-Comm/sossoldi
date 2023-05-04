import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sossoldi/constants/constants.dart';
import 'package:sossoldi/custom_widgets/default_container.dart';
import '../../../constants/functions.dart';
import '../../../model/bank_account.dart';
import '../../../providers/accounts_provider.dart';

class AccountList extends ConsumerStatefulWidget {
  const AccountList({Key? key}) : super(key: key);

  @override
  ConsumerState<AccountList> createState() => _AccountListState();
}

class _AccountListState extends ConsumerState<AccountList> with Functions {
  @override
  Widget build(BuildContext context) {
    final accountsList = ref.watch(accountsProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("Account"),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed('/add-account'),
            icon: const Icon(Icons.add_circle),
            splashRadius: 28,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.account_balance_wallet,
                      size: 16.0,
                      color: Theme.of(context).colorScheme.background,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Text(
                    "Your accounts",
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge!
                        .copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
            ),
            accountsList.when(
              data: (accounts) => ListView.separated(
                itemCount: accounts.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, i) {
                  BankAccount account = accounts[i];
                  IconData? icon = accountIconList[account.symbol];
                  Color? color = accountColorList[account.color];
                  return DefaultContainer(
                    onTap: () async {
                      await ref.read(accountsProvider.notifier).selectedAccount(account).whenComplete(() => Navigator.of(context).pushNamed('/add-account'));
                    },
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                          ),
                          padding: const EdgeInsets.all(10.0),
                          child: icon != null
                              ? Icon(
                                  icon,
                                  size: 30.0,
                                  color: Theme.of(context).colorScheme.background,
                                )
                              : const SizedBox(),
                        ),
                        const SizedBox(width: 12.0),
                        Text(
                          account.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(color: Theme.of(context).colorScheme.primary),
                        ),
                      ],
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
            ),
          ],
        ),
      ),
    );
  }
}
