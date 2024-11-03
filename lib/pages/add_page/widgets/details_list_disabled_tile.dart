import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../constants/style.dart";
import "details_list_tile.dart";

class NonEditableDetailsListTile extends DetailsListTile {
  NonEditableDetailsListTile({
    required String title,
    required IconData icon,
    required String? value,
    Key? key,
  }) : super(
    title: title,
    icon: icon,
    value: value,
    callback: () {}, // Override the callback to make it non-editable
    key: key,
  );

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
          color: Theme.of(context).colorScheme.background,
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
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: Colors.grey), // Make the text gray
          ),
          const SizedBox(width: 6.0)
        ],
      ),
    );
  }
}