import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../constants/style.dart";

class DetailsListTile extends ConsumerWidget {
  const DetailsListTile({
    required this.title,
    required this.icon,
    required this.value,
    required this.callback,
    super.key,
  });

  final String title;
  final IconData icon;
  final String? value;
  final VoidCallback callback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.all(16.0),
      tileColor: Theme.of(context).colorScheme.surface,
      onTap: callback,
      leading: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.secondary,
        ),
        padding: const EdgeInsets.all(10.0),
        child: Icon(
          icon,
          size: 24.0,
          color: Theme.of(context).colorScheme.surface,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge!
            .copyWith(color: Theme.of(context).colorScheme.primary),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value ?? '',
            style:
                Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: Theme.of(context).colorScheme.secondary),
          ),
          const SizedBox(width: 6.0),
          const Icon(Icons.chevron_right, color: grey1),
        ],
      ),
    );
  }
}
