import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../providers/settings_provider.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'sossoldi#reminder', // id del canale
    'Reminder', // nome del canale
    importance: Importance.high,
  );

  Future<void> initializeNotifications() async {
    var initializeSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializeSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    var initializationSettings = InitializationSettings(
      android: initializeSettingsAndroid,
      iOS: initializeSettingsIOS,
    );
    await notificationsPlugin.initialize(initializationSettings);
    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> requestNotificationPermissions() async {
    if (Platform.isIOS) {
      await notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      bool? notificationEnabled = await notificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;
      // If notificaitons are not enabled popup the request
      if (!notificationEnabled) {
        notificationEnabled = await notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission() ?? false;
      }
      if (notificationEnabled) {
        bool? canSchedule = await notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.canScheduleExactNotifications() ?? false;
        if (!canSchedule) {
          await notificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.requestExactAlarmsPermission();
        }
      }
    }
  }

  static Future<void> scheduleNotification({
    required String title,
    required String body,
    int id = 0,
    NotificationReminderType recurrence = NotificationReminderType.daily,
  }) async {
    NotificationDetails notificationDetails = const NotificationDetails(
      android: AndroidNotificationDetails(
        'sossoldi#reminder',
        'reminder',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    // Get today's date
    final DateTime now = DateTime.now();
    DateTime scheduledDate;
    DateTimeComponents matchDateTimeComponents = DateTimeComponents.time;

    if (recurrence == NotificationReminderType.daily) {
      // Check if current time is past 21:00
      if (now.hour < 21) {
        // Schedule for today at 21:00
        scheduledDate = DateTime(now.year, now.month, now.day, 21, 0);
      } else {
        // Schedule for tomorrow at 21:00
        scheduledDate = DateTime(now.year, now.month, now.day + 1, 21, 0);
      }
    } else if (recurrence == NotificationReminderType.weekly) {
      // Find the nearest Sunday
      int daysUntilSunday = (DateTime.sunday - now.weekday) % 7;
      if (daysUntilSunday == 0 && now.hour >= 21) {
        // If today is Sunday and it's past 21:00, schedule for next Sunday
        daysUntilSunday = 7;
      }
      scheduledDate =
          DateTime(now.year, now.month, now.day + daysUntilSunday, 21, 0);
      matchDateTimeComponents = DateTimeComponents.dayOfWeekAndTime;
    } else {
      // Find the nearest first of the next month
      if (now.day == 1 && now.hour < 21) {
        // If today is the first and it's before 21:00, schedule for today
        scheduledDate = DateTime(now.year, now.month, now.day, 21, 0);
      } else {
        // Schedule for the first of the next month
        scheduledDate = DateTime(now.year, now.month + 1, 1, 21, 0);
      }
      matchDateTimeComponents = DateTimeComponents.dayOfMonthAndTime;
    }

    // ? Uncomment the following line to test the notification after 10 seconds
    // scheduledDate = DateTime.now().add(const Duration(seconds: 10));

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: matchDateTimeComponents,
    );
  }

  static Future<void> cancelNotification({int id = 0}) async {
    await notificationsPlugin.cancel(id);
  }
}
