import 'package:intl/intl.dart';

String getFormattedDateRange(DateTime a, DateTime b) {
  DateTime lastOfMonth = DateTime(a.year, a.month + 1, 0);

  if (a.day == 1 && b == lastOfMonth) {
    return DateFormat('MMMM yyyy').format(a);
  } else {
    final s = DateFormat('dd/MM/yy').format(a);
    final e = DateFormat('dd/MM/yy').format(b);
    return "$s - $e";
  }
}
