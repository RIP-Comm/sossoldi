import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../constants/style.dart';

class GeneralSettingsPage extends ConsumerStatefulWidget {
  const GeneralSettingsPage({super.key});

  @override
  ConsumerState<GeneralSettingsPage> createState() =>
      _GeneralSettingsPageState();
}

class _GeneralSettingsPageState extends ConsumerState<GeneralSettingsPage> {
  //default values
  bool darkMode = false;
  String selectedCurrency = "EUR";
  dynamic selectedLanguage = "🇬🇧";

  List<List<dynamic>> languages = [
    ["🇬🇧", "English"],
    ["🇮🇹", "Italiano"],
    ["🇫🇷", "Français"],
    ["🇩🇪", "Deutsch"]
  ];

  List<List<String>> currencies = [
    ["£", "British Pound"],
    ["€", "Euro"],
    ["\$", "US Dollar"],
    ["CHF", "Swiss Franc"],
    ["¥", "Yuan"],
  ];

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
          'General Settings',
          style: Theme.of(context)
              .textTheme
              .headlineLarge!
              .copyWith(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 25),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Row(
              children: [
                Text("Appearance",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary)),
                const Spacer(),
                CircleAvatar(
                    radius: 30.0,
                    backgroundColor: blue5,
                    child: IconButton(
                      color: blue5,
                      onPressed: () {
                        setState(() {
                          darkMode = !darkMode;
                        });
                      },
                      icon: Icon(
                        darkMode ? Icons.dark_mode : Icons.light_mode,
                        size: 25.0,
                        color: Theme.of(context).colorScheme.background,
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text("Currency",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary)),
                const Spacer(),
                GestureDetector(
                    onTap: () {
                      sellectCurrency();
                    },
                    child: CircleAvatar(
                        radius: 30.0,
                        backgroundColor: blue5,
                        child: Center(
                            child: Text(
                          NumberFormat().simpleCurrencySymbol(selectedCurrency),
                          style: const TextStyle(color: white, fontSize: 25),
                        )))),
              ],
            ),
            const SizedBox(height: 20),
            /*
            Row(
              children: [
                Text("Language",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary)),
                const Spacer(),
                GestureDetector(
                    onTap: () {
                      selectLanguage();
                    },
                    child: CircleAvatar(
                      radius: 30.0,
                      backgroundColor: blue5,
                      child: Center(child: Text(selectedLanguage, style: const TextStyle(fontSize: 30))),
                    )),
              ],
            ),*/
          ],
        ),
      ),
    );
  }

  selectLanguage() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: Text('Select a language',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Theme.of(context).colorScheme.primary)),
            content: SizedBox(
              height: 220,
              width: 220,
              child: ListView.builder(
                  itemCount: languages.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedLanguage = languages.elementAt(index)[0];
                          });
                          Navigator.pop(context);
                        },
                        child: ListTile(
                          leading: Text(languages.elementAt(index)[0],
                              style: const TextStyle(fontSize: 30)),
                          title: Text(
                            languages.elementAt(index)[1],
                            textAlign: TextAlign.center,
                          ),
                        ));
                  }),
            )));
  }

  sellectCurrency() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: Text('Select a currency',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Theme.of(context).colorScheme.primary)),
            content: SizedBox(
              height: 220,
              width: 220,
              child: ListView.builder(
                  itemCount: currencies.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCurrency = currencies.elementAt(index)[0];
                          });
                          Navigator.pop(context);
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 22,
                            backgroundColor: blue5,
                            child: Text(currencies.elementAt(index)[0],
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20)),
                          ),
                          title: Text(
                            currencies.elementAt(index)[1],
                            textAlign: TextAlign.center,
                          ),
                        ));
                  }),
            )));
  }
}
