import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants/style.dart';
import '../models/transaction.dart';

/// Adds extensions to num  to make creating durations more succint:
///
/// ```
/// 200.ms // equivalent to Duration(milliseconds: 200)
/// 3.seconds // equivalent to Duration(milliseconds: 3000)
/// 1.5.days // equivalent to Duration(hours: 36)
/// ```
extension NumDurationX on num {
  Duration get microseconds => Duration(microseconds: round());
  Duration get ms => (this * 1000).microseconds;
  Duration get milliseconds => (this * 1000).microseconds;
  Duration get seconds => (this * 1000 * 1000).microseconds;
  Duration get minutes => (this * 1000 * 1000 * 60).microseconds;
  Duration get hours => (this * 1000 * 1000 * 60 * 60).microseconds;
  Duration get days => (this * 1000 * 1000 * 60 * 60 * 24).microseconds;
}

/// Set of extensions to make working with [TextStyle] easier
///
/// ```
/// TextStyle(
///   fontSize: 16,
/// ).bold // equivalent to TextStyle(fontWeight: FontWeight.bold);
/// .italic // equivalent to TextStyle(fontStyle: FontStyle.italic);
/// .color(Colors.red); // equivalent to TextStyle(color: Colors.red);
/// ```
extension TextStyleX on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);

  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);

  TextStyle color(Color color) => copyWith(color: color);
}

extension StringExtension on String {
  String capitalize() {
    return isEmpty ? "" : "${this[0].toUpperCase()}${substring(1)}";
  }

  num toNum() => num.parse(replaceAll(",", "."));
}

/// Adds a method to [num] to convert it to a currency string.
///
/// ```
/// 1234.56.toCurrency(); // '1234.56'
/// ```
extension NumExtension on num {
  String toCurrency() => toStringAsFixed(2);
}

/// Adds a method to [DateTime] to convert it to a string.
///
/// ```
/// DateTime.now().formatEDMY(); // 'Wed, 11 September 2001'
/// DateTime.now().formatMDE(); // 'September 11, Wednesday'
/// DateTime.now().formatYMD(); // '20010911'
/// DateTime.now().isSameDate(DateTime.now()); // true
/// ```
extension DateTimeExtension on DateTime {
  String formatEDMY() => DateFormat('E, d MMMM y').format(this);

  String formatMDE() => DateFormat('MMMM d, EEEE').format(this);

  String formatYMD() => DateFormat('yyyyMMdd').format(this);

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

/// Adds a method to [TransactionType] to convert it to a color.
///
/// ```
/// TransactionType.income.toColor(); // green
/// TransactionType.expense.toColor(); // red
/// TransactionType.transfer.toColor(); // blue3
extension TransactionTypeExtension on TransactionType {
  Color toColor({Brightness brightness = Brightness.light}) {
    switch (this) {
      case TransactionType.income:
        return green;
      case TransactionType.expense:
        return red;
      case TransactionType.transfer:
        if (brightness == Brightness.light) {
          return blue3;
        }
        return darkBlue6;
    }
  }
}
