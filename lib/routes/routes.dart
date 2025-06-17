import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../pages/accounts/account_page.dart';
import '../pages/accounts/create_edit_account_page.dart';
import '../pages/accounts/account_list_page.dart';
import '../pages/transactions/create_transaction/create_transaction_page.dart';
import '../pages/transactions/categories/create_edit_category_page.dart';
import '../pages/transactions/categories/category_list_page.dart';
import '../pages/settings/general/general_settings_page.dart';
import '../pages/graphs/graphs_page.dart';
import '../pages/dashboard/dashboard_page.dart';
import '../pages/settings/infos/collaborators_page.dart';
import '../pages/settings/infos/more_info_page.dart';
import '../pages/settings/infos/privacy_policy_page.dart';
import '../pages/settings/notifications/notifications_settings.dart';
import '../pages/onboarding/onboarding_page.dart';
import '../pages/planning/planning_page.dart';
import '../pages/search/search_page.dart';
import '../pages/settings/settings_page.dart';
import '../pages/structure.dart';
import '../pages/transactions/transactions_page.dart';
import '../pages/planning/widget/edit_recurring_transaction.dart';
import '../pages/settings/backup/backup_page.dart';

Route<dynamic> makeRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return buildAdaptiveRoute(settings.name, const Structure());
    case '/onboarding':
      return buildAdaptiveRoute(settings.name, const Onboarding());
    case '/dashboard':
      return buildAdaptiveRoute(settings.name, const DashboardPage());
    case '/add-page':
      Map<String, bool>? args;
      if (settings.arguments is Map<String, bool>?) {
        args = settings.arguments as Map<String, bool>?;
      } else {
        args = null;
      }
      return buildAdaptiveRoute(
        settings.name,
        CreateTransactionPage(
            recurrencyEditingPermitted:
                args?['recurrencyEditingPermitted'] ?? true),
      );
    case '/edit-recurring-transaction':
      return buildAdaptiveRoute(
          settings.name, const EditRecurringTransaction());
    case '/transactions':
      return buildAdaptiveRoute(settings.name, const TransactionsPage());
    case '/category-list':
      return buildAdaptiveRoute(settings.name, const CategoryList());
    case '/add-category':
      final args = settings.arguments as Map<String, dynamic>?;
      return buildAdaptiveRoute(
        settings.name,
        CreateEditCategoryPage(hideIncome: args?['hideIncome'] ?? false),
      );
    case '/more-info':
      return buildAdaptiveRoute(settings.name, const MoreInfoPage());
    case '/privacy-policy':
      return buildAdaptiveRoute(settings.name, const PrivacyPolicyPage());
    case '/collaborators':
      return buildAdaptiveRoute(settings.name, const CollaboratorsPage());
    case '/account':
      return buildAdaptiveRoute(settings.name, const AccountPage());
    case '/account-list':
      return buildAdaptiveRoute(settings.name, const AccountList());
    case '/add-account':
      return buildAdaptiveRoute(settings.name, const CreateEditAccountPage());
    case '/planning':
      return buildAdaptiveRoute(settings.name, const PlanningPage());
    case '/graphs':
      return buildAdaptiveRoute(settings.name, const GraphsPage());
    case '/settings':
      return buildAdaptiveRoute(settings.name, const SettingsPage());
    case '/general-settings':
      return buildAdaptiveRoute(settings.name, const GeneralSettingsPage());
    case '/notifications-settings':
      return buildAdaptiveRoute(settings.name, const NotificationsSettings());
    case '/search':
      return buildAdaptiveRoute(settings.name, const SearchPage());
    case '/backup-page':
      return buildAdaptiveRoute(settings.name, const BackupPage());
    default:
      throw 'Route is not defined';
  }
}

PageRoute buildAdaptiveRoute(String? routeName, Widget viewToShow) {
  if (Platform.isAndroid) {
    return _materialPageRoute(routeName, viewToShow);
  }

  return _cupertinoPageRoute(routeName, viewToShow);
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
