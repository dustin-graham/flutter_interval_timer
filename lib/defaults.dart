import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class Defaults {
  static const String lastUsedSets = "lastUsedSets";
  static const String lastUsedWorkDurationSeconds = "lastUsedWorkDurationSeconds";
  static const String lastUsedRestDurationSeconds = "lastUsedRestDurationSeconds";

  static const int _defaultSets = 2;
  static const int _defaultWorkDurationSeconds = 20;
  static const int _defaultRestDurationSeconds = 20;

  final SharedPreferences sharedPreferences;

  Defaults(this.sharedPreferences);

  int getDefaultSets() {
    var userSets = sharedPreferences.getInt(lastUsedSets);
    if (userSets == null) {
      return _defaultSets;
    }
    return userSets;
  }

  Future<bool> setDefaultSets(int sets) async {
    return sharedPreferences.setInt(lastUsedSets, sets);
  }

  int getDefaultWorkDuration() {
    var workDuration = sharedPreferences.getInt(lastUsedWorkDurationSeconds);
    if (workDuration == null) {
      return _defaultWorkDurationSeconds;
    }
    return workDuration;
  }

  Future<bool> setDefaultWorkDuration(int workDuration) {
    return sharedPreferences.setInt(lastUsedWorkDurationSeconds, workDuration);
  }

  int getDefaultRestDurationSeconds() {
    var restDuration = sharedPreferences.getInt(lastUsedRestDurationSeconds);
    if (restDuration == null) {
      return _defaultRestDurationSeconds;
    }
    return restDuration;
  }

  Future<bool> setDefaultRestDuration(int restDuration) {
    return sharedPreferences.setInt(lastUsedRestDurationSeconds, restDuration);
  }
}