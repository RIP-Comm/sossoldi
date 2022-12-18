import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthSelector extends StatelessWidget {
  MonthSelector({
    required this.amount,
    Key? key,
  }) : super(key: key);

  final double amount; // get from backend (Bloc) instead of from parent
  final double height = 60;

  final startDate = ValueNotifier<DateTime>(DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  )); // last day of the month
  final endDate = ValueNotifier<DateTime>(DateTime(
    DateTime.now().year,
    DateTime.now().month + 1,
    0,
  )); // last day of the month

  String getFormattedDate() {
    DateTime lastOfMonth =
        DateTime(startDate.value.year, startDate.value.month + 1, 0);

    if (startDate.value.day == 1 && endDate.value == lastOfMonth) {
      return DateFormat('MMMM yyyy').format(startDate.value);
    } else {
      final s = DateFormat('dd/MM/yy').format(startDate.value);
      final e = DateFormat('dd/MM/yy').format(endDate.value);
      return "$s - $e";
    }
  }

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
          color: Color(0xFFf1f5f9),
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
                color: Color(0xFF00152d),
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
                      getFormattedDate(),
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    Text(
                      "$amount €",
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: (amount > 0) ? Colors.green : Colors.red),
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
                color: Color(0xFF00152d),
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
