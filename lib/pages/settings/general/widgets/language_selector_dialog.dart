import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../providers/locale_provider.dart';

class LanguageSelectorDialog {
  static void selectLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.selectALanguage,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        content: Consumer(
          builder: (context, ref, _) {
            final selected = ref.watch(appLocaleProvider);
            final options = <Locale?, String>{
              null: AppLocalizations.of(context)!.systemLanguage,
              ...supportedAppLocales,
            };
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final option in options.entries)
                  ListTile(
                    title: Text(option.value),
                    trailing: option.key == selected
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.secondary,
                          )
                        : null,
                    onTap: () {
                      ref
                          .read(appLocaleProvider.notifier)
                          .setLocale(option.key);
                      Navigator.pop(context);
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
