import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'rounded_icon.dart';
import '../../constants/style.dart';
import '../../providers/theme_provider.dart';
import '../../../ui/device.dart';

class LabelListTile extends ConsumerWidget {
  const LabelListTile(
    this.labelController, {
    super.key,
  });

  final TextEditingController labelController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(appThemeStateNotifier).isDarkModeEnabled;

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(Sizes.lg, Sizes.lg, Sizes.xxl, Sizes.lg),
      child: Row(
        children: [
          RoundedIcon(
            icon: Icons.description,
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: Sizes.lg),
          Text(
            "Description",
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: Sizes.lg),
          Expanded(
            child: TextField(
              controller: labelController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Add a description",
              ),
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: isDarkMode
                        ? grey3
                        : Theme.of(context).colorScheme.secondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
