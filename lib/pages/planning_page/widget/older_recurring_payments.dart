import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import '../../../constants/constants.dart';
import '../../../custom_widgets/rounded_icon.dart';
import '../../../model/transaction.dart';
import 'package:intl/intl.dart';

import '../../../model/recurring_transaction.dart';
import '../../../providers/categories_provider.dart';
import '../../../providers/currency_provider.dart';

class OlderRecurringPayments extends ConsumerStatefulWidget {
  final RecurringTransaction transaction;
  const OlderRecurringPayments({super.key, required this.transaction});

  @override
  ConsumerState<OlderRecurringPayments> createState() => _OlderRecurringPaymentsState();
}

class _OlderRecurringPaymentsState extends ConsumerState<OlderRecurringPayments> {
  List<Transaction>? transactions;
  num sum = 0.0;

  @override
  void initState() {
    super.initState();
    TransactionMethods()
        .getRecurrenceTransactionsById(id: widget.transaction.id)
        .then((value) {
      setState(() {
        transactions = value;
        sum = value.fold(
            0.0, (previousValue, element) => previousValue + element.amount);
      });
    });
  }

  String getNextText() {
    final now = DateTime.now();
    final daysPassed = now
        .difference(widget.transaction.lastInsertion ?? widget.transaction.fromDate)
        .inDays;
    final daysInterval =
        recurrenceMap[parseRecurrence(widget.transaction.recurrency)]!.days;
    final daysUntilNextTransaction = daysInterval - (daysPassed % daysInterval);
    return daysUntilNextTransaction.toString();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider).value;
    final category = categories?.firstWhere(
          (element) => element.id == widget.transaction.idCategory,// Prevents crashing if the category is not found
    );
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    // var cat = categories
    //     ?.firstWhere((element) => element.id == transaction.idCategory);
    final currencyState = ref.watch(currencyStateNotifier);
    Map<int, List<Transaction>> transactionsByYear = {};
    if (transactions != null) {
      for (var transaction in transactions!) {
        int year = transaction.date.year;
        if (!transactionsByYear.containsKey(year)) {
          transactionsByYear[year] = [];
        }
        transactionsByYear[year]!.add(transaction);
      }
    }

    return Column(
      children: [
        // Back and Older Payments Row
        Container(
         // color: Color(0xFFF5F5F5),
          padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xFF356CA3),
                ),
              ),
              Text(
                'Back',
                style: TextStyle(
                  color: Color(0xFF356CA3),
                  fontSize: 20.0,
                  fontFamily: "NunitoSans",
                ),
              ),
              SizedBox(width: 25.0),
              Text(
                'Older Payments',
                style: TextStyle(
                  color: Color(0xFF00152D),
                  fontSize: 20.0,
                  fontFamily: "NunitoSans",
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 25.0),

        Row(
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: RoundedIcon(
                      icon: category != null
                          ? iconList[category.symbol]
                          : Icons.abc,
                      backgroundColor: category != null
                          ? categoryColorListTheme[category.color]
                          : Colors.grey,
                      size: 40.0,
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(width: 10),
                      Text(
                        widget.transaction.note,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      SizedBox(width: 10),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC52626),
                          ),
                          children: [
                            TextSpan(
                              text: "-${sum.toStringAsFixed(2)}",
                              style: const TextStyle(fontSize: 40),
                            ),
                            TextSpan(
                              text: "${currencyState.selectedCurrency.symbol}",
                              style: const TextStyle(fontSize: 25),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      SizedBox(width: 10),
                      if (widget.transaction.recurrency == "MONTHLY") ...[
                        // Display the first RichText if recurrency is "MONTHLY"
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Color(0xFF00152D)),
                            children: [
                              TextSpan(
                                text: "${widget.transaction.recurrency}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "NunitoSans",
                                ),
                              ),
                              TextSpan(
                                text: " - On the ",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "NunitoSans",
                                ),
                              ),
                              TextSpan(
                                text: getDayWithSuffix(widget.transaction.fromDate.day),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "NunitoSans",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else if (int.parse(getNextText()) == 1) ...[
                        // If next transaction is in exactly 1 day, display this
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Color(0xFF00152D)),
                            children: [
                              TextSpan(
                                text: "${widget.transaction.recurrency}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "NunitoSans",
                                ),
                              ),
                              TextSpan(
                                text: " - In ${getNextText()} day",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "NunitoSans",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // For other recurrencies, display this RichText with plural days
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Color(0xFF00152D)),
                            children: [
                              TextSpan(
                                text: "${widget.transaction.recurrency}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "NunitoSans",
                                ),
                              ),
                              TextSpan(
                                text: " - In ${getNextText()} days",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "NunitoSans",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),


                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [],
              ),
            )
          ],
        ),

        SizedBox(height: 20),

        // Display loading, empty message, or transactions
        if (transactions == null)
          const CircularProgressIndicator()
        else if (transactions!.isEmpty)
          const Text(
            "All recurring payments will be displayed here",
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 13,
            ),
          )
        else
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: transactionsByYear.entries.map((entry) {
                int year = entry.key;
                List<Transaction> transactionsOfYear = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Year Container with Rounded Corners
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                year.toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "NunitoSans",
                                ),
                              ),
                              SizedBox(width: 0.5 * MediaQuery.of(context).size.width),
                              RichText(
                                text: TextSpan(
                                  text: "-${sum.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFC52626),
                                    fontFamily: "NunitoSans",
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                      " ${currencyState.selectedCurrency.symbol}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFC52626),
                                        fontFamily: "NunitoSans",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),

                          // Monthly Transactions
                          Column(
                            children: transactionsOfYear.map((transaction) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 15),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  DateFormat('d')
                                                      .format(transaction.date),
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: "NunitoSans",
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  DateFormat('MMMM')
                                                      .format(transaction.date),
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: "NunitoSans",
                                                  ),
                                                ),
                                              ],
                                            ),
                                            RichText(
                                              text: TextSpan(
                                                text:
                                                "- ${transaction.amount.toStringAsFixed(2)}",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFFC52626),
                                                  fontFamily: "NunitoSans",
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text:
                                                    " ${currencyState.selectedCurrency.symbol}",
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                      color: Color(0xFFC52626),
                                                      fontFamily: "NunitoSans",
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Divider: Only if there are 2 or more transactions
                                        if (transactionsOfYear.length > 1)
                                          Divider(
                                            color: Colors.black45,
                                            thickness: 1,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  String getDayWithSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return '$day' + 'th'; // Special case for 11, 12, 13
    }
    switch (day % 10) {
      case 1:
        return '$day' + 'st';
      case 2:
        return '$day' + 'nd';
      case 3:
        return '$day' + 'rd';
      default:
        return '$day' + 'th';
    }
  }

}

