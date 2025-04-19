import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/settings_provider.dart';

class NotificationTypeTile extends ConsumerWidget {
  final NotificationReminderType type;
  final VoidCallback setNotificationTypeCallback;

  const NotificationTypeTile({
    super.key,
    required this.type,
    required this.setNotificationTypeCallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionReminderCadence =
        ref.watch(transactionReminderCadenceProvider);

    return GestureDetector(
      onTap: setNotificationTypeCallback.call,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          border: Border.all(
            color: transactionReminderCadence == type
                ? Theme.of(context).colorScheme.secondary
                : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Text(
                "${type.name[0].toUpperCase()}${type.name.substring(1)}",
                style: TextStyle(
                  color: transactionReminderCadence == type
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
              const Spacer(),
              if (transactionReminderCadence == type)
                Icon(
                  Icons.check,
                  color: Theme.of(context).colorScheme.secondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
