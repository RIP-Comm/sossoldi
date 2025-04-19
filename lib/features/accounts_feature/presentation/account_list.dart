import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/constants.dart';
import '../../../shared/models/bank_account.dart';
import '../../../shared/providers/accounts_provider.dart';
import '../../../shared/ui/widgets/default_card.dart';
import '../../../shared/ui/widgets/rounded_icon.dart';
import '../../../shared/ui/device.dart';

class AccountList extends ConsumerStatefulWidget {
  const AccountList({super.key});

  @override
  ConsumerState<AccountList> createState() => _AccountListState();
}

class _AccountListState extends ConsumerState<AccountList> {
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
        actions: [
          IconButton(
            onPressed: () {
              ref.read(accountsProvider.notifier).reset();
              Navigator.of(context).pushNamed('/add-account');
            },
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
              padding: const EdgeInsets.symmetric(
                  vertical: Sizes.xl, horizontal: Sizes.lg),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    padding: const EdgeInsets.all(Sizes.sm),
                    child: Icon(
                      Icons.account_balance_wallet,
                      size: 24.0,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: Sizes.md),
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
                separatorBuilder: (context, index) =>
                    const SizedBox(height: Sizes.lg),
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
                        const SizedBox(width: Sizes.md),
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
