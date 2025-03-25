import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceInfoClass {
  static late DeviceInfoPlugin deviceInfo;

  static String osInfo = Platform.operatingSystem.toUpperCase();

  static late IosDeviceInfo iosDevice;
  static late AndroidDeviceInfo androidDevice;
  static late PackageInfo packageInfo;

  static String deviceId = "";
  // init Device Info
  static Future init() async {
    deviceInfo = DeviceInfoPlugin();

    // will cause crash  if iphone get androidInfo, so do a platform checking
    if (Platform.isIOS) {
      iosDevice = await deviceInfo.iosInfo;
    } else {
      androidDevice = await deviceInfo.androidInfo;
    }

    packageInfo = await PackageInfo.fromPlatform();
  }

  static String getDeviceModel() {
    if (Platform.isIOS) {
      return iosDevice.model;
    } else if (Platform.isAndroid) {
      return androidDevice.model;
    } else {
      return "";
    }
  }

  static String getDeviceId() {
    if (Platform.isIOS) {
      log("device id : ${iosDevice.identifierForVendor}");
      return iosDevice.identifierForVendor ?? ""; // unique ID on iOS
    } else if (Platform.isAndroid) {
      return androidDevice.id;
    } else {
      return "";
    }
  }

  static String getDeviceOSVersion() {
    if (Platform.isIOS) {
      return iosDevice.systemVersion;
    } else if (Platform.isAndroid) {
      return androidDevice.version.release;
    } else {
      return "";
    }
  }

  static String getAppVersion() {
    // String appName = packageInfo.appName;
    // String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    // String buildNumber = packageInfo.buildNumber;

    return version;
  }
}
