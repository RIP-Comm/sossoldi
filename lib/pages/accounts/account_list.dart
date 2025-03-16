import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/constants.dart';
import '../../constants/functions.dart';
import '../../custom_widgets/default_card.dart';
import '../../custom_widgets/rounded_icon.dart';
import '../../model/bank_account.dart';
import '../../providers/accounts_provider.dart';

class AccountList extends ConsumerStatefulWidget {
  const AccountList({super.key});

  @override
  ConsumerState<AccountList> createState() => _AccountListState();
}

class _AccountListState extends ConsumerState<AccountList> with Functions {
  @override
  Widget build(BuildContext context) {
    final accountsList = ref.watch(accountsProvider);
    ref.listen(selectedAccountProvider, (_, __) {});
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Account'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(accountsProvider.notifier).reset();
              Navigator.of(context).pushNamed('/add-account');
            },
            icon: const Icon(
              Icons.add_circle,
              size: 30,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(
              height: 16,
            ),
            accountsList.when(
              data: (accounts) => ListView.separated(
                itemCount: accounts.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, i) {
                  BankAccount account = accounts[i];
                  return DefaultCard(
                    onTap: () {
                      ref.read(selectedAccountProvider.notifier).state =
                          account;
                      Navigator.of(context).pushNamed('/add-account');
                    },
                    child: Row(
                      children: [
                        RoundedIcon(
                          icon: accountIconList[account.symbol],
                          backgroundColor: accountColorListTheme[account.color],
                          size: 30,
                        ),
                        const SizedBox(width: 12.0),
                        Text(
                          account.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                  color: Theme.of(context).colorScheme.primary),
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
