class RecurringTransactionCalculator {
  static void generateRecurringTransactionMonthly(
      {required DateTime startDate,
      required DateTime endDate,
      required num amount,
      required Map<DateTime, num> groupedMonthlyTransaction,
      required Map<int, num> yearlyTotal}) {
    //clear first
    groupedMonthlyTransaction.clear();
    yearlyTotal.clear();

    DateTime current = startDate;

    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      DateTime monthKey = DateTime(current.year, current.month, current.day);

      // Store monthly recurring amount
      groupedMonthlyTransaction[monthKey] =
          (groupedMonthlyTransaction[monthKey] ?? 0) + amount;

      // Handle month overflow properly
      if (current.month == 12) {
        current = DateTime(current.year + 1, 1, current.day);
      } else {
        // Check if the day exists in the next month
        int nextMonth = current.month + 1;
        int year = current.year;
        int day = current.day;

        // Handle cases where day doesn't exist in next month (e.g., Jan 31 -> Feb 31)
        int daysInNextMonth = DateTime(year, nextMonth + 1, 0).day;
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

  static void generateRecurringTransactionBiMonthly(
      {required DateTime startDate,
      required DateTime endDate,
      required num amount,
      required Map<DateTime, num> groupedMonthlyTransaction,
      required Map<int, num> yearlyTotal}) {
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

      int daysInTargetMonth = DateTime(year, nextMonth + 1, 0).day;
      int desiredDay = startDate.day; // the original start day

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

  static void generateRecurringTransactionQuarterly(
      {required DateTime startDate,
      required DateTime endDate,
      required num amount,
      required Map<DateTime, num> groupedMonthlyTransaction,
      required Map<int, num> yearlyTotal}) {
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

  static void generateRecurringTransactionSemester(
      {required DateTime startDate,
      required DateTime endDate,
      required num amount,
      required Map<DateTime, num> groupedMonthlyTransaction,
      required Map<int, num> yearlyTotal}) {
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

  static void generateRecurringTransactionAnnually(
      {required DateTime startDate,
      required DateTime endDate,
      required num amount,
      required Map<DateTime, num> groupedMonthlyTransaction,
      required Map<int, num> yearlyTotal}) {
    groupedMonthlyTransaction.clear();
    yearlyTotal.clear();
    DateTime current = startDate;

    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      yearlyTotal[current.year] = (yearlyTotal[current.year] ?? 0) + amount;
      current = DateTime(current.year + 1, current.month, current.day);
    }
  }

  static void generateRecurringTransactionDaily(
      {required DateTime startDate,
      required DateTime endDate,
      required num amount,
      required Map<DateTime, num> groupedMonthlyTransaction,
      required Map<int, num> yearlyTotal}) {
    //clear first
    groupedMonthlyTransaction.clear();
    yearlyTotal.clear();

    DateTime current = startDate;
    int firstDayOfTheMonth = current.day; //starting day

    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      DateTime monthKey = DateTime(current.year, current.month, current.day);

      // current month last day
      var lastDayOfTheMonth = lastDayInTheMonth(endDate, current);

      num monthlyTotal = (lastDayOfTheMonth - firstDayOfTheMonth + 1) * amount;
      // Store monthly recurring amount
      groupedMonthlyTransaction[monthKey] = monthlyTotal;

      // Handle month overflow properly
      if (current.month == 12) {
        current = DateTime(current.year + 1, 1, current.day);
      } else {
        // Check if the day exists in the next month
        int nextMonth = current.month + 1;
        int year = current.year;
        int day = current.day;

        // Handle cases where day doesn't exist in next month (e.g., Jan 31 -> Feb 31)
        int daysInNextMonth = DateTime(year, nextMonth + 1, 0).day;
        if (day > daysInNextMonth) {
          day = daysInNextMonth;
        } else if (day != startDate.day) {
          day = startDate.day;
        }

        current = DateTime(year, nextMonth, day);
        // resetting the firstday of the month to 1 as we need monthly total
        firstDayOfTheMonth = 1;
      }
    }
    for (var entry in groupedMonthlyTransaction.entries) {
      int year = entry.key.year;
      yearlyTotal[year] = (yearlyTotal[year] ?? 0) + entry.value;
    }
  }

  static void generateRecurringTransactionWeekly(
      {required DateTime startDate,
      required DateTime endDate,
      required num amount,
      required Map<DateTime, num> groupedMonthlyTransaction,
      required Map<int, num> yearlyTotal}) {
    //clear first
    groupedMonthlyTransaction.clear();
    yearlyTotal.clear();

    DateTime current = startDate;
    int firstDayOfTheMonth = current.day;

    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      DateTime monthKey = DateTime(current.year, current.month, current.day);

      // current month last day
      var lastDayOfTheMonth = lastDayInTheMonth(endDate, current);

      // rounding weeks to nearest value eg: if the weeks is 2.4 then amount will be calculated for 3 weeks
      num weeks = ((lastDayOfTheMonth - firstDayOfTheMonth + 1) / 7).ceil();

      num monthlyTotal = weeks * amount;
      // Store monthly recurring amount
      groupedMonthlyTransaction[monthKey] = monthlyTotal;

      // Handle month overflow properly
      if (current.month == 12) {
        current = DateTime(current.year + 1, 1, current.day);
      } else {
        // Check if the day exists in the next month
        int nextMonth = current.month + 1;
        int year = current.year;
        int day = current.day;

        // Handle cases where day doesn't exist in next month (e.g., Jan 31 -> Feb 31)
        int daysInNextMonth = DateTime(year, nextMonth + 1, 0).day;
        if (day > daysInNextMonth) {
          day = daysInNextMonth;
        } else if (day != startDate.day) {
          day = startDate.day;
        }

        current = DateTime(year, nextMonth, day);
        // resetting the firstday of the month to 1 as we need monthly total
        firstDayOfTheMonth = 1;
      }
    }
    for (var entry in groupedMonthlyTransaction.entries) {
      int year = entry.key.year;
      yearlyTotal[year] = (yearlyTotal[year] ?? 0) + entry.value;
    }
  }

  static int lastDayInTheMonth(DateTime endDate, DateTime current) {
    int lastDay = 0;
    if (current.year == endDate.year && current.month == endDate.month) {
      lastDay = endDate.day;
    } else {
      lastDay = DateTime(current.year, current.month + 1, 0).day;
    }
    return lastDay;
  }
}
