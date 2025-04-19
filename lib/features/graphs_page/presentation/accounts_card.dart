import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/linear_progress_bar.dart';
import '../../../constants/functions.dart';
import '../../../widgets/default_container.dart';
import '../../../providers/accounts_provider.dart';
import '../../../providers/currency_provider.dart';
import '../../../model/bank_account.dart';
import 'card_label.dart';

class AccountsCard extends ConsumerWidget with Functions {
  const AccountsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountList = ref.watch(accountsProvider);
    final currencyState = ref.watch(currencyStateNotifier);

    return Column(
      children: [
        const CardLabel(label: "Accounts"),
        const SizedBox(height: 10),
        DefaultContainer(
          child: accountList.when(
            data: (accounts) => ListView.separated(
              itemCount: accounts.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              separatorBuilder: (context, i) => const SizedBox(height: 4),
              itemBuilder: (context, i) {
                double total = accounts.isNotEmpty
                    ? accounts
                        .map((account) => account.total!.toDouble())
                        .reduce(
                            (first, second) => first > second ? first : second)
                    : 0.0;
                BankAccount account = accounts[i];
                return SizedBox(
                  height: 50.0,
                  child: Column(
                    spacing: 4,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: account.name,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "${numToCurrency(account.total)}${currencyState.selectedCurrency.symbol}",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      LinearProgressBar(
                        type: BarType.account,
                        amount: account.total!.toDouble(),
                        total: total,
                        colorIndex: account.color,
                      ),
                    ],
                  ),
                );
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (e, s) => Text('Error: $e'),
          ),
        ),
      ],
    );
  }
}
