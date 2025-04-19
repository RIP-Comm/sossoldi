import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "rounded_icon.dart";
import "../device.dart";
import "details_list_tile.dart";

class NonEditableDetailsListTile extends DetailsListTile {
  NonEditableDetailsListTile({
    required super.title,
    required super.icon,
    required super.value,
    super.key,
  }) : super(
          callback: () {},
        );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.all(Sizes.lg),
      tileColor: Theme.of(context).colorScheme.surface,
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
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: Colors.grey),
          ),
          const SizedBox(width: Sizes.sm)
        ],
      ),
    );
  }
}
