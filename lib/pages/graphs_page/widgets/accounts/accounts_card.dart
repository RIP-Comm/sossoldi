import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sossoldi/pages/graphs_page/widgets/linear_progress_bar.dart';
import '../../../../constants/functions.dart';
import '../../../../constants/style.dart';
import '../../../../custom_widgets/default_container.dart';
import '../../../../providers/accounts_provider.dart';
import '../../../../providers/currency_provider.dart';
import '../../../../model/bank_account.dart';
import '../card_label.dart';

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
            data: (accounts) => ListView.builder(
              itemCount: accounts.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemBuilder: (context, i) {
                double total = accounts.isNotEmpty
                    ? accounts
                        .map((account) => account.total!.toDouble())
                        .reduce(
                            (first, second) => first > second ? first : second)
                    : 0.0;
                if (i == accounts.length) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [defaultShadow],
                      ),
                    ),
                  );
                } else {
                  BankAccount account = accounts[i];
                  return SizedBox(
                    height: 50.0,
                    child: Column(
                      children: [
                        const Padding(padding: EdgeInsets.all(2.0)),
                        Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: account.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: blue1),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "${numToCurrency(account.total)}${currencyState.selectedCurrency.symbol}",
                                textAlign: TextAlign.right,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: blue1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        LinearProgressBar(
                          type: BarType.account,
                          amount: account.total!.toDouble(),
                          total: total,
                          colorIndex: account.color,
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            error: (e, s) => Text('Error: $e'),
            loading: () => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
