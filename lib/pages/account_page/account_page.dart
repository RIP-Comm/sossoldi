import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/functions.dart';
import '../../constants/style.dart';
import '../../custom_widgets/line_chart.dart';
import '../../custom_widgets/transactions_list.dart';
import '../../providers/accounts_provider.dart';
import '../../model/transaction.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AccountPage();
}

class _AccountPage extends ConsumerState<AccountPage> with Functions {
  @override
  Widget build(BuildContext context) {
    final account = ref.read(selectedAccountProvider);
    final accountTransactions =
        ref.watch(selectedAccountCurrentMonthDailyBalanceProvider);
    final transactions = ref.watch(selectedAccountLastTransactions);

    return Scaffold(
      appBar: AppBar(
          title:
              Text(account?.name ?? "", style: const TextStyle(color: white)),
          backgroundColor: blue5,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              color: blue5,
              child: Column(
                children: [
                  Text(
                    numToCurrency(account?.total),
                    style: const TextStyle(
                      color: white,
                      fontSize: 32.0,
                      fontFamily: 'SF Pro Text',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Padding(padding: EdgeInsets.all(8.0)),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: LineChartWidget(
                      line1Data: accountTransactions,
                      colorLine1Data: const Color(0xffffffff),
                      line2Data: const <FlSpot>[],
                      colorLine2Data: const Color(0xffffffff),
                      colorBackground: blue5,
                      period: Period.month,
                      minY: 0,
                    ),
                  ),
                ],
              ),
            ),
            Container(
                padding: const EdgeInsets.only(top: 40.0),
                child: TransactionsList(
                    transactions: transactions
                        .map((json) => Transaction.fromJson(json))
                        .toList())),
          ],
        ),
      ),
    );
  }
}
