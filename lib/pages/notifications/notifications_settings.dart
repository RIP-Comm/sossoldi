import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/style.dart';
import '../../providers/settings_provider.dart';
import 'widgets/notification_type_tile.dart';

class NotificationsSettings extends ConsumerStatefulWidget {
  const NotificationsSettings({super.key});

  @override
  ConsumerState<NotificationsSettings> createState() => _NotificationsSettingsState();
}

class _NotificationsSettingsState extends ConsumerState<NotificationsSettings> {
  @override
  Widget build(BuildContext context) {
    final isReminderEnabled = ref.watch(transactionReminderSwitchProvider);
    ref.listen(settingsProvider, (_, __) {});

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.notifications_active,
                      size: 24.0,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Text(
                    "Notifications",
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge!
                        .copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Add transactions reminder",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      CupertinoSwitch(
                        value: isReminderEnabled,
                        onChanged: (value) {
                          ref.read(transactionReminderSwitchProvider.notifier).state = value;
                          ref
                              .read(settingsProvider.notifier)
                              .updateNotificationReminder(active: value);
                        },
                      ),
                    ],
                  ),
                  AnimatedCrossFade(
                    crossFadeState:
                        isReminderEnabled ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 150),
                    firstChild: const SizedBox(),
                    secondChild: Column(
                      children: NotificationReminderType.values
                          .where((type) => type != NotificationReminderType.none)
                          .map((type) {
                        return NotificationTypeTile(
                          type: type,
                          setNotificationTypeCallback: () {
                            ref.watch(transactionReminderCadenceProvider.notifier).state = type;
                            ref.read(settingsProvider.notifier).updateNotificationReminder();
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 28, top: 24, bottom: 8),
              child: Text(
                "RECURRING TRANSACTIONS",
                style: Theme.of(context).textTheme.labelLarge!.copyWith(color: grey1),
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Recurring transaction added",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      CupertinoSwitch(
                        value: ref.watch(transactionRecAddedSwitchProvider),
                        onChanged: (value) {
                          ref.read(transactionRecAddedSwitchProvider.notifier).state = value;
                          ref
                              .read(settingsProvider.notifier)
                              .updateNotificationRecurring(active: value);
                        },
                      ),
                    ],
                  ),
                  // TODO: Implement this feature
                  // const SizedBox(height: 12),
                  // Divider(
                  //   height: 1,
                  //   color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                  // ),
                  // const SizedBox(height: 12),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Expanded(
                  //       child: Text(
                  //         "Recurring transaction reminder",
                  //         style: Theme.of(context).textTheme.bodyMedium,
                  //       ),
                  //     ),
                  //     CupertinoSwitch(
                  //       value: ref.watch(transactionRecReminderSwitchProvider),
                  //       onChanged: (value) {
                  //         ref.read(transactionRecReminderSwitchProvider.notifier).state = value;
                  //         ref.read(settingsProvider.notifier).updateNotifications(active: value);
                  //       },
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 28, top: 6),
              child: Text(
                "Remind me before a recurring transaction is added",
                style: Theme.of(context).textTheme.labelMedium!.copyWith(color: grey1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
