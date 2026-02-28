// Settings page.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/settings_provider.dart';
import '../../../ui/widgets/default_card.dart';
import '../../../ui/device.dart';

class MoreInfoPage extends ConsumerWidget {
  const MoreInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moreInfoOptions = [
      ["App Version:", ref.watch(versionProvider), null],
      ["Collaborators", "See the team behind this app", "/collaborators"],
      ["Privacy Policy", "Read more", "/privacy-policy"],
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('App Info'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.only(top: Sizes.xl),
        physics: const BouncingScrollPhysics(),
        itemCount: moreInfoOptions.length,
        separatorBuilder: (context, index) => const SizedBox(height: Sizes.lg),
        itemBuilder: (context, index) {
          List option = moreInfoOptions[index];
          return SettingsInfo(
            title: option[0],
            value: option[1],
            link: option[2],
          );
        },
      ),
    );
  }
}

class SettingsInfo extends StatelessWidget {
  final String title;
  final String value;
  final String? link;
  const SettingsInfo({
    super.key,
    required this.title,
    required this.value,
    this.link,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultCard(
      onTap: () {
        if (link != null) {
          Navigator.of(context).pushNamed(link as String);
        }
      },
      child: Row(
        spacing: Sizes.md,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.left,
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
