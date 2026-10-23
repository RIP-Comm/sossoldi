---
title: Translations
layout: default
nav_order: 4
parent: How to contribute to the project
---

# Translations

Sossoldi uses the standard Flutter localization tooling (`flutter_localizations` + `gen-l10n`).
The app falls back to English when the language is not supported.

## Where the strings live

- `lib/l10n/app_en.arb` is the template: every new string is added here first.
- `lib/l10n/app_<language>.arb` contains the translation for each language (e.g. `app_it.arb`).
- `lib/l10n/app_localizations*.dart` are generated and not committed: `flutter pub get` (or `flutter gen-l10n`) creates them.

The app follows the device language unless the user picks one in *Settings → General → Language*.

The languages offered to users are listed in `supportedAppLocales` in `lib/providers/locale_provider.dart`,
and must also be listed under `CFBundleLocalizations` in `ios/Runner/Info.plist`.
A language should be enabled only once its translation has been reviewed by a native speaker.

## Adding or changing a string

1. Add the key to `app_en.arb`. Use `{placeholder}` for dynamic values:

   ```json
   "deleteAccountConfirm": "Are you sure you want to delete the account named \"{name}\"?"
   ```

2. Add the same key, with the same placeholders, to every other `app_<language>.arb` file.
   If you don't know the language, copy the English text: translators will update it.
3. Use it in a widget:

   ```dart
   final l10n = AppLocalizations.of(context)!;
   Text(l10n.deleteAccountConfirm(account.name));
   ```

`test/l10n/arb_consistency_test.dart` fails if a translation file is missing a key or uses different placeholders.
`test/l10n/hardcoded_strings_test.dart` fails if a user facing text is written directly in the code instead of coming from `AppLocalizations`.
Only the developer menu strings are allowed there.

## Crowdin

Translations can be managed by the community on Crowdin (configuration in `crowdin.yml`), using the [Crowdin CLI](https://crowdin.github.io/crowdin-cli/):

```bash
# Upload new or changed English strings
crowdin upload sources

# Download the latest translations, then regenerate the Dart classes
crowdin download
flutter gen-l10n
```

Download the latest translations before editing `.arb` files by hand, so that changes made on Crowdin are not overwritten.
