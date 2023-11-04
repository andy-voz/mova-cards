import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DarkModeController {
  static const String darkThemeEnabledKey = 'darkThemeEnabled';

  final Function _updateCallback;

  bool _darkTheme = false;
  get darkTheme => _darkTheme;

  DarkModeController(this._updateCallback);

  void init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    bool? savedValue = prefs.getBool(darkThemeEnabledKey);
    if (savedValue == null) {
      setValue(brightness == Brightness.dark);
    }
    else
    {
      _updateCallback(() {
        _darkTheme = savedValue;
      });
    }
  }

  setValue(bool value) async {
    _updateCallback(() {
      _darkTheme = value;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(darkThemeEnabledKey, value);
  }
}
