// Settings page.

// ignore_for_file: unused_result

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/style.dart';
import '../custom_widgets/alert_dialog.dart';
import '../custom_widgets/default_card.dart';
import '../database/sossoldi_database.dart';
import '../providers/accounts_provider.dart';
import '../providers/budgets_provider.dart';
import '../providers/categories_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/statistics_provider.dart';
import '../providers/transactions_provider.dart';

var settingsOptions = [
  [
    Icons.settings,
    "General Settings",
    "Edit general settings",
    "/general-settings",
  ],
  [
    Icons.account_balance_wallet,
    "Accounts",
    "Add or edit your accounts",
    "/account-list",
  ],
  [
    Icons.list_alt,
    "Categories",
    "Add/edit categories and subcategories",
    "/category-list",
  ],
  [
    Icons.attach_money,
    "Budget",
    "Add or edit your budgets",
    null,
  ],
  [
    Icons.download_for_offline,
    "Import/Export",
    "Import or export data from a CSV file",
    null,
  ],
  [
    Icons.notifications_active,
    "Notifications",
    "Manage your notifications settings",
    Platform.isAndroid ? "/notifications-settings" : null,
  ],
  [
    Icons.feedback,
    "Leave a feedback",
    "Complete a small form to report a bug or leave a feedback",
    "https://feedback.sossoldi.com",
  ],
  [
    Icons.info,
    "App Info",
    "Learn more about us and the app",
    "/more-info",
  ],
];

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isDeveloperOptionsActive = false;
  int _tapCount = 0;

  void _onSettingsTap() {
    _tapCount++;

    if (_tapCount == 4) {
      setState(() {
        _isDeveloperOptionsActive = !_isDeveloperOptionsActive;
      });
      _tapCount = 0; // Reset the tap counter

      if (_isDeveloperOptionsActive) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Developer options activated."),
            content: const Text(
                "WARNING: tapping on any button on the red bar, erases permanently your data. Do it at your own risk"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "OK",
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ],
          ),
        );
      }
    }

    // Reset the tap count if too much time passes between taps (optional)
    Future.delayed(const Duration(seconds: 1), () {
      _tapCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: GestureDetector(
                onTap: _onSettingsTap,
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      padding: const EdgeInsets.all(5.0),
                      child: Icon(
                        Icons.settings,
                        size: 28.0,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Text(
                      "Settings",
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge!
                          .copyWith(color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              ),
            ),
            ListView.builder(
              itemCount: settingsOptions.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, i) {
                List setting = settingsOptions[i];
                if (setting[3] == null) return Container();
                return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DefaultCard(
                      onTap: () {
                        if (setting[3] != null) {
                          final link = setting[3] as String;
                          if (link.startsWith("http")) {
                            Uri url = Uri.parse(link);
                            launchUrl(url);
                          } else {
                            Navigator.of(context).pushNamed(link);
                          }
                        }
                      },
                      child: Row(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: blue5,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(10.0),
                            child: Icon(
                              setting[0] as IconData,
                              size: 30.0,
                              color: white,
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  setting[1].toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(color: Theme.of(context).colorScheme.primary),
                                ),
                                Text(
                                  setting[2].toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(color: Theme.of(context).colorScheme.primary),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ));
              },
            ),
          ],
        ),
      ),
      bottomSheet: _isDeveloperOptionsActive
          ? Container(
              color: Colors.deepOrangeAccent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  const Text(
                    '[DEV ONLY]\nDANGEROUS\nZONE',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.yellowAccent,
                      shadows: <Shadow>[
                        Shadow(
                          offset: Offset(1.0, 1.0),
                          blurRadius: 3.0,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  ElevatedButton(
                    child: const Text('RESET DB'),
                    onPressed: () async {
                      await SossoldiDatabase.instance.resetDatabase().then((v) {
                        ref.refresh(accountsProvider);
                        ref.refresh(categoriesProvider);
                        ref.refresh(transactionsProvider);
                        ref.refresh(budgetsProvider);
                        showSuccessDialog(context, "DB Cleared");
                      });
                    },
                  ),
                  ElevatedButton(
                    child: const Text('CLEAR AND FILL DEMO DATA'),
                    onPressed: () async {
                      await SossoldiDatabase.instance.clearDatabase();
                      await SossoldiDatabase.instance.fillDemoData().then((value) {
                        ref.refresh(accountsProvider);
                        ref.refresh(categoriesProvider);
                        ref.refresh(transactionsProvider);
                        ref.refresh(budgetsProvider);
                        ref.refresh(dashboardProvider);
                        ref.refresh(lastTransactionsProvider);
                        ref.refresh(statisticsProvider);
                        showSuccessDialog(context, "DB Cleared, and DEMO data added");
                      });
                    },
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
