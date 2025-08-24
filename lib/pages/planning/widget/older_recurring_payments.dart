import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/constants.dart';
import '../../../constants/style.dart';
import '../../../model/category_transaction.dart';
import '../../../model/transaction.dart';
import 'package:intl/intl.dart';

import '../../../model/recurring_transaction.dart';
import '../../../providers/categories_provider.dart';
import '../../../providers/currency_provider.dart';
import '../../../ui/device.dart';
import '../../../ui/extensions.dart';
import '../../../ui/widgets/default_container.dart';
import '../../../ui/widgets/rounded_icon.dart';
import '../../../ui/widgets/transactions_list.dart';
import '../../transactions/widgets/list_tab.dart';

class OlderRecurringPayments extends ConsumerStatefulWidget {
  final RecurringTransaction transaction;
  const OlderRecurringPayments({super.key, required this.transaction});

  @override
  ConsumerState<OlderRecurringPayments> createState() =>
      _OlderRecurringPaymentsState();
}

class _OlderRecurringPaymentsState
    extends ConsumerState<OlderRecurringPayments> {
  List<Transaction>? transactions;
  num sum = 0.0;
  Map<DateTime, num> groupedMonthlyTransaction = {};
  Map<int, num> yearlyTotal = {};

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

    _generateDataBasedOnRecurrentType();
  }

  void _generateDataBasedOnRecurrentType() {
    var startDate = widget.transaction.fromDate;
    var endDate = widget.transaction.toDate ?? DateTime.now();
    var recurrency = widget.transaction.recurrency;
    switch (recurrency) {
      case "MONTHLY":
        generateRecurringTransactionMonthly(
          startDate: startDate,
          endDate: endDate,
          amount: widget.transaction.amount,
        );
        break;
      case "BIMONTHLY":
        generateRecurringTransactionBiMonthly(
            startDate: startDate,
            endDate: endDate,
            amount: widget.transaction.amount);
        break;
      case "QUARTERLY":
        generateRecurringTransactionQuarterly(
            startDate: startDate,
            endDate: endDate,
            amount: widget.transaction.amount);
        break;
      case "SEMESTER":
        generateRecurringTransactionSemester(
            startDate: startDate,
            endDate: endDate,
            amount: widget.transaction.amount);
        break;

      case "ANNUAL":
        generateRecurringTransactionAnnually(
            startDate: startDate,
            endDate: endDate,
            amount: widget.transaction.amount);
        break;
      case "DAILY":
        generateRecurringTransactionDaily(
            startDate: startDate,
            endDate: endDate,
            amount: widget.transaction.amount);
        break;
      case "WEEKLY":
    }
  }

  String getNextDueDay() {
    final now = DateTime.now();
    final daysPassed = now
        .difference(
            widget.transaction.lastInsertion ?? widget.transaction.fromDate)
        .inDays;
    final daysInterval =
        recurrenceMap[parseRecurrence(widget.transaction.recurrency)]!.days;
    final daysUntilNextTransaction = daysInterval - (daysPassed % daysInterval);
    return daysUntilNextTransaction.toString();
  }

  String ordinal(int number) {
    if (number >= 11 && number <= 13) {
      return '${number}th';
    }
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  var months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  void generateRecurringTransactionMonthly({
    required DateTime startDate, // dec 31st 2022
    required DateTime endDate, //dec 24 2023
    required num amount,
  }) {
    //clear first
    groupedMonthlyTransaction.clear();
    yearlyTotal.clear();

    DateTime current = startDate; //

    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      DateTime monthKey = DateTime(current.year, current.month, current.day);

      // Store monthly recurring amount
      groupedMonthlyTransaction[monthKey] =
          (groupedMonthlyTransaction[monthKey] ?? 0) + amount;

      // Handle month overflow properly
      if (current.month == 12) {
        current = DateTime(current.year + 1, 1, current.day); // jan 31
      } else {
        // Check if the day exists in the next month
        int nextMonth = current.month + 1; //feb
        int year = current.year; //2023
        int day = current.day; //31

        // Handle cases where day doesn't exist in next month (e.g., Jan 31 -> Feb 31)
        int daysInNextMonth = DateTime(year, nextMonth + 1, 0).day; //28
        if (day > daysInNextMonth) {
          day = daysInNextMonth;
        } else if (day != startDate.day) {
          day = startDate.day;
        }

        current = DateTime(year, nextMonth, day);
      }
    }
    for (var entry in groupedMonthlyTransaction.entries) {
      int year = entry.key.year;
      yearlyTotal[year] = (yearlyTotal[year] ?? 0) + entry.value;
    }
  }

  void generateRecurringTransactionBiMonthly({
    required DateTime startDate,
    required DateTime endDate,
    required num amount,
  }) {
    groupedMonthlyTransaction.clear();
    yearlyTotal.clear();

    DateTime current = startDate;

    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      DateTime monthKey = DateTime(current.year, current.month, current.day);

      // store transaction
      groupedMonthlyTransaction[monthKey] =
          (groupedMonthlyTransaction[monthKey] ?? 0) + amount;

      // calculate next bi-monthly date
      int nextMonth = current.month + 2;
      int year = current.year;

      // adjust year/month if overflow
      if (nextMonth > 12) {
        year += (nextMonth - 1) ~/ 12;
        nextMonth = ((nextMonth - 1) % 12) + 1;
      }

      // pick correct day
      int daysInTargetMonth = DateTime(year, nextMonth + 1, 0).day;
      int desiredDay =
          startDate.day; // always try to use the original start day

      int day = desiredDay <= daysInTargetMonth
          ? desiredDay
          : daysInTargetMonth; // clamp only if necessary

      current = DateTime(year, nextMonth, day);
    }

    // build yearly totals
    for (var entry in groupedMonthlyTransaction.entries) {
      var year = entry.key.year;
      yearlyTotal[year] = (yearlyTotal[year] ?? 0) + entry.value;
    }
  }

  void generateRecurringTransactionQuarterly({
    required DateTime startDate,
    required DateTime endDate,
    required num amount,
  }) {
    groupedMonthlyTransaction.clear();
    yearlyTotal.clear();

    DateTime current = startDate;

    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      // Insert or accumulate safely
      groupedMonthlyTransaction[current] =
          (groupedMonthlyTransaction[current] ?? 0) + amount;

      // Calculate next quarterly date (+3 months, clamped)
      int nextMonth = current.month + 3;
      int year = current.year;

      if (nextMonth > 12) {
        year += (nextMonth - 1) ~/ 12;
        nextMonth = ((nextMonth - 1) % 12) + 1;
      }

      int daysInTargetMonth = DateTime(year, nextMonth + 1, 0).day;
      int desiredDay = startDate.day;

      int day =
          desiredDay <= daysInTargetMonth ? desiredDay : daysInTargetMonth;

      current = DateTime(year, nextMonth, day);
    }

    // Build yearly totals
    for (var entry in groupedMonthlyTransaction.entries) {
      var year = entry.key.year;
      yearlyTotal[year] = (yearlyTotal[year] ?? 0) + entry.value;
    }
  }

  void generateRecurringTransactionSemester({
    required DateTime startDate,
    required DateTime endDate,
    required num amount,
  }) {
    groupedMonthlyTransaction.clear();
    yearlyTotal.clear();

    DateTime current = startDate;

    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      // Insert or accumulate safely
      groupedMonthlyTransaction[current] =
          (groupedMonthlyTransaction[current] ?? 0) + amount;

      // Calculate next semester date (+6 months, clamped)
      int nextMonth = current.month + 6;
      int year = current.year;

      if (nextMonth > 12) {
        year += (nextMonth - 1) ~/ 12;
        nextMonth = ((nextMonth - 1) % 12) + 1;
      }

      int daysInTargetMonth = DateTime(year, nextMonth + 1, 0).day;
      int desiredDay = startDate.day;

      int day =
          desiredDay <= daysInTargetMonth ? desiredDay : daysInTargetMonth;

      current = DateTime(year, nextMonth, day);
    }

    // Build yearly totals
    for (var entry in groupedMonthlyTransaction.entries) {
      var year = entry.key.year;
      yearlyTotal[year] = (yearlyTotal[year] ?? 0) + entry.value;
    }
  }

  void generateRecurringTransactionAnnually(
      {required DateTime startDate,
      required DateTime endDate,
      required num amount}) {
    groupedMonthlyTransaction.clear();
    yearlyTotal.clear();
    DateTime current = startDate;

    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      DateTime dateKey = DateTime(current.year, current.month, current.day);
      yearlyTotal[current.year] = (yearlyTotal[current.year] ?? 0) + amount;
      current = DateTime(current.year + 1, current.month, current.day);
    }
  }

  void generateRecurringTransactionDaily(
      {required DateTime startDate,
      required DateTime endDate,
      required num amount}) {
    //clear first
    groupedMonthlyTransaction.clear();
    yearlyTotal.clear();

    DateTime current = startDate;

    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      DateTime monthKey = DateTime(current.year, current.month, current.day);

      var days = daysInMonth(current.year, current.month);
      num monthlyTotal = days * amount;
      // Store monthly recurring amount
      groupedMonthlyTransaction[monthKey] = monthlyTotal;

      // Handle month overflow properly
      if (current.month == 12) {
        current = DateTime(current.year + 1, 1, current.day); // jan 31
      } else {
        // Check if the day exists in the next month
        int nextMonth = current.month + 1; //feb
        int year = current.year; //2023
        int day = current.day; //31

        // Handle cases where day doesn't exist in next month (e.g., Jan 31 -> Feb 31)
        int daysInNextMonth = DateTime(year, nextMonth + 1, 0).day; //28
        if (day > daysInNextMonth) {
          day = daysInNextMonth;
        } else if (day != startDate.day) {
          day = startDate.day;
        }

        current = DateTime(year, nextMonth, day);
      }
    }
    for (var entry in groupedMonthlyTransaction.entries) {
      int year = entry.key.year;
      yearlyTotal[year] = (yearlyTotal[year] ?? 0) + entry.value;
    }
  }

  int daysInMonth(int year, int month) {
    // Go to the next month, then subtract 1 day
    var lastDay = DateTime(year, month + 1, 0);
    return lastDay.day;
  }

  @override
  Widget build(BuildContext context) {
    final currencyState = ref.watch(currencyStateNotifier);
    final categories = ref.watch(categoriesProvider).value;
    final category = categories?.firstWhereOrNull(
        (element) => element.id == widget.transaction.idCategory);

    // Handle null category case
    if (category == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Older payments"),
          centerTitle: true,
        ),
        body: Center(
          child: Text("Category not found"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Older payments"),
        centerTitle: true,
        backgroundColor: grey3,
        leadingWidth: 80.0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Row(
            children: [
              const SizedBox(
                width: Sizes.sm,
              ),
              const Icon(Icons.arrow_back_ios),
              Text(
                "Back",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: darkBlue5,
                    ),
              )
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Sizes.lg),
            _CategoryHeader(
              category: category,
              transaction: widget.transaction,
              currencyState: currencyState,
            ),
            const SizedBox(height: Sizes.sm),
            Builder(builder: (ctx) {
              var recurrence = parseRecurrence(widget.transaction.recurrency);
              final label = recurrenceMap[recurrence]!.label;
              return Text(
                "$label"
                " on the ${ordinal(int.parse(getNextDueDay()))}",
                style: Theme.of(context).textTheme.bodyLarge,
              );
            }),
            const SizedBox(height: Sizes.xl),
            yearlyTotal.isNotEmpty
                ? Expanded(
                    child: ListView.separated(
                      itemCount: yearlyTotal.length,
                      itemBuilder: (ctx, index) {
                        var years = yearlyTotal.keys.toList();
                        var year = years[index];
                        var totalyealyAmt = yearlyTotal[year];
                        var monthlyEntries =
                            groupedMonthlyTransaction.entries.where((m) {
                          return m.key.year == year;
                        }).toList();

                        return DefaultContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: Row(children: [
                                  Text(
                                    '$year',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  const Spacer(),
                                  _buildAmountText(context, totalyealyAmt,
                                      currencyState.selectedCurrency.symbol)
                                ]),
                              ),
                              const SizedBox(
                                height: Sizes.sm,
                              ),
                              monthlyEntries.isNotEmpty
                                  ? Container(
                                      padding: EdgeInsets.all(Sizes.md),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        borderRadius: BorderRadius.circular(
                                            Sizes.borderRadius),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            Sizes.borderRadius),
                                        child: ListView.separated(
                                          shrinkWrap: true,
                                          itemCount: monthlyEntries.length,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemBuilder: (ctx, index) {
                                            var date =
                                                monthlyEntries[index].key;

                                            var month = months[date.month - 1];
                                            var day = date.day;
                                            var montlyAmt =
                                                groupedMonthlyTransaction[date];

                                            return Container(
                                              padding: EdgeInsets.all(Sizes.md),
                                              child: Row(
                                                children: [
                                                  Text('$day'),
                                                  SizedBox(width: Sizes.xs),
                                                  Text(month),
                                                  Spacer(),
                                                  _buildAmountText(
                                                      context,
                                                      montlyAmt,
                                                      currencyState
                                                          .selectedCurrency
                                                          .symbol),
                                                ],
                                              ),
                                            );
                                          },
                                          separatorBuilder: (ctx, index) {
                                            return const SizedBox(
                                              height: Sizes.xxs,
                                              child: Divider(
                                                thickness: 0.3,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: double.infinity,
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      child: Center(
                                        child: Text(
                                          "No Montly payment history",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ),
                                    )
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (crx, index) {
                        return SizedBox(
                          height: Sizes.lg,
                          child: Container(
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  )
                : Expanded(
                    child: Container(
                      width: double.infinity,
                      color: Theme.of(context).colorScheme.surface,
                      child: Center(
                        child: Text(
                          "No recurrent payment history",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                  )
          ],
        ),
      ),
    );
  }

  // Reusable amount display
  Widget _buildAmountText(
      BuildContext context, num? amount, String currencySymbol) {
    final prefix =
        widget.transaction.type == TransactionType.expense ? "-" : "";
    return Row(
      children: [
        Text(
          '$prefix${amount ?? 0}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: widget.transaction.type.toColor(
                  brightness: Theme.of(context).brightness,
                ),
              ),
        ),
        Text(
          currencySymbol,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: widget.transaction.type.toColor(
                  brightness: Theme.of(context).brightness,
                ),
              ),
        ),
      ],
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader(
      {required this.category,
      required this.transaction,
      required this.currencyState,
      super.key});

  final CategoryTransaction category;
  final RecurringTransaction transaction;
  final CurrencyState currencyState;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RoundedIcon(
          icon: iconList[category.symbol] ?? Icons.help_outline,
          backgroundColor: categoryColorList[category.color] ?? Colors.grey,
          padding: const EdgeInsets.all(Sizes.sm),
          size: 56,
        ),
        const SizedBox(
          height: Sizes.sm,
        ),
        Text(
          transaction.note,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: Sizes.sm),
        Text(
          "${transaction.type.prefix}"
          "${transaction.amount}"
          "${currencyState.selectedCurrency.symbol}",
          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                color: transaction.type.toColor(
                  brightness: Theme.of(context).brightness,
                ),
              ),
        ),
      ],
    );
  }
}
