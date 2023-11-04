import 'package:flutter/material.dart';
import 'package:mova_cards/utils/word_update_controller.dart';
import 'package:test/test.dart';

void main() {
  group('alreadyUpdated tests', () {
    test('Need update, lastUpdate yesterday.', () {
      TimeOfDay updateTime = const TimeOfDay(hour: 20, minute: 10); // 20:10
      DateTime lastUpdate = DateTime(2023, 7, 20, 22); // 20 Jul 2023, 22:00:00

      DateTime timeNow = DateTime(2023, 7, 21, 20, 25); // 21 Jul 2023, 20:25:00

      // Shouldn't be updated.
      assert(!WordUpdateController.isUpdated(
          lastUpdate.millisecondsSinceEpoch, timeNow, updateTime));
    });

    test('Need update, lastUpdate before yesterday.', () {
      TimeOfDay updateTime = const TimeOfDay(hour: 20, minute: 10); // 20:10
      DateTime lastUpdate = DateTime(2023, 7, 20, 19); // 20 Jul 2023, 19:00:00

      DateTime timeNow = DateTime(2023, 7, 21, 20, 25); // 21 Jul 2023, 20:25:00

      // Shouldn't be updated.
      assert(!WordUpdateController.isUpdated(
          lastUpdate.millisecondsSinceEpoch, timeNow, updateTime));
    });

    test('Don\'t need update, lastUpdate today', () {
      TimeOfDay updateTime = const TimeOfDay(hour: 20, minute: 10); // 20:10
      DateTime timeNow = DateTime(2023, 7, 20, 23, 25); // 20 Jul 2023, 23:25:00

      DateTime lastUpdate = DateTime(2023, 7, 20, 22); // 20 Jul 2023, 22:00:00

      // Should be already updated.
      assert(WordUpdateController.isUpdated(
          lastUpdate.millisecondsSinceEpoch, timeNow, updateTime));
    });

    test('Don\'t need update, lastUpdate yesterday', () {
      TimeOfDay updateTime = const TimeOfDay(hour: 20, minute: 10); // 20:10
      DateTime timeNow = DateTime(2023, 7, 21, 19, 25); // 21 Jul 2023, 19:25:00

      DateTime lastUpdate = DateTime(2023, 7, 20, 22); // 20 Jul 2023, 22:00:00

      // Should be already updated.
      assert(WordUpdateController.isUpdated(
          lastUpdate.millisecondsSinceEpoch, timeNow, updateTime));
    });

    test('Need update, 00:00 case', () {
      TimeOfDay updateTime = const TimeOfDay(hour: 0, minute: 0); // 00:00
      DateTime timeNow = DateTime(2023, 7, 21, 19, 25); // 21 Jul 2023, 19:25:00

      DateTime lastUpdate = DateTime(2023, 7, 20, 22); // 20 Jul 2023, 22:00:00

      assert(!WordUpdateController.isUpdated(
          lastUpdate.millisecondsSinceEpoch, timeNow, updateTime));
    });

    test('Don\'t need update, 00:00 case', () {
      TimeOfDay updateTime = const TimeOfDay(hour: 0, minute: 0); // 00:00
      DateTime timeNow = DateTime(2023, 7, 20, 19, 25); // 20 Jul 2023, 19:25:00

      DateTime lastUpdate =
          DateTime(2023, 7, 20, 0, 10); // 20 Jul 2023, 00:10:00

      assert(WordUpdateController.isUpdated(
          lastUpdate.millisecondsSinceEpoch, timeNow, updateTime));
    });

    test('Need update, last one was a week ago', () {
      TimeOfDay updateTime = const TimeOfDay(hour: 20, minute: 10); // 20:10
      DateTime timeNow = DateTime(2023, 7, 27, 19, 25); // 27 Jul 2023, 19:25:00

      DateTime lastUpdate =
          DateTime(2023, 7, 20, 0, 10); // 20 Jul 2023, 00:10:00

      assert(!WordUpdateController.isUpdated(
          lastUpdate.millisecondsSinceEpoch, timeNow, updateTime));
    });

    test('Don\'t need update, last one is much higher', () {
      TimeOfDay updateTime = const TimeOfDay(hour: 20, minute: 10); // 20:10
      DateTime timeNow = DateTime(2023, 7, 27, 19, 25); // 27 Jul 2023, 19:25:00

      DateTime lastUpdate =
          DateTime(2023, 9, 20, 0, 10); // 20 Jul 2023, 00:10:00

      assert(WordUpdateController.isUpdated(
          lastUpdate.millisecondsSinceEpoch, timeNow, updateTime));
    });
  });
}
