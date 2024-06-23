import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

final log = Logger('Notifications');

class NotificationManager {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Future<bool?> init() {
    tz.initializeTimeZones();

    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    return flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleDailyNotifications(DateTime? time) async {
    bool? canNotify = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();

    if (canNotify != null && canNotify) {
      flutterLocalNotificationsPlugin.cancelAll();
      if (time == null) return;

      var scheduledNotificationTZDateTime = tz.TZDateTime.from(time, tz.local);

      // We schedule daily notifications for the whole week.
      for (int i = 0; i < 7; ++i) {
        flutterLocalNotificationsPlugin.zonedSchedule(
            0,
            'Мова: Карткі',
            'Запрашаю прагледзіць новае слова!',
            scheduledNotificationTZDateTime,
            const NotificationDetails(
                android: AndroidNotificationDetails(
                    'MovaCardsChannelID', 'Daily',
                    channelDescription: 'Daily word update notifications',
                    importance: Importance.max,
                    priority: Priority.max)),
            androidScheduleMode: AndroidScheduleMode.inexact,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime);

        log.info(
            'A Notification is scheduled for $scheduledNotificationTZDateTime');

        scheduledNotificationTZDateTime =
            scheduledNotificationTZDateTime.add(const Duration(days: 1));
      }
    }
  }
}
