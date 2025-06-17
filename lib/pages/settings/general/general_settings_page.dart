import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/style.dart';
import '../../../model/currency.dart';
import '../../../providers/currency_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../ui/device.dart';
import 'widgets/currency_selector_dialog.dart';

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

  Future<List<Currency>> currencyList = CurrencyMethods().selectAll();

  @override
  Widget build(BuildContext context) {
    final appThemeState = ref.watch(appThemeStateNotifier);
    final currencyState = ref.watch(currencyStateNotifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('General Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
            left: Sizes.lg, right: Sizes.lg, top: Sizes.xl),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "Appearance",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                const Spacer(),
                CircleAvatar(
                  radius: 30.0,
                  backgroundColor: blue5,
                  child: IconButton(
                    color: blue5,
                    onPressed: () {
                      // Toggle dark mode using the provider
                      if (appThemeState.isDarkModeEnabled) {
                        ref
                            .read(appThemeStateNotifier.notifier)
                            .setLightTheme();
                      } else {
                        ref.read(appThemeStateNotifier.notifier).setDarkTheme();
                      }
                    },
                    icon: Icon(
                      appThemeState.isDarkModeEnabled
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      size: 25.0,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Sizes.lg),
            Row(
              children: [
                Text(
                  "Currency",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      CurrencySelectorDialog.selectCurrencyDialog(
                          context, currencyState, currencyList);
                    });
                  },
                  child: CircleAvatar(
                    radius: 30.0,
                    backgroundColor: blue5,
                    child: Center(
                      child: Text(
                        currencyState.selectedCurrency.symbol,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Sizes.lg),
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
