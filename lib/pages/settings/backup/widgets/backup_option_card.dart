import 'package:flutter/material.dart';

import '../../../../ui/device.dart';
import '../../../../ui/widgets/default_card.dart';

class BackupOptionCard extends StatelessWidget {
  const BackupOptionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return DefaultCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: Sizes.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(color: color),
                ),
                const SizedBox(height: Sizes.xs),
                Text(
                  description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(color: color),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: color),
        ],
      ),
    );
  }
}

/// Page layout shared by the backup pages: an app bar and a list of cards.
class BackupOptionsScaffold extends StatelessWidget {
  const BackupOptionsScaffold({
    required this.title,
    required this.options,
    super.key,
  });

  final String title;
  final List<BackupOptionCard> options;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.only(top: Sizes.xl),
        physics: const BouncingScrollPhysics(),
        itemCount: options.length,
        separatorBuilder: (context, index) => const SizedBox(height: Sizes.lg),
        itemBuilder: (context, index) => options[index],
      ),
    );
  }
}
