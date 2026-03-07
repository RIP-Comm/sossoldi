// Settings page.

// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../constants/constants.dart';
import '../../constants/style.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets/alert_dialog.dart';
import '../../ui/widgets/default_card.dart';
import '../../services/database/sossoldi_database.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/budgets_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/statistics_provider.dart';
import '../../providers/transactions_provider.dart';
import '../../ui/device.dart';


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
              "WARNING: tapping on any button on the red bar, erases permanently your data. Do it at your own risk",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "OK",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
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
    var l10n = AppLocalizations.of(context)!;


    var settingsOptions = [
      [
        Icons.settings,
        l10n.generalSettings,
        l10n.generalSettingsDesc,
        "/general-settings",
      ],
      [
        Icons.account_balance_wallet,
        l10n.accounts,
        l10n.accountsDesc,
        "/account-list",
      ],
      [
        Icons.list_alt,
        l10n.categories,
        l10n.categoriesDesc,
        "/category-list",
      ],
      [Icons.attach_money, l10n.budget, l10n.budgetDesc, null],
      [
        Icons.download_for_offline,
        l10n.importExport,
        l10n.importExportDesc,
        "/backup-page",
      ],
      [
        Icons.notifications_active,
        l10n.notifications,
        l10n.notificationsDesc,
        "/notifications-settings",
      ],
      [
        Icons.feedback,
        l10n.leaveFeedback,l10n.leaveFeedbackDesc,
        "https://feedback.sossoldi.com",
      ],
      [Icons.info, l10n.appInfo, l10n.appInfoDesc, "/more-info"],
    ];


    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: _onSettingsTap,
          child: Text(l10n.settings),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: Sizes.xl),
        physics: const BouncingScrollPhysics(),
        itemCount: settingsOptions.length,
        itemBuilder: (context, i) {
          List setting = settingsOptions[i];
          if (setting[3] == null) return Container();
          return Padding(
            padding: const EdgeInsets.only(bottom: Sizes.lg),
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
                    padding: const EdgeInsets.all(Sizes.sm),
                    child: Icon(
                      setting[0] as IconData,
                      size: 30.0,
                      color: white,
                    ),
                  ),
                  const SizedBox(width: Sizes.md),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          setting[1].toString(),
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        Text(
                          setting[2].toString(),
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Sizes.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.settingsDisclaimer,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.github),
                    onPressed: () => launchUrl(Uri.parse(githubUrl)),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.linkedin),
                    onPressed: () => launchUrl(Uri.parse(linkedinUrl)),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.youtube),
                    onPressed: () => launchUrl(Uri.parse(youtubeUrl)),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.discord),
                    onPressed: () => launchUrl(Uri.parse(discordUrl)),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
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
                  FilledButton(
                    child: const Text('RESET DB'),
                    onPressed: () async {
                      await SossoldiDatabase.instance.resetDatabase();
                      ref.refresh(accountsProvider);
                      ref.refresh(categoriesProvider);
                      ref.refresh(transactionsProvider);
                      ref.refresh(budgetsProvider);

                      if (context.mounted) {
                        showSuccessDialog(context, "DB Cleared");
                      }
                    },
                  ),
                  FilledButton(
                    child: const Text('CLEAR AND FILL DEMO DATA'),
                    onPressed: () async {
                      await SossoldiDatabase.instance.clearDatabase();
                      await SossoldiDatabase.instance.fillDemoData();
                      ref.refresh(accountsProvider);
                      ref.refresh(categoriesProvider);
                      ref.refresh(transactionsProvider);
                      ref.refresh(budgetsProvider);
                      ref.refresh(dashboardProvider);
                      ref.refresh(lastTransactionsProvider);
                      ref.refresh(statisticsProvider);

                      if (context.mounted) {
                        showSuccessDialog(
                          context,
                          "DB Cleared, and DEMO data added",
                        );
                      }
                    },
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
