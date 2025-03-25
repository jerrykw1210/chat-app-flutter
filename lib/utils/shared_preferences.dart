import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PrefsStorage {
  // init SharedPreferences
  static Future init() async {
    prefs = await SharedPreferences.getInstance();
  }

  // variable
  static late SharedPreferences prefs;

  static var conversations = SharedPrefsObject("conversations");
  static var user = SharedPrefsObject("user");
  static var userLanguage = SharedPrefsObject("language");
  static var userLanguageList = SharedPrefsObject("languageList");
  static var appEnvironment = SharedPrefsObject("appEnvironment");
  static var newMessageNotification =
      SharedPrefsObject("newMessageNotification");
  static var inAppSound = SharedPrefsObject("inAppSound");
  static var inAppVibration = SharedPrefsObject("inAppVibration");
}

class SharedPrefsObject {
  //variable
  String key;

  // constructor
  SharedPrefsObject(this.key);

  //region: Method
  String get stringValue {
    final String? value = PrefsStorage.prefs.getString(key);
    return (value == null) ? "" : (value);
  }

  int get intValue {
    final int? value = PrefsStorage.prefs.getInt(key);
    if (value == null) {
      return 0;
    }
    return (value);
  }

  bool get boolValue {
    final bool? value = PrefsStorage.prefs.getBool(key);
    if (value == null) {
      if (key == "newMessageNotification" || key == "inAppSound" || key == "inAppVibration") {
        return true;
      } 
      return false;
    }
    return value;
  }

  List get listValue {
    final List? value = PrefsStorage.prefs.getStringList(key);
    if (value == null) {
      return [];
    }
    return value;
  }
  //endregion

  saveJson(json) {
    String user = jsonEncode(json);
    PrefsStorage.prefs.setString(key, user);
  }

  setString(String value) {
    PrefsStorage.prefs.setString(key, value);
  }

  setInt(int value) {
    PrefsStorage.prefs.setInt(key, value);
  }

  setBool(bool value) {
    PrefsStorage.prefs.setBool(key, value);
  }

  setStringList(List<String> value) {
    PrefsStorage.prefs.setStringList(key, value);
  }
}
