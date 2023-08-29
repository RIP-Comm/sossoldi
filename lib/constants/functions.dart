import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/style.dart';
import '../model/transaction.dart';

mixin Functions {
  String numToCurrency(num? value) {
    if (value == null) return '';
    return value.toStringAsFixed(2).replaceAll(".", ",");
  }

  num currencyToNum(String value) {
    if (value != '') {
      return num.parse(value.replaceAll(",", "."));
    }
    return 0;
  }

  String dateToString(DateTime date) {
    final format = DateFormat('E, d MMMM y');
    return format.format(date);
  }

  Color typeToColor(Type type) {
    switch (type) {
      case Type.income:
        return green;
      case Type.expense:
        return red;
      case Type.transfer:
        return blue3;
      default:
        return blue3;
    }
  }
}
