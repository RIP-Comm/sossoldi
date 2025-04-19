import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/style.dart';
import '../../../providers/accounts_provider.dart';
import '../../../shared/models/transaction.dart';
import '../../../providers/currency_provider.dart';
import '../../../utils/decimal_text_input_formatter.dart';
import '../../../ui/extensions.dart';
import '../../../ui/widgets/line_chart.dart';
import '../../../ui/widgets/transactions_list.dart';
import '../../../ui/device.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AccountPage();
}

class _AccountPage extends ConsumerState<AccountPage> {
  bool isRecoinciling = false;
  final TextEditingController _newBalanceController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    _newBalanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.read(selectedAccountProvider);
    final accountTransactions =
        ref.watch(selectedAccountCurrentMonthDailyBalanceProvider);
    final transactions = ref.watch(selectedAccountLastTransactions);
    final currencyState = ref.watch(currencyStateNotifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          account?.name ?? "",
          style: const TextStyle(color: white),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        elevation: 0,
        iconTheme: const IconThemeData(color: white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: Sizes.md),
              color: Theme.of(context).colorScheme.secondary,
              child: Column(
                children: [
                  Text(
                    account?.total?.toCurrency() ?? "",
                    style: const TextStyle(
                      color: white,
                      fontSize: 32.0,
                      fontFamily: 'SF Pro Text',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Padding(padding: EdgeInsets.all(Sizes.sm)),
                  Padding(
                    padding: const EdgeInsets.all(Sizes.sm),
                    child: LineChartWidget(
                      lineData: accountTransactions,
                      colorBackground: Theme.of(context).colorScheme.secondary,
                      period: Period.month,
                      minY: 0,
                    ),
                  ),
                ],
              ),
            ),
            Card(
              margin: const EdgeInsets.all(Sizes.lg),
              child: Padding(
                padding: const EdgeInsets.all(Sizes.lg),
                child: Column(
                  children: [
                    Row(
                      spacing: 8,
                      children: [
                        const Icon(Icons.info_outline),
                        Text("Balance Discrepancy?"),
                      ],
                    ),
                    const SizedBox(height: Sizes.sm),
                    Text(
                        "Your recorder balance might differ from your bank's statement. Tap below to manually adjust your balance and keep your records accurate."),
                    const SizedBox(height: Sizes.lg),
                    if (isRecoinciling)
                      Column(
                        children: [
                          TextField(
                            focusNode: _focusNode,
                            controller: _newBalanceController,
                            decoration: InputDecoration(
                                hintText: "New Balance",
                                border: OutlineInputBorder(),
                                prefixIcon: SizedBox(
                                  width: 40,
                                  child: Center(
                                    child: Text(
                                      currencyState.selectedCurrency.symbol,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                  ),
                                )),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: <TextInputFormatter>[
                              DecimalTextInputFormatter(decimalDigits: 2),
                            ],
                          ),
                          const SizedBox(height: Sizes.lg),
                          Row(
                            spacing: 8,
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                      iconColor: Colors.white,
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            Sizes.borderRadius),
                                      ),
                                      backgroundColor: Colors.green),
                                  onPressed: () async {
                                    if (account != null) {
                                      await ref
                                          .read(accountsProvider.notifier)
                                          .reconcileAccount(
                                              newBalance: _newBalanceController
                                                  .text
                                                  .toNum(),
                                              account: account);
                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                      }
                                    }
                                  },
                                  label: const Text("Save"),
                                  icon: const Icon(Icons.check),
                                ),
                              ),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                      iconColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            Sizes.borderRadius),
                                      ),
                                      foregroundColor: Colors.red,
                                      backgroundColor: Colors.transparent),
                                  onPressed: () =>
                                      setState(() => isRecoinciling = false),
                                  label: const Text(
                                    "Cancel",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  icon: const Icon(Icons.cancel_outlined),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    else
                      TextButton.icon(
                          onPressed: () {
                            setState(() => isRecoinciling = true);
                            _focusNode.requestFocus();
                          },
                          icon: const Icon(Icons.sync),
                          label: Text(
                            "Start Reconciliation",
                            style: Theme.of(context).textTheme.bodyMedium,
                          )),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: Sizes.lg, bottom: Sizes.sm, top: Sizes.sm),
              child: Text("Your last transactions",
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            TransactionsList(
              transactions: transactions
                  .map((json) => Transaction.fromJson(json))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
