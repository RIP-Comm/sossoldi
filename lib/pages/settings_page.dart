// Settings page.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../custom_widgets/default_container.dart';
import '../constants/style.dart';
import '../custom_widgets/alert_dialog.dart';
import '../database/sossoldi_database.dart';
import '../providers/transactions_provider.dart';
import '../providers/accounts_provider.dart';
import '../providers/budgets_provider.dart';
import '../providers/categories_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

var settingsOptions = const [
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
    null,
  ],
  [
    Icons.info,
    "App Info",
    "Learn more about us and the app",
    "/more-info",
  ],
];

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0XFF7DA1C4),
          ),
          onPressed: () {
            Navigator.pop(context);
            // Return to previous page
          },
        ),
        title: Text(
          'Settings',
          style: Theme.of(context)
              .textTheme
              .headlineLarge!
              .copyWith(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            ),
            ListView.separated(
              itemCount: settingsOptions.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, i) {
                List setting = settingsOptions[i];
                return DefaultContainer(
                  onTap: () {
                    setting[3] != null
                        ? Navigator.of(context).pushNamed(setting[3] as String)
                        : print("click");
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
                          color: Theme.of(context).colorScheme.background,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            setting[1].toString(),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(color: Theme.of(context).colorScheme.primary),
                            textAlign: TextAlign.left,
                          ),
                          Text(
                            setting[2].toString(),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(color: Theme.of(context).colorScheme.primary),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomSheet: Container(
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
                child: const Text('CLEAR DB'),
                onPressed: () async {
                  await SossoldiDatabase.instance.clearDatabase().then((v) {
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
                    showSuccessDialog(context, "DB Cleared, and DEMO data added");
                  });
                },
              ),
            ],
          )),
    );
  }
}
