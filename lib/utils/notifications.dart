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
        ?.requestPermission();
    return flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleNotification(DateTime? time) async {
    flutterLocalNotificationsPlugin.cancelAll();
    if (time == null) return;

    var scheduledNotificationTZDateTime = tz.TZDateTime.from(time, tz.local);

    // We schedule daily notifications for the whole week.
    for (int i = 0; i < 7; ++i) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
          0,
          'Мова: Карткі',
          'Запрашаю прагледзіць новае слова!',
          scheduledNotificationTZDateTime,
          const NotificationDetails(
              android: AndroidNotificationDetails('MovaCardsChannelID', 'Daily',
                  channelDescription: 'Daily word update notifications')),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);

      log.info(
          'A Notification is scheduled for $scheduledNotificationTZDateTime');

      if (i > 0) {
        scheduledNotificationTZDateTime.add(const Duration(days: 1));
      }
    }
  }
}
