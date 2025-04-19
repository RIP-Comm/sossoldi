import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../constants/style.dart";
import "../../providers/theme_provider.dart";
import "rounded_icon.dart";
import "../../../ui/device.dart";

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
    final isDarkMode = ref.watch(appThemeStateNotifier).isDarkModeEnabled;

    return ListTile(
      contentPadding: const EdgeInsets.all(Sizes.lg),
      onTap: callback,
      leading: RoundedIcon(
        icon: icon,
        backgroundColor: Theme.of(context).colorScheme.secondary,
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
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: isDarkMode
                    ? grey3
                    : Theme.of(context).colorScheme.secondary),
          ),
          const SizedBox(width: Sizes.sm),
          Icon(
            Icons.chevron_right,
            color: isDarkMode ? grey3 : Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),
    );
  }
}
