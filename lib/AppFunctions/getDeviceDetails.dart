import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:streaming_demo_app/AppData/local/constant.dart';

bool isIOS() => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

bool isAndroid() => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

Future<void> getDeviceDetailsForEvents() async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String deviceId = "";
  String osVersion = "";
  String appVersion = "";
  String deviceName = "";
  String deviceType = "";
  String fcmToken = '';
  String apnsToken = '';
  String operatingSystem = '';

  try {
    if (isAndroid()) {
      try {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceName = androidInfo.model;
        deviceId = androidInfo.id;
        osVersion = androidInfo.version.release;
      } catch (e) {
        debugPrint("Error fetching Android device info: $e");
      }
    } else if (isIOS()) {
      try {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceName = iosInfo.utsname.machine;
        deviceId = iosInfo.identifierForVendor ?? "";
        osVersion = iosInfo.systemVersion;
      } catch (e) {
        debugPrint("Error fetching iOS device info: $e");
      }
    }
  } catch (e) {
    debugPrint("Error determining platform: $e");
  }

  try {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
  } catch (e) {
    debugPrint("Error fetching app version: $e");
  }

  try {
    deviceType = isAndroid()
        ? "Android"
        : isIOS()
            ? "iOS"
            : "Web";
  } catch (e) {
    debugPrint("Error determining device type: $e");
  }

  if (Platform.isIOS) {
    try {
      apnsToken = await FirebaseMessaging.instance.getAPNSToken() ?? "";
    } catch (e) {
      debugPrint("Error fetching APNS token: $e");
    }
  } else {
    try {
      fcmToken = (await FirebaseMessaging.instance.getToken()) ?? '';
    } catch (e) {
      debugPrint("Error fetching FCM token: $e");
    }
  }

  try {
    operatingSystem = Platform.operatingSystem;
  } catch (e) {
    debugPrint("Error fetching operating system: $e");
  }

  constant.currentDeviceId = deviceId;
  constant.currentOsVersion = osVersion;
  constant.currentAppVersion = appVersion;
  constant.currentDeviceName = deviceName;
  constant.currentDeviceType = deviceType;
  constant.currentFcmToken = fcmToken;
  constant.currentApnsToken = apnsToken;
  constant.currentOperatingSystem = operatingSystem;

  debugPrint("--------------------------currentDeviceId---------------------------");
  debugPrint(constant.currentDeviceId);
  debugPrint("--------------------------currentOsVersion---------------------------");
  debugPrint(constant.currentOsVersion);
  debugPrint("--------------------------currentAppVersion---------------------------");
  debugPrint(constant.currentAppVersion);
  debugPrint("--------------------------currentDeviceName---------------------------");
  debugPrint(constant.currentDeviceName);
  debugPrint("--------------------------currentDeviceType---------------------------");
  debugPrint(constant.currentDeviceType);
  debugPrint("--------------------------currentFcmToken---------------------------");
  debugPrint(constant.currentFcmToken);
  debugPrint("--------------------------currentApnsToken---------------------------");
  debugPrint(constant.currentApnsToken);
  debugPrint("--------------------------currentOperatingSystem---------------------------");
  debugPrint(constant.currentOperatingSystem);

  //
}
