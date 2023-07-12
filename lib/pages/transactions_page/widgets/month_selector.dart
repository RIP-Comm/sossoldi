import 'package:flutter/material.dart';

import '../../../constants/style.dart';
import '../../../utils/formatted_date_range.dart';

class MonthSelector extends StatelessWidget {
  const MonthSelector({
    required this.amount,
    required this.startDate,
    required this.endDate,
    Key? key,
  }) : super(key: key);

  final double amount;
  final ValueNotifier<DateTime> startDate;
  final ValueNotifier<DateTime> endDate;
  final double height = 60;

  // last day of the month

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // pick range of dates
        DateTimeRange? range = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2010, 1, 1),
          lastDate: DateTime(2030, 12, 31),
          currentDate: DateTime.now(),
          initialDateRange: DateTimeRange(
            start: startDate.value,
            end: endDate.value,
          ),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              appBarTheme: Theme.of(context)
                  .appBarTheme
                  .copyWith(backgroundColor: blue1),
            ),
            child: child!,
          ),
        );
        if (range != null) {
          startDate.value = range.start;
          endDate.value = range.end;
        }
      },
      child: Container(
        clipBehavior: Clip.antiAlias, // force rounded corners on children
        height: height,
        decoration: const BoxDecoration(
          color: blue7,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                // move to previous month
                startDate.value = DateTime(startDate.value.year,
                    startDate.value.month - 1, startDate.value.day);
                endDate.value = DateTime(
                    startDate.value.year, startDate.value.month + 1, 0);
              },
              child: Container(
                height: height,
                width: height,
                color: Theme.of(context).colorScheme.primary,
                child: const Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                ),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: startDate,
              builder: (context, value, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      getFormattedDateRange(startDate.value, endDate.value),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      "$amount €",
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: (amount > 0) ? green : red),
                    ),
                  ],
                );
              },
            ),
            GestureDetector(
              onTap: () {
                // move to next month
                startDate.value = DateTime(startDate.value.year,
                    startDate.value.month + 1, startDate.value.day);
                endDate.value = DateTime(
                    startDate.value.year, startDate.value.month + 1, 0);
              },
              child: Container(
                height: height,
                width: height,
                color: Theme.of(context).colorScheme.primary,
                child: const Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
