import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/style.dart';
import '../../../providers/currency_provider.dart';
import '../../../providers/transactions_provider.dart';
import '../../../ui/device.dart';
import '../../../ui/extensions.dart';
import '../../../ui/formatters/formatted_date_range.dart';
import '../../graphs/widgets/categories/categories_bar_chart.dart';

enum MonthSelectorType { simple, advanced } //advanced = with amount

class MonthSelector extends ConsumerWidget {
  const MonthSelector({required this.type, super.key});

  final MonthSelectorType type;
  final double height = 60;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalAmount = ref.watch(totalAmountProvider);
    final startDate = ref.watch(filterDateStartProvider);
    final endDate = ref.watch(filterDateEndProvider);
    final currencyState = ref.watch(currencyStateNotifier);

    double currentHeight = type == MonthSelectorType.advanced ? 60 : 30;

    return GestureDetector(
      onTap: () async {
        // pick range of dates
        DateTimeRange? range = await showDateRangePicker(
          context: context,
          firstDate: DateTime(1970, 1, 1),
          lastDate: DateTime(2100, 12, 31),
          currentDate: DateTime.now(),
          initialDateRange: DateTimeRange(start: startDate, end: endDate),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              appBarTheme: Theme.of(
                context,
              ).appBarTheme.copyWith(backgroundColor: blue1),
            ),
            child: child!,
          ),
        );
        if (range != null) {
          ref.read(filterDateStartProvider.notifier).state = range.start;
          ref.read(filterDateEndProvider.notifier).state = range.end;
          ref.read(highlightedMonthProvider.notifier).state =
              range.start.month - 1;
        }
      },
      child: Container(
        clipBehavior: Clip.antiAlias, // force rounded corners on children
        height: currentHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary,
          borderRadius: BorderRadius.circular(Sizes.borderRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                // move to previous month
                DateTime newStartDate = DateTime(
                  startDate.year,
                  startDate.month - 1,
                  1,
                );
                DateTime newEndDate = DateTime(
                  newStartDate.year,
                  newStartDate.month + 1,
                  0,
                );
                ref.read(filterDateStartProvider.notifier).state = newStartDate;
                ref.read(filterDateEndProvider.notifier).state = newEndDate;
                ref.read(transactionsProvider.notifier).filterTransactions();
                ref.read(highlightedMonthProvider.notifier).state =
                    newStartDate.month - 1;
              },
              child: Container(
                height: currentHeight,
                width: height,
                color: Theme.of(context).colorScheme.primary,
                child: Icon(
                  Icons.chevron_left,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  getFormattedDateRange(startDate, endDate),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (type == MonthSelectorType.advanced)
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: totalAmount.toCurrency(),
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(color: totalAmount.toColor()),
                        ),
                        TextSpan(
                          text: currencyState.selectedCurrency.symbol,
                          style: Theme.of(context).textTheme.labelLarge!
                              .copyWith(color: totalAmount.toColor()),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            GestureDetector(
              onTap: () {
                // move to next month
                DateTime newStartDate = DateTime(
                  startDate.year,
                  startDate.month + 1,
                  1,
                );
                DateTime newEndDate = DateTime(
                  newStartDate.year,
                  newStartDate.month + 1,
                  0,
                );
                ref.read(filterDateStartProvider.notifier).state = newStartDate;
                ref.read(filterDateEndProvider.notifier).state = newEndDate;
                ref.read(transactionsProvider.notifier).filterTransactions();
                ref.read(highlightedMonthProvider.notifier).state =
                    newStartDate.month - 1;
              },
              child: Container(
                height: currentHeight,
                width: height,
                color: Theme.of(context).colorScheme.primary,
                child: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
