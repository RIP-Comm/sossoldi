// Settings page.

import 'package:flutter/material.dart';
import '../constants/style.dart';
import '../custom_widgets/alert_dialog.dart';
import '../database/sossoldi_database.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsPageState createState() => _SettingsPageState();
}

var settingsOptions = const [
  [
    Icons.account_balance_wallet,
    "Accounts",
    "Add or edit your accounts",
  ],
  [
    Icons.list_alt,
    "Categories",
    "Add or edit categories and subcategories",
  ],
  [
    Icons.attach_money,
    "Budget",
    "Add or edit your budgets",
  ],
  [
    Icons.download_for_offline,
    "Import/Export",
    "Import or export data from a CSV file",
  ],
];

class _SettingsPageState extends State<SettingsPage> {
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
      body: GridView.count(
        padding: const EdgeInsets.all(16.0),
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 3 / 2.5,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: List.generate(
          settingsOptions.length,
          (index) {
            return Material(
              color: blue7,
              borderRadius: BorderRadius.circular(4),
              child: InkWell(
                onTap: () => print("click"),
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: const BoxDecoration(
                          color: blue4,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          settingsOptions[index][0] as IconData,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        settingsOptions[index][1].toString(),
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(color: Theme.of(context).colorScheme.primary),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        settingsOptions[index][2].toString(),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: Theme.of(context).colorScheme.primary),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomSheet: Container(
        color: Colors.deepOrangeAccent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget> [
            const Text(
              '[DEV ONLY]\nDANGEROUS\nZONE',
              style: TextStyle(
                fontSize: 11, color: Colors.yellowAccent,
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
                await SossoldiDatabase.instance.clearDatabase();
                showSuccessDialog(context, "DB Cleared");
              },
            ),
            ElevatedButton(
              child: const Text('CLEAR AND FILL DEMO DATA'),
              onPressed: () async {
                await SossoldiDatabase.instance.clearDatabase();
                await SossoldiDatabase.instance.fillDemoData();
                showSuccessDialog(context, "DB Cleared, and DEMO data added");
              },
            ),
          ],
        )
      ),
    );
  }
}
