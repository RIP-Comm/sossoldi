import 'package:flutter/material.dart';

import 'style.dart';

// icons
const Map<String, IconData> iconList = {
  'restaurant': Icons.restaurant,
  'home': Icons.home,
  'shopping_cart': Icons.shopping_cart,
  'subscriptions': Icons.subscriptions,
  'hiking_rounded': Icons.hiking_rounded,
  'directions_car_rounded': Icons.directions_car_rounded,
  'airplane_ticket_rounded': Icons.airplane_ticket_rounded,
  'construction': Icons.construction,
  'cookie': Icons.cookie,
  'desktop_mac': Icons.desktop_mac,
  'beach_access': Icons.beach_access,
  'ac_unit': Icons.ac_unit,
  'drafts': Icons.drafts,
  'device_thermostat': Icons.device_thermostat,
  'dry_cleaning': Icons.dry_cleaning,
  'work': Icons.work,
  'question_mark': Icons.question_mark,
};

const Map<String, IconData> accountIconList = {
  'payments': Icons.payments,
  'credit_card': Icons.credit_card,
  'savings': Icons.savings,
  'account_balance': Icons.account_balance,
};

// colors
const categoryColorList = [
  category0,
  category1,
  category2,
  category3,
  category4,
  category5,
  category6,
  category7,
  category8,
  category9,
];

const darkCategoryColorList = [
  darkCategory0,
  darkCategory1,
  darkCategory2,
  darkCategory3,
  darkCategory4,
  darkCategory5,
  darkCategory6,
  darkCategory7,
  darkCategory8,
  darkCategory9,
];

const accountColorList = [
  account1,
  account2,
  account3,
  account4,
  account5,
];

const darkAccountColorList = [
  darkAccount1,
  darkAccount2,
  darkAccount3,
  darkAccount4,
  darkAccount5,
];

List<Color> categoryColorListTheme = categoryColorList;
List<Color> accountColorListTheme = accountColorList;

void updateColorsBasedOnTheme(bool isDarkModeEnabled) {
  if (isDarkModeEnabled) {
    categoryColorListTheme = darkCategoryColorList;
    accountColorListTheme = darkAccountColorList;
  } else {
    categoryColorListTheme = categoryColorList;
    accountColorListTheme = accountColorList;
  }
}
