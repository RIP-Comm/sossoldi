import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'accounts_sum.dart';
import '../../../constants/style.dart';
import '../../../model/bank_account.dart';
import '../../../providers/accounts_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../ui/device.dart';
import '../../../ui/widgets/rounded_icon.dart';

class AccountSection extends ConsumerWidget {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountList = ref.watch(accountsProvider);
    final isDarkMode = ref.watch(appThemeStateProvider).isDarkModeEnabled;
    return SizedBox(
      height: 80.0,
      child: accountList.when(
        data: (accounts) => ListView.separated(
          itemCount: accounts.length + 1,
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(
            horizontal: Sizes.lg,
            vertical: Sizes.xs,
          ),
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          separatorBuilder: (context, i) => const SizedBox(width: Sizes.lg),
          itemBuilder: (context, i) {
            if (i == accounts.length) {
              return Container(
                width: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Sizes.borderRadius),
                  boxShadow: [defaultShadow],
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Sizes.md,
                      vertical: Sizes.sm,
                    ),
                  ),
                  icon: RoundedIcon(
                    icon: Icons.add_rounded,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    padding: const EdgeInsets.all(Sizes.xs),
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
        ),
        loading: () => const SizedBox(),
        error: (err, stack) => Text('Error: $err'),
      ),
    );
  }
}
