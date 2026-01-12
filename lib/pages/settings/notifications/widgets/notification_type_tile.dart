import 'package:flutter/material.dart';

import '../../../../providers/settings_provider.dart';
import '../../../../ui/device.dart';

class NotificationTypeTile extends StatelessWidget {
  final NotificationReminderType type;
  final bool selected;
  final VoidCallback setNotificationTypeCallback;

  const NotificationTypeTile({
    super.key,
    required this.type,
    required this.selected,
    required this.setNotificationTypeCallback,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: setNotificationTypeCallback.call,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: Sizes.xs),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.secondary
                : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(Sizes.borderRadiusSmall),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Sizes.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${type.name[0].toUpperCase()}${type.name.substring(1)}",
                style: TextStyle(
                  color: selected
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
              if (selected)
                Icon(
                  Icons.check,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
