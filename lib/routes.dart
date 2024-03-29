import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sossoldi/pages/onboarding_page/onboarding_page.dart';

import 'pages/account_page/account_page.dart';
import 'pages/accounts/account_list.dart';
import 'pages/accounts/add_account.dart';
import 'pages/add_page/add_page.dart';
import 'pages/categories/add_category.dart';
import 'pages/categories/category_list.dart';
import 'pages/general_options/general_settings.dart';
import 'pages/home_page.dart';
import 'pages/more_info_page/collaborators_page.dart';
import 'pages/more_info_page/more_info.dart';
import 'pages/more_info_page/privacy_policy.dart';
import 'pages/notifications/notifications_settings.dart';
import 'pages/planning_page/planning_page.dart';
import 'pages/search_page/search_page.dart';
import 'pages/settings_page.dart';
import 'pages/statistics_page.dart';
import 'pages/structure.dart';
import 'pages/transactions_page/transactions_page.dart';

Route<dynamic> makeRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return _materialPageRoute(settings.name, const Structure());
    case '/onboarding':
      return _materialPageRoute(settings.name, const Onboarding());
    case '/dashboard':
      return _materialPageRoute(settings.name, const HomePage());
    case '/add-page':
      return _materialPageRoute(settings.name, const AddPage());
    case '/transactions':
      return _materialPageRoute(settings.name, const TransactionsPage());
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
    case '/account':
      return _materialPageRoute(settings.name, const AccountPage());
    case '/account-list':
      return _cupertinoPageRoute(settings.name, const AccountList());
    case '/add-account':
      return _cupertinoPageRoute(settings.name, const AddAccount());
    case '/planning':
      return _materialPageRoute(settings.name, const PlanningPage());
    case '/graphs':
      return _materialPageRoute(settings.name, const StatsPage());
    case '/settings':
      return _noTransitionPageRoute(settings.name, const SettingsPage());
    case '/general-settings':
      return _cupertinoPageRoute(settings.name, const GeneralSettingsPage());
    case '/notifications-settings':
      return _cupertinoPageRoute(settings.name, const NotificationsSettings());
    case '/search':
      return _materialPageRoute(settings.name, const SearchPage());
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
