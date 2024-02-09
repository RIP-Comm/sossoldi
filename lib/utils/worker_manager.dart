import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:workmanager/workmanager.dart";

import "../pages/notifications/notifications_service.dart";
import "../providers/settings_provider.dart";

//tasks
const taskShowNotification = "showNotification";

@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() async {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case taskShowNotification:
        await notificationsPlugin.show(
            0,
            "Weekly reminder",
            "Remember to fill your weekly movements!",
            const NotificationDetails(
              android: AndroidNotificationDetails(
                  'sossoldi#reminder', 'reminder',
                  importance: Importance.max, priority: Priority.max),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ));
    }
    return Future.value(true);
  });
}

void scheduleTransactionReminder(NotificationReminderType type) {
  Workmanager().cancelByUniqueName("#reminder").then((value) => {
    Workmanager().registerPeriodicTask("sossoldi#reminder", taskShowNotification, frequency: Duration(days: type == NotificationReminderType.daily ? 1 : type == NotificationReminderType.weekly ? 7 : 30))
  });
}

void scheduleAlertRecursiveTransaction() {
  //TODO
  Workmanager().cancelByUniqueName("#alert").then((value) => {
        Workmanager().registerPeriodicTask("#alert", taskShowNotification,
            frequency: const Duration(days: 30))
      });
}
