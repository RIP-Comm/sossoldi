// Settings page.

import 'package:flutter/material.dart';

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
    "Add or edit categories or subcategories",
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
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).colorScheme.primary,
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
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(12.0),
              crossAxisCount: 2,
              childAspectRatio: 3 / 2.5,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: List.generate(
                settingsOptions.length,
                (index) {
                  return InkWell(
                    onTap: () {},
                    child: Card(
                      color: const Color(0XFFF1F5F9),
                      child: Container(
                        height: double.infinity,
                        margin: const EdgeInsets.only(left: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 40.0,
                              height: 40.0,
                              decoration: const BoxDecoration(
                                color: Color(0xFF03478c),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                settingsOptions[index][0] as IconData,
                                color: Colors.white,
                              ),
                            ),
                            Text(settingsOptions[index][1].toString(),
                                style: const TextStyle(
                                    fontSize: 18, color: Color(0XFF00152D)),
                                textAlign: TextAlign.left),
                            Text(
                              settingsOptions[index][2].toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w100,
                                  fontSize: 14,
                                  color: Color(0XFF00152D)),
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
          ),
        ],
      ),
    );
  }
}
