import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

final log = Logger('Notifications');

class NotificationManager {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Future<bool?> init() async {
    if (!Platform.isAndroid) {
      return false;
    }

    tz.initializeTimeZones();

    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@drawable/ic_notifications');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    return flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleDailyNotifications(DateTime? time) async {
    if (!Platform.isAndroid) {
      return;
    }

    bool? canNotify = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();

    if (canNotify != null && canNotify) {
      flutterLocalNotificationsPlugin.cancelAll();
      if (time == null) return;

      var scheduledNotificationTZDateTime = tz.TZDateTime.from(time, tz.local);

      flutterLocalNotificationsPlugin.zonedSchedule(
          0,
          'Мова: Карткі',
          'Запрашаю прагледзіць новае слова!',
          scheduledNotificationTZDateTime,
          const NotificationDetails(
              android: AndroidNotificationDetails(
                  'MovaCardsChannelID', 'Штодзённыя',
                  channelDescription: 'Вывучай новае слова кожны дзень!',
                  importance: Importance.max,
                  priority: Priority.max)),
          androidScheduleMode: AndroidScheduleMode.inexact,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time);

      log.info(
          'A Notification is scheduled for $scheduledNotificationTZDateTime');
    }
  }
}
