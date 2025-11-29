import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/constants.dart';
import '../../../constants/style.dart';
import '../../../model/category_transaction.dart';
import '../../../model/transaction.dart';

import '../../../model/recurring_transaction.dart';
import '../../../providers/categories_provider.dart';
import '../../../providers/currency_provider.dart';
import '../../../services/transactions/recurring_transaction_calculator.dart';
import '../../../ui/device.dart';
import '../../../ui/extensions.dart';
import '../../../ui/widgets/default_container.dart';
import '../../../ui/widgets/rounded_icon.dart';

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
              0.0,
              (previousValue, element) => previousValue + element.amount,
            );
          });
        });

    _generateDataBasedOnRecurrentType();
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

  @override
  Widget build(BuildContext context) {
    final currencyState = ref.watch(currencyStateNotifier);
    final categories = ref.watch(categoriesProvider).value;
    final category = categories?.firstWhereOrNull(
      (element) => element.id == widget.transaction.idCategory,
    );

    // Handle null category case
    if (category == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Older payments"), centerTitle: true),
        body: const Center(child: Text("Category not found")),
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
              const SizedBox(width: Sizes.sm),
              const Icon(Icons.arrow_back_ios),
              Text(
                "Back",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(color: darkBlue5),
              ),
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
            Builder(
              builder: (ctx) {
                var recurrence = parseRecurrence(widget.transaction.recurrency);
                final label = recurrenceMap[recurrence]!.label;
                return Text(
                  "$label"
                  " on the ${ordinal(int.parse(getNextDueDay()))} day",
                  style: Theme.of(context).textTheme.bodyLarge,
                );
              },
            ),
            const SizedBox(height: Sizes.xl),
            yearlyTotal.isNotEmpty
                ? Expanded(
                    child: ListView.separated(
                      itemCount: yearlyTotal.length,
                      itemBuilder: (ctx, index) {
                        var years = yearlyTotal.keys.toList();
                        var year = years[index];
                        var totalyealyAmt = yearlyTotal[year];
                        var monthlyEntries = groupedMonthlyTransaction.entries
                            .where((m) {
                              return m.key.year == year;
                            })
                            .toList();

                        return DefaultContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: Row(
                                  children: [
                                    Text(
                                      '$year',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge,
                                    ),
                                    const Spacer(),
                                    _buildAmountText(
                                      context,
                                      totalyealyAmt,
                                      currencyState.selectedCurrency.symbol,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: Sizes.sm),
                              monthlyEntries.isNotEmpty
                                  ? Container(
                                      padding: const EdgeInsets.all(Sizes.md),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(
                                          Sizes.borderRadius,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          Sizes.borderRadius,
                                        ),
                                        child: ListView.separated(
                                          shrinkWrap: true,
                                          itemCount: monthlyEntries.length,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder: (ctx, index) {
                                            var date =
                                                monthlyEntries[index].key;

                                            var month = months[date.month - 1];
                                            var day = date.day;
                                            var montlyAmt =
                                                groupedMonthlyTransaction[date];

                                            return Container(
                                              padding: const EdgeInsets.all(
                                                Sizes.md,
                                              ),
                                              child: Row(
                                                children: [
                                                  Text('$day'),
                                                  const SizedBox(
                                                    width: Sizes.xs,
                                                  ),
                                                  Text(month),
                                                  const Spacer(),
                                                  _buildAmountText(
                                                    context,
                                                    montlyAmt,
                                                    currencyState
                                                        .selectedCurrency
                                                        .symbol,
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          separatorBuilder: (ctx, index) {
                                            return const SizedBox(
                                              height: Sizes.xxs,
                                              child: Divider(thickness: 0.3),
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: double.infinity,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface,
                                      child: Center(
                                        child: Text(
                                          "No Montly payment history",
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (crx, index) {
                        return SizedBox(
                          height: Sizes.lg,
                          child: Container(color: Colors.white),
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
                  ),
          ],
        ),
      ),
    );
  }

  void _generateDataBasedOnRecurrentType() {
    var startDate = widget.transaction.fromDate;
    var endDate = widget.transaction.toDate ?? DateTime.now();
    var recurrency = widget.transaction.recurrency;
    switch (recurrency) {
      case "MONTHLY":
        RecurringTransactionCalculator.generateRecurringTransactionMonthly(
          startDate: startDate,
          endDate: endDate,
          amount: widget.transaction.amount,
          groupedMonthlyTransaction: groupedMonthlyTransaction,
          yearlyTotal: yearlyTotal,
        );
        break;
      case "BIMONTHLY":
        RecurringTransactionCalculator.generateRecurringTransactionBiMonthly(
          startDate: startDate,
          endDate: endDate,
          amount: widget.transaction.amount,
          groupedMonthlyTransaction: groupedMonthlyTransaction,
          yearlyTotal: yearlyTotal,
        );
        break;
      case "QUARTERLY":
        RecurringTransactionCalculator.generateRecurringTransactionQuarterly(
          startDate: startDate,
          endDate: endDate,
          amount: widget.transaction.amount,
          groupedMonthlyTransaction: groupedMonthlyTransaction,
          yearlyTotal: yearlyTotal,
        );
        break;
      case "SEMESTER":
        RecurringTransactionCalculator.generateRecurringTransactionSemester(
          startDate: startDate,
          endDate: endDate,
          amount: widget.transaction.amount,
          groupedMonthlyTransaction: groupedMonthlyTransaction,
          yearlyTotal: yearlyTotal,
        );
        break;

      case "ANNUAL":
        RecurringTransactionCalculator.generateRecurringTransactionAnnually(
          startDate: startDate,
          endDate: endDate,
          amount: widget.transaction.amount,
          groupedMonthlyTransaction: groupedMonthlyTransaction,
          yearlyTotal: yearlyTotal,
        );
        break;
      case "DAILY":
        RecurringTransactionCalculator.generateRecurringTransactionDaily(
          startDate: startDate,
          endDate: endDate,
          amount: widget.transaction.amount,
          groupedMonthlyTransaction: groupedMonthlyTransaction,
          yearlyTotal: yearlyTotal,
        );
        break;
      case "WEEKLY":
        RecurringTransactionCalculator.generateRecurringTransactionWeekly(
          startDate: startDate,
          endDate: endDate,
          amount: widget.transaction.amount,
          groupedMonthlyTransaction: groupedMonthlyTransaction,
          yearlyTotal: yearlyTotal,
        );
        break;
    }
  }

  String getNextDueDay() {
    final now = DateTime.now();
    final daysPassed = now
        .difference(
          widget.transaction.lastInsertion ?? widget.transaction.fromDate,
        )
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

  // Reusable amount display
  Widget _buildAmountText(
    BuildContext context,
    num? amount,
    String currencySymbol,
  ) {
    final prefix = widget.transaction.type == TransactionType.expense
        ? "-"
        : "";
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
  const _CategoryHeader({
    required this.category,
    required this.transaction,
    required this.currencyState,
  });

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
          backgroundColor: categoryColorList[category.color],
          padding: const EdgeInsets.all(Sizes.sm),
          size: 56,
        ),
        const SizedBox(height: Sizes.sm),
        Text(transaction.note, style: Theme.of(context).textTheme.titleLarge),
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
