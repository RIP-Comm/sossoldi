import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/notifications_service.dart';

enum NotificationReminderType {
  none,
  daily,
  weekly,
  monthly,
}

final transactionReminderSwitchProvider = StateProvider.autoDispose<bool>((ref) => false);
final transactionReminderCadenceProvider =
    StateProvider.autoDispose<NotificationReminderType>((ref) => NotificationReminderType.none);
final transactionRecReminderSwitchProvider = StateProvider.autoDispose<bool>((ref) => false);
final transactionRecAddedSwitchProvider = StateProvider.autoDispose<bool>((ref) => false);

class AsyncSettingsNotifier extends AutoDisposeAsyncNotifier<dynamic> {
  @override
  Future<dynamic> build() async {
    return _getSettings();
  }

  Future<void> _getSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    ref.read(transactionReminderSwitchProvider.notifier).state =
        prefs.getBool('transaction-reminder') ?? false;
    ref.read(transactionReminderCadenceProvider.notifier).state = NotificationReminderType.values
        .firstWhere((value) => value.name == prefs.getString('transaction-reminder-cadence'));
    ref.read(transactionRecReminderSwitchProvider.notifier).state =
        prefs.getBool('transaction-rec-reminder') ?? false;
    ref.read(transactionRecAddedSwitchProvider.notifier).state =
        prefs.getBool('transaction-rec-added') ?? false;
  }

  Future<void> updateNotificationReminder({bool active = true}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (active) {
        if (ref.read(transactionReminderCadenceProvider) == NotificationReminderType.none) {
          ref.read(transactionReminderCadenceProvider.notifier).state =
              NotificationReminderType.daily;
        }
        await prefs.setBool('transaction-reminder', true);
        await prefs.setString(
          'transaction-reminder-cadence',
          ref.read(transactionReminderCadenceProvider).name,
        );
        await NotificationService.scheduleNotification(
          title: "Remember to log new expenses!",
          body:
              "Sossoldi is waiting for your latest transactions. Don't lose sight of your financial movements, and input your most recent expenses.",
          recurrence: ref.read(transactionReminderCadenceProvider),
        );
      } else {
        ref.invalidate(transactionReminderCadenceProvider);
        await prefs.remove('transaction-reminder');
        await prefs.remove('transaction-reminder-cadence');
        await NotificationService.cancelNotification();
      }

      return _getSettings();
    });
  }

  Future<void> updateNotificationRecurring({bool active = true}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
          'transaction-rec-reminder', ref.read(transactionRecReminderSwitchProvider));
      await prefs.setBool('transaction-rec-added', ref.read(transactionRecAddedSwitchProvider));

      return _getSettings();
    });
  }
}

final settingsProvider = AutoDisposeAsyncNotifierProvider<AsyncSettingsNotifier, dynamic>(() {
  return AsyncSettingsNotifier();
});
