import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/style.dart';
import '../../../providers/accounts_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../ui/widgets/accounts_sum.dart';
import '../../../ui/widgets/rounded_icon.dart';
import '../../../models/bank_account.dart';

class AccountsList extends ConsumerWidget {
  const AccountsList({
    super.key,
    required this.accounts,
  });

  final List<BankAccount> accounts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(appThemeStateNotifier).isDarkModeEnabled;

    return ListView.separated(
      itemCount: accounts.length + 1,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      separatorBuilder: (context, i) => const SizedBox(width: 16),
      itemBuilder: (context, i) {
        if (i == accounts.length) {
          return Container(
            constraints: const BoxConstraints(maxWidth: 140),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [defaultShadow],
            ),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              icon: RoundedIcon(
                icon: Icons.add_rounded,
                backgroundColor: blue5,
                padding: EdgeInsets.all(5.0),
              ),
              label: Text(
                "New Account",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: isDarkMode
                          ? grey3
                          : Theme.of(context).colorScheme.secondary,
                    ),
                maxLines: 2,
              ),
              onPressed: () {
                ref.read(accountsProvider.notifier).reset();
                Navigator.of(context).pushNamed('/add-account');
              },
            ),
          );
        }
        BankAccount account = accounts[i];
        return AccountsSum(account: account);
      },
    );
  }
}
