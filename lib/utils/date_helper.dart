import 'package:intl/intl.dart';

const String dateFormatter = 'MMMM d, EEEE';
const String dateYMDFormatter = 'yyyyMMdd';

extension DateHelper on DateTime {
  String formatDate() {
    final formatter = DateFormat(dateFormatter);
    return formatter.format(this);
  }

  String toYMD() {
    final formatter = DateFormat(dateYMDFormatter);
    return formatter.format(this);
  }

  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
