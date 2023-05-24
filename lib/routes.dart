import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sossoldi/pages/categories/category_list.dart';
import 'package:sossoldi/pages/more_info_page/collaborators_page.dart';
import 'model/bank_account.dart';
import '/pages/more_info_page/more_info.dart';
import '/pages/more_info_page/privacy_policy.dart';
import 'pages/accounts/account_list.dart';
import 'pages/categories/add_category.dart';
import 'pages/accounts/add_account.dart';
import 'pages/add_page/widgets/recurrence_selector.dart';
import 'pages/add_page/widgets/account_selector.dart';
import 'pages/add_page/widgets/category_selector.dart';
import 'pages/home_page.dart';
import 'pages/planning_budget_page.dart';
import 'pages/settings_page.dart';
import 'pages/statistics_page.dart';
import 'pages/structure.dart';
import 'pages/transactions_page/transactions_page.dart';
import 'pages/onboarding_page/onboarding_page.dart';

Route<dynamic> makeRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return _materialPageRoute(settings.name, const Structure());
    case '/onboarding':
      return _materialPageRoute(settings.name, const Onboarding());
    case '/dashboard':
      return _materialPageRoute(settings.name, const HomePage());
    case '/transactions':
      return _materialPageRoute(settings.name, TransactionsPage());
    case '/categoryselect':
      return _cupertinoPageRoute(settings.name, const CategorySelector());
    case '/category-list':
      return _cupertinoPageRoute(settings.name, const CategoryList());
    case '/add-category':
      return _cupertinoPageRoute(settings.name, const AddCategory());
    case '/more-info':
      return _cupertinoPageRoute(settings.name, const MoreInfoPage());
    case '/privacy-policy':
      return _cupertinoPageRoute(settings.name, const PrivacyPolicyPage());
    case '/collaborators':
      return _cupertinoPageRoute(settings.name, const CollaboratorsPage());
    case '/account-list':
      return _cupertinoPageRoute(settings.name, const AccountList());
    case '/add-account':
      return _cupertinoPageRoute(settings.name, const AddAccount());
    case '/accountselect':
      return _cupertinoPageRoute(
          settings.name, AccountSelector(settings.arguments as StateProvider));
    case '/recurrenceselect':
      return _cupertinoPageRoute(settings.name, const RecurrenceSelector());
    case '/planning':
      return _materialPageRoute(settings.name, const PlanningPage());
    case '/graphs':
      return _materialPageRoute(settings.name, const StatsPage());
    case '/settings':
      return _noTransitionPageRoute(settings.name, const SettingsPage());
    default:
      throw 'Route is not defined';
  }
}

PageRoute _cupertinoPageRoute(String? routeName, Widget viewToShow) {
  return CupertinoPageRoute(
    settings: RouteSettings(
      name: routeName,
    ),
    builder: (_) => viewToShow,
  );
}

PageRoute _materialPageRoute(String? routeName, Widget viewToShow) {
  return MaterialPageRoute(
    settings: RouteSettings(
      name: routeName,
    ),
    builder: (_) => viewToShow,
  );
}

PageRoute _noTransitionPageRoute(String? routeName, Widget viewToShow) {
  return PageRouteBuilder(
    transitionDuration: const Duration(),
    reverseTransitionDuration: const Duration(),
    settings: RouteSettings(
      name: routeName,
    ),
    pageBuilder: (_, __, ___) => viewToShow,
  );
}
