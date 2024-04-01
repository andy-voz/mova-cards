import 'package:flutter/material.dart';

import 'prefs.dart';
import 'notifications.dart';
import 'package:logging/logging.dart';
import 'dart:async';

final log = Logger('WordUpdateController');

class WordUpdateController {
  final Prefs _prefs;
  final BuildContext _context;
  final Function _regenerateCallback;

  late TimeOfDay _updateTime;
  late NotificationManager _notificationManager;

  DateTime? _nextUpdateDateTime;
  Timer? _updateTimer;

  WordUpdateController(this._context, this._prefs, this._regenerateCallback);

  static bool isUpdateTimeLowerThen(TimeOfDay updateTime, TimeOfDay otherTime) {
    return otherTime.hour > updateTime.hour ||
        (otherTime.hour == updateTime.hour &&
            otherTime.minute >= updateTime.minute);
  }

  static bool isUpdated(
      int lastUpdateMillis, DateTime timeNow, TimeOfDay updateTime) {
    DateTime lastUpdateDateTime =
        DateTime.fromMillisecondsSinceEpoch(lastUpdateMillis);

    DateTime thisDayUpdate = DateTime(timeNow.year, timeNow.month, timeNow.day,
        updateTime.hour, updateTime.minute);

    // If last update time is higher than this day update, we definitely don't need an update.
    if (lastUpdateDateTime.compareTo(thisDayUpdate) > 0) {
      return true;
    }

    DateTime previousUpdate = thisDayUpdate.subtract(const Duration(days: 1));
    // We definitely need an update if lastUpdate was before the previous day update.
    if (lastUpdateDateTime.compareTo(previousUpdate) < 0) {
      return false;
    } else {
      // We updated after the previos day updateTime at this point
      // but wasn't updated today. So will check if the current time is higher than this day update time.
      return timeNow.compareTo(thisDayUpdate) < 0;
    }
  }

  void init() {
    _notificationManager = NotificationManager();
    _notificationManager.init().then((value) => _scheduleNextUpdate());
    _loadUpdateTime();
  }

  bool alreadyUpdated() {
    int? lastUpdateMillis = _prefs.getLastUpdateTime();
    if (lastUpdateMillis == null) return false;

    return isUpdated(lastUpdateMillis, DateTime.now(), _updateTime);
  }

  void configureUpdateTime() async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: _context,
      initialTime: _updateTime,
      helpText: 'Час абнаўлення слова',
      cancelText: 'Назад',
      confirmText: 'Добра',
      hourLabelText: 'Гадзіна',
      minuteLabelText: 'Хвіліна',
      errorInvalidText: 'Не валідны час',
      initialEntryMode: TimePickerEntryMode.input,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      _updateTime = selectedTime;
      _saveUpdateTime();
      _scheduleNextUpdate();
    }
  }

  Future<void> _saveUpdateTime() async {
    _prefs.setUpdateHour(_updateTime.hour);
    _prefs.setUpdateMinute(_updateTime.minute);
  }

  bool _isUpdateTimeLowerThen(TimeOfDay otherTime) {
    return isUpdateTimeLowerThen(_updateTime, otherTime);
  }

  void _loadUpdateTime() {
    int? updateHour = _prefs.getUpdateHour();
    int? updateMinute = _prefs.getUpdateMinute();

    if (updateHour != null && updateMinute != null) {
      _updateTime = TimeOfDay(hour: updateHour, minute: updateMinute);
    } else {
      _updateTime = TimeOfDay.now();
      _saveUpdateTime();
    }
  }

  void _scheduleNextUpdate() {
    if (_updateTimer != null) {
      _updateTimer!.cancel();
    }

    var now = DateTime.now();

    // Schedule the notification at the selected time
    _nextUpdateDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _updateTime.hour,
      _updateTime.minute,
    );

    // Checking do we need to schedule a notification for the next day.
    if (_isUpdateTimeLowerThen(TimeOfDay(hour: now.hour, minute: now.minute))) {
      _nextUpdateDateTime = _nextUpdateDateTime!.add(const Duration(days: 1));
    }

    _updateTimer = Timer(
        Duration(
            milliseconds: _nextUpdateDateTime!.millisecondsSinceEpoch -
                now.millisecondsSinceEpoch), () {
      _regenerateCallback();
      _scheduleNextUpdate();
    });

    log.info('Scheduled next update at $_nextUpdateDateTime');

    _notificationManager.scheduleDailyNotifications(_nextUpdateDateTime);
  }
}
