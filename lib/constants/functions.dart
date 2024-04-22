import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/style.dart';
import '../model/transaction.dart';

mixin Functions {
  String numToCurrency(num? value) {
    if (value == null) return '';
    return value.toStringAsFixed(2);
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

  Color typeToColor(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return green;
      case TransactionType.expense:
        return red;
      case TransactionType.transfer:
        return blue3;
      default:
        return blue3;
    }
  }

  String capitalizeFirstLetter(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1);
  }
}
