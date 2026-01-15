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
  bool build() {
    final SharedPreferences prefs = ref.watch(sharedPrefProvider);
    return prefs.getBool('visibility_amount') ?? false;
  }

  Future<void> setVisibility(bool visibility) async {
    final SharedPreferences prefs = ref.read(sharedPrefProvider);
    await prefs.setBool('visibility_amount', visibility);
    state = visibility;
  }
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
  Future<void> build() async {
    return await _getSettings();
  }

  Future<void> _getSettings() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final SharedPreferences prefs = ref.watch(sharedPrefProvider);
      final trscReminder = prefs.getBool('transaction-reminder') ?? false;
      final cadenceStr = prefs.getString('transaction-reminder-cadence');
      final recReminder = prefs.getBool('transaction-rec-reminder') ?? false;
      final recAdded = prefs.getBool('transaction-rec-added') ?? false;
      Future.microtask(() {
        ref
            .read(transactionReminderSwitchProvider.notifier)
            .setValue(trscReminder);
        if (cadenceStr != null) {
          final cadence = NotificationReminderType.values.firstWhere(
            (value) => value.name == cadenceStr,
            orElse: () => NotificationReminderType.none,
          );
          ref
              .read(transactionReminderCadenceProvider.notifier)
              .setValue(cadence);
        }
        ref
            .read(transactionRecReminderSwitchProvider.notifier)
            .setValue(recReminder);
        ref.read(transactionRecAddedSwitchProvider.notifier).setValue(recAdded);
      });
    });
  }

  Future<void> updateNotificationReminder({
    bool active = true,
    NotificationReminderType type = NotificationReminderType.daily,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final SharedPreferences prefs = ref.watch(sharedPrefProvider);
      ref.read(transactionReminderSwitchProvider.notifier).setValue(active);
      if (active) {
        ref.read(transactionReminderCadenceProvider.notifier).setValue(type);
        await prefs.setBool('transaction-reminder', true);
        await prefs.setString('transaction-reminder-cadence', type.name);
        await NotificationService.scheduleNotification(
          title: "Remember to log new expenses!",
          body:
              "Sossoldi is waiting for your latest transactions. Don't lose sight of your financial movements, and input your most recent expenses.",
          recurrence: type,
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
      final SharedPreferences prefs = ref.watch(sharedPrefProvider);
      ref.read(transactionRecAddedSwitchProvider.notifier).setValue(active);
      if (active) {
        await prefs.setBool('transaction-rec-added', active);
      } else {
        await prefs.remove('transaction-rec-added');
      }

      return _getSettings();
    });
  }
}
