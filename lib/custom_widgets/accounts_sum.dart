import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/constants.dart';
import '../model/bank_account.dart';
import '../constants/functions.dart';
import '../constants/style.dart';
import '../providers/accounts_provider.dart';
import '../providers/currency_provider.dart';
import '../ui/device.dart';
import 'rounded_icon.dart';

/// This class shows account summaries in the dashboard
class AccountsSum extends ConsumerWidget with Functions {
  final BankAccount account;

  const AccountsSum({
    required this.account,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyState = ref.watch(currencyStateNotifier);
    ref.listen(selectedAccountProvider, (_, __) {});
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(Sizes.borderRadius),
        boxShadow: [defaultShadow],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: accountColorListTheme[account.color].withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(Sizes.borderRadius),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(Sizes.borderRadius),
            onTap: () async {
              await ref
                  .read(accountsProvider.notifier)
                  .refreshAccount(account)
                  .whenComplete(() {
                if (context.mounted) {
                  Navigator.of(context).pushNamed('/account');
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: Sizes.md, vertical: Sizes.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 8,
                children: [
                  RoundedIcon(
                    icon: accountIconList[account.symbol],
                    backgroundColor: accountColorListTheme[account.color],
                    padding: const EdgeInsets.all(Sizes.xs),
                    size: 20,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        account.name,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: numToCurrency(account.total),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            TextSpan(
                              text: currencyState.selectedCurrency.symbol,
                              style:
                                  Theme.of(context).textTheme.bodySmall?.apply(
                                fontFeatures: [const FontFeature.subscripts()],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
