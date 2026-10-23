import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/style.dart';
import '../../../l10n/app_localizations.dart';
import '../../../model/currency.dart';
import '../../../providers/currency_provider.dart';
import '../../../providers/authentication_provider.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../services/database/repositories/currency_repository.dart';
import '../../../ui/device.dart';
import 'widgets/currency_selector_dialog.dart';
import 'widgets/language_selector_dialog.dart';

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

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    final appThemeState = ref.watch(appThemeStateProvider);
    final currencyState = ref.watch(currencyStateProvider);
    Future<List<Currency>> currencyList = ref
        .read(currencyRepositoryProvider)
        .selectAll();
    final requiresAuthenticationState = ref.watch(authenticationStateProvider);
    final selectedLocale = ref.watch(appLocaleProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.generalSettings),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: Sizes.lg,
          right: Sizes.lg,
          top: Sizes.xl,
        ),
        physics: const BouncingScrollPhysics(),
        child: Column(
          spacing: Sizes.lg,
          children: [
            Row(
              children: [
                Text(
                  l10n.appearance,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                CircleAvatar(
                  radius: 30.0,
                  backgroundColor: blue5,
                  child: IconButton(
                    color: blue5,
                    onPressed: () {
                      ref.read(appThemeStateProvider.notifier).updateTheme();
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
            Row(
              children: [
                Text(
                  l10n.currency,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      CurrencySelectorDialog.selectCurrencyDialog(
                        context,
                        currencyState,
                        currencyList,
                      );
                    });
                  },
                  child: CircleAvatar(
                    radius: 30.0,
                    backgroundColor: blue5,
                    child: Center(
                      child: Text(
                        currencyState.symbol,
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
            Row(
              children: [
                Text(
                  l10n.requireAuthentication,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                CircleAvatar(
                  radius: 30.0,
                  backgroundColor: blue5,
                  child: IconButton(
                    color: blue5,
                    onPressed: () {
                      ref
                          .read(authenticationStateProvider.notifier)
                          .updateAuthentication();
                    },
                    icon: Icon(
                      requiresAuthenticationState
                          ? Icons.lock
                          : Icons.lock_open,
                      size: 25.0,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  l10n.language,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () =>
                      LanguageSelectorDialog.selectLanguageDialog(context),
                  child: CircleAvatar(
                    radius: 30.0,
                    backgroundColor: blue5,
                    child: selectedLocale == null
                        ? Icon(
                            Icons.language,
                            size: 25.0,
                            color: Theme.of(context).colorScheme.onPrimary,
                          )
                        : Text(
                            selectedLocale.languageCode.toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 20,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
