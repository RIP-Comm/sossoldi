import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/notifications/notifications_service.dart';

part 'settings_provider.g.dart';

@Riverpod(keepAlive: true)
String version(Ref ref) => '0.0.0'; // Default value until initialized

@Riverpod(keepAlive: true)
SharedPreferences sharedPref(Ref ref) => throw UnimplementedError();

@Riverpod(keepAlive: true)
bool onBoardingCompleted(Ref ref) {
  final SharedPreferences prefs = ref.watch(sharedPrefProvider);
  return prefs.getBool('onboarding_completed') ?? false;
}

@Riverpod(keepAlive: true)
class VisibilityAmount extends _$VisibilityAmount {
  @override
  bool build() => false;

  void setVisibility(bool visibility) => state = visibility;
}

enum NotificationReminderType { none, daily, weekly, monthly }

@Riverpod(keepAlive: true)
class TransactionReminderSwitch extends _$TransactionReminderSwitch {
  @override
  bool build() => false;

  void setValue(bool value) => state = value;
}

@Riverpod(keepAlive: true)
class TransactionReminderCadence extends _$TransactionReminderCadence {
  @override
  NotificationReminderType build() => NotificationReminderType.none;

  void setValue(NotificationReminderType value) => state = value;
}

@Riverpod(keepAlive: true)
class TransactionRecReminderSwitch extends _$TransactionRecReminderSwitch {
  @override
  bool build() => false;

  void setValue(bool value) => state = value;
}

@Riverpod(keepAlive: true)
class TransactionRecAddedSwitch extends _$TransactionRecAddedSwitch {
  @override
  bool build() => false;

  void setValue(bool value) => state = value;
}

@Riverpod(keepAlive: true)
class Notifications extends _$Notifications {
  @override
  Future<dynamic> build() async {
    return _getSettings();
  }

  Future<void> _getSettings() async {
    final SharedPreferences prefs = ref.watch(sharedPrefProvider);
    ref.read(transactionReminderSwitchProvider.notifier).state =
        prefs.getBool('transaction-reminder') ?? false;
    ref
        .read(transactionReminderCadenceProvider.notifier)
        .state = NotificationReminderType.values.firstWhere(
      (value) => value.name == prefs.getString('transaction-reminder-cadence'),
    );
    ref.read(transactionRecReminderSwitchProvider.notifier).state =
        prefs.getBool('transaction-rec-reminder') ?? false;
    ref.read(transactionRecAddedSwitchProvider.notifier).state =
        prefs.getBool('transaction-rec-added') ?? false;
  }

  Future<void> updateNotificationReminder({bool active = true}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (active) {
        if (ref.read(transactionReminderCadenceProvider) ==
            NotificationReminderType.none) {
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
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
        'transaction-rec-reminder',
        ref.read(transactionRecReminderSwitchProvider),
      );
      await prefs.setBool(
        'transaction-rec-added',
        ref.read(transactionRecAddedSwitchProvider),
      );

      return _getSettings();
    });
  }
}
