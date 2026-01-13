import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/style.dart';
import '../../../providers/settings_provider.dart';
import '../../../ui/device.dart';
import '../../../services/notifications/notifications_service.dart';
import 'widgets/notification_type_tile.dart';

class NotificationsSettings extends ConsumerWidget {
  const NotificationsSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(notificationsProvider, (_, _) {});
    final isTrscReminderEnabled = ref.watch(transactionReminderSwitchProvider);
    final trscReminderCadence = ref.watch(transactionReminderCadenceProvider);
    final isTrscAddedReminderEnabled = ref.watch(
      transactionRecAddedSwitchProvider,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: Sizes.xl,
              horizontal: Sizes.lg,
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  padding: const EdgeInsets.all(Sizes.sm),
                  child: Icon(
                    Icons.notifications_active,
                    size: 24.0,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 12.0),
                Text(
                  "Notifications",
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: Sizes.lg),
            padding: const EdgeInsets.symmetric(
              horizontal: Sizes.lg,
              vertical: Sizes.md,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(Sizes.borderRadiusSmall),
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
                    Switch.adaptive(
                      value: isTrscReminderEnabled,
                      onChanged: (value) async {
                        await NotificationService()
                            .requestNotificationPermissions();
                        ref
                            .read(notificationsProvider.notifier)
                            .updateNotificationReminder(active: value);
                      },
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  crossFadeState: isTrscReminderEnabled
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 150),
                  firstChild: const SizedBox(),
                  secondChild: Column(
                    children: NotificationReminderType.values
                        .where((type) => type != NotificationReminderType.none)
                        .map((type) {
                          return NotificationTypeTile(
                            type: type,
                            selected: trscReminderCadence == type,
                            setNotificationTypeCallback: () {
                              ref
                                  .read(notificationsProvider.notifier)
                                  .updateNotificationReminder(type: type);
                            },
                          );
                        })
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(
              left: Sizes.xxl,
              top: Sizes.xl,
              bottom: Sizes.sm,
            ),
            child: Text(
              "RECURRING TRANSACTIONS",
              style: Theme.of(
                context,
              ).textTheme.labelLarge!.copyWith(color: grey1),
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: Sizes.lg),
            padding: const EdgeInsets.symmetric(
              horizontal: Sizes.lg,
              vertical: Sizes.md,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(Sizes.borderRadiusSmall),
            ),
            child: Column(
              spacing: Sizes.md,
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
                    Switch.adaptive(
                      value: isTrscAddedReminderEnabled,
                      onChanged: (value) {
                        ref
                            .read(notificationsProvider.notifier)
                            .updateNotificationRecurring(active: value);
                      },
                    ),
                  ],
                ),
                // TODO: Implement this feature
                // const Divider(height: 1, color: grey2),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Expanded(
                //       child: Text(
                //         "Recurring transaction reminder",
                //         style: Theme.of(context).textTheme.bodyMedium,
                //       ),
                //     ),
                //     Switch.adaptive(
                //       value: ref.watch(transactionRecReminderSwitchProvider),
                //       onChanged: (value) {
                //         ref.read(transactionRecReminderSwitchProvider.notifier).setValue(value);
                //         // ref.read(notificationsProvider.notifier).updateNotifications(active: value);
                //       },
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
