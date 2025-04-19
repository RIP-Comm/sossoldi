import 'dart:math' as math;
import 'package:flutter/services.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({this.decimalDigits})
      : assert(decimalDigits == null || decimalDigits > 0);

  final int? decimalDigits;
  final String decimalSeparator = ".";
  final String thousandsSeparator = ",";

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String value = newValue.text;

    RegExp regex = RegExp(r'[\d\,\.]');

    if (value.isNotEmpty && !regex.hasMatch(value[value.length - 1])) {
      return oldValue;
    }

    if (value.contains(thousandsSeparator)) {
      value = value.replaceAll(thousandsSeparator, decimalSeparator);
    }

    if (decimalSeparator.allMatches(value).length > 1 ||
        value.contains(thousandsSeparator)) {
      return oldValue;
    }

    if (value == decimalSeparator) {
      // Allow for .x decimal notation
      value = "0$decimalSeparator";
    }

    if (decimalDigits != null &&
        value.contains(decimalSeparator) &&
        value.substring(value.indexOf(decimalSeparator) + 1).length >
            decimalDigits!) {
      value = oldValue.text;
    }

    newSelection = newValue.selection.copyWith(
      baseOffset: math.min(value.length, value.length + 1),
      extentOffset: math.min(value.length, value.length + 1),
    );

    return TextEditingValue(
      text: value,
      selection: newSelection,
      composing: TextRange.empty,
    );
  }
}
