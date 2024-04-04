import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static const String updateHourKey = 'updateHour';
  static const String updateMinuteKey = 'updateMinute';
  static const String lastUpdateTimeKey = 'lastUpdateTime';
  static const String tutorialKey = 'tutorial';
  static const String rateUsKey = 'rateUsShowed';

  static const String collectionsKey = 'collection_';

  late SharedPreferences prefs;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }
  
  bool? getRateUsShowed() {
    return prefs.getBool(rateUsKey);
  }

  void setRateUsShowed() {
    prefs.setBool(rateUsKey, true);
  }

  bool? getTutorialPassed() {
    return prefs.getBool(tutorialKey);
  }

  void setTutorialPassed() async {
    prefs.setBool(tutorialKey, true);
  }

  int? getUpdateHour() {
    return prefs.getInt(updateHourKey);
  }

  void setUpdateHour(int hour) {
    prefs.setInt(updateHourKey, hour);
  }

  int? getUpdateMinute() {
    return prefs.getInt(updateMinuteKey);
  }

  void setUpdateMinute(int minute) {
    prefs.setInt(updateMinuteKey, minute);
  }

  int? getLastUpdateTime() {
    return prefs.getInt(lastUpdateTimeKey);
  }

  void setLastUpdateTime(int time) {
    prefs.setInt(lastUpdateTimeKey, time);
  }

  bool getCollectionState(String collectionName) {
    bool? existingValue = prefs.getBool(collectionsKey + collectionName);
    return existingValue ?? true;
  }

  void setCollectionState(String collectionName, bool state) {
    prefs.setBool(collectionsKey + collectionName, state);
  }
}
