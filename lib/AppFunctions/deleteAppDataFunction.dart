import 'package:streaming_demo_app/AppData/local/constant.dart';
import 'package:streaming_demo_app/AppData/local/shared_pref_helper.dart';

void deleteAppDataFunction() {
  constant.userName = "";
  constant.userRole = "";
  constant.playerId = "";
  constant.currentDeviceId = "";
  constant.currentOsVersion = "";
  constant.currentAppVersion = "";
  constant.currentDeviceName = "";
  constant.currentDeviceType = "";
  constant.currentFcmToken = '';
  constant.currentApnsToken = '';
  constant.currentOperatingSystem = '';

  SharedPreferencesHelper.clearShareCache();
}
