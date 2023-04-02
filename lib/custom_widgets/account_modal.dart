import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sossoldi/custom_widgets/transactions_list.dart';
import '../constants/functions.dart';
import '../model/transaction.dart';
import '../providers/transactions_provider.dart';
import 'line_chart.dart';

class AccountDialog extends ConsumerStatefulWidget {
  final String accountName;
  final num amount;
  final id;

  const AccountDialog({super.key, required this.accountName, required this.amount, required this.id,});

  @override
  ConsumerState<AccountDialog> createState() => _AccountDialog();
}

class _AccountDialog extends ConsumerState<AccountDialog> with Functions {

  @override
  Widget build(BuildContext context) {
    final transactionList = ref.watch(transactionsProvider);

    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            color: const Color(0xff356CA3),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 12.0),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          widget.accountName,
                          style: const TextStyle(
                            color: Color(0xffffffff),
                            fontSize: 18.0,
                            fontFamily: 'SF Pro Text',
                          ),
                        ),
                        const Padding(padding: EdgeInsets.all(12)),
                        Text(
                          numToCurrency(widget.amount),
                          style: const TextStyle(
                            color: Color(0xffffffff),
                            fontSize: 32.0,
                            fontFamily: 'SF Pro Text',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 30.0),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                ),
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
                  colorLine1Data: Color(0xffffffff),
                  line2Data: <FlSpot>[],
                  colorLine2Data: Color(0xffffffff),
                  colorBackground: Color(0xff356CA3),
                  maxY: 5.0,
                  minY: -5.0,
                  maxDays: 30.0,
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 14.0),
                ),
              ],
            ),
          ),
          Card(
            color: const Color(0xffffffff),
            child: Column(children: [
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
                data: (transactions) => TransactionsList(transactions: transactions, id: widget.id,),
                loading: () => const SizedBox(),
                error: (err, stack) => Text('Error: $err'),
              ),
            ],)
          ),
        ],
      ),
    );
  }
}
