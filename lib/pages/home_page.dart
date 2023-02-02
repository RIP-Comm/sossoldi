import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../custom_widgets/transactions_list.dart';
import '../constants/functions.dart';
import '../providers/transactions_provider.dart';
import '../custom_widgets/budget_circular_indicator.dart';
import '../providers/accounts_provider.dart';
import '../constants/style.dart';
import '../model/bank_account.dart';
import '../custom_widgets/accounts_sum.dart';
import '../custom_widgets/line_chart.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with Functions {

  @override
  Widget build(BuildContext context) {
    final accountList = ref.watch(accountsProvider);
    final transactionList = ref.watch(transactionsProvider);
    return ListView(
      children: [
        Column(
          children: [
            const SizedBox(height: 24),
            Row(
              children: [
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "MONTHLY BALANCE",
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: Theme.of(context).colorScheme.primary),
                    ),
                    RichText(
                      textScaleFactor: MediaQuery.of(context).textScaleFactor,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: numToCurrency(-1536.65),
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(color: Theme.of(context).colorScheme.primary),
                          ),
                          TextSpan(
                            text: "€",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: Theme.of(context).colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "INCOME",
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    RichText(
                      textScaleFactor: MediaQuery.of(context).textScaleFactor,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: numToCurrency(1050.65),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: green),
                          ),
                          TextSpan(
                            text: "€",
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: green),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "EXPENSES",
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    RichText(
                      textScaleFactor: MediaQuery.of(context).textScaleFactor,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: numToCurrency(-1050.65),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: red),
                          ),
                          TextSpan(
                            text: "€",
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const LineChartWidget(
              line1Data: [
                FlSpot(0, 3),
                FlSpot(1, 1.3),
                FlSpot(2, -2),
                FlSpot(3, -4.5),
                FlSpot(4, -5),
                FlSpot(5, -2.2),
                FlSpot(6, -3.1),
                FlSpot(7, -0.2),
                FlSpot(8, -4),
                FlSpot(9, -3),
                FlSpot(10, -2),
                FlSpot(11, -4),
                FlSpot(12, 3),
                FlSpot(13, 1.3),
                FlSpot(14, -2),
                FlSpot(15, -4.5),
                FlSpot(16, 2.5),
              ],
              colorLine1Data: Color(0xff00152D),
              line2Data: [
                FlSpot(0, -3),
                FlSpot(1, -1.3),
                FlSpot(2, 2),
                FlSpot(3, 4.5),
                FlSpot(4, 5),
                FlSpot(5, 2.2),
                FlSpot(6, 3.1),
                FlSpot(7, 0.2),
                FlSpot(8, 4),
                FlSpot(9, 3),
                FlSpot(10, 2),
                FlSpot(11, 4),
                FlSpot(12, -3),
                FlSpot(13, -1.3),
                FlSpot(14, 2),
                FlSpot(15, 4.5),
                FlSpot(16, 5),
                FlSpot(17, 2.2),
                FlSpot(18, 3.1),
                FlSpot(19, 0.2),
                FlSpot(20, 4),
                FlSpot(21, 3),
                FlSpot(22, 2),
                FlSpot(23, 4),
                FlSpot(24, -3),
                FlSpot(25, -1.3),
                FlSpot(26, 2),
                FlSpot(27, 4.5),
                FlSpot(28, 5),
                FlSpot(29, 4.7),
                FlSpot(30, 1),
              ],
              colorLine2Data: Color(0xffB9BABC),
              colorBackground: Color(0xffF1F5F9),
              maxY: 5.0,
              minY: -5.0,
              maxDays: 31.0,
            ),
            Row(
              children: [
                const SizedBox(width: 16),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  "Current month",
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: grey2,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  "Last month",
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 22),
          ],
        ),
        Container(
          decoration: const BoxDecoration(
            color: white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  "Your accounts",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              SizedBox(
                height: 85.0,
                child: accountList.when(
                  data: (accounts) => ListView.builder(
                    itemCount: accounts.length + 1,
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, i) {
                      if (i == accounts.length) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [defaultShadow],
                            ),
                            child: TextButton.icon(
                              style: ButtonStyle(
                                maximumSize: MaterialStateProperty.all(const Size(130, 48)),
                                backgroundColor: MaterialStateProperty.all(
                                    Theme.of(context).colorScheme.surface),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                              icon: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: grey1,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Icon(
                                    Icons.add_rounded,
                                    size: 24.0,
                                    color: Theme.of(context).colorScheme.surface,
                                  ),
                                ),
                              ),
                              label: Text(
                                "New Account",
                                style:
                                    Theme.of(context).textTheme.bodyLarge!.copyWith(color: grey1),
                                maxLines: 2,
                              ),
                              onPressed: () {
                                // TODO: Navigate to the page to add account
                              },
                            ),
                          ),
                        );
                      } else {
                        BankAccount account = accounts[i];
                        return AccountsSum(accountName: account.name, amount: account.value);
                      }
                    },
                  ),
                  loading: () => const SizedBox(),
                  error: (err, stack) => Text('Error: $err'),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
                  child: Text(
                    "Last transactions",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              transactionList.when(
                data: (transactions) => TransactionsList(transactions: transactions),
                loading: () => const SizedBox(),
                error: (err, stack) => Text('Error: $err'),
              ),
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    "Your budgets",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    BudgetCircularIndicator(
                      title: "TOTALE",
                      amount: 320,
                      perc: 0.25,
                      color: Color(0xFFEBC35F),
                    ),
                    BudgetCircularIndicator(
                      title: "SPESE",
                      amount: 500,
                      perc: 0.5,
                      color: Color(0xFFD336B6),
                    ),
                    BudgetCircularIndicator(
                      title: "SVAGO",
                      amount: 178.67,
                      perc: 0.88,
                      color: Color(0xFF8E5FEB),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ],
    );
  }
}
