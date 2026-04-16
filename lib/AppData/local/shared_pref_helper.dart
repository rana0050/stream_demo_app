import 'package:shared_preferences/shared_preferences.dart';
import 'package:streaming_demo_app/AppFunctions/app_strings.dart';

class SharedPreferencesHelper {
  static final SharedPreferencesHelper _instance = SharedPreferencesHelper._ctor();

  static String userName = 'USERNAME';
  static String userRole = 'USER_ROLE';
  static String playerId = 'PLAYER_ID';

  factory SharedPreferencesHelper() {
    return _instance;
  }

  SharedPreferencesHelper._ctor();
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  //---------------------------------------------------------------

  static void setUserName({required String name}) {
    _prefs.setString(userName, name);
  }

  static String getUserName() {
    return _prefs.getString(userName) ?? "";
  }

  //---------------------------------------------------------------

  static void setUserRole({required String role}) {
    _prefs.setString(userRole, role);
  }

  static String getUserRole() {
    return _prefs.getString(userRole) ?? "";
  }

  //---------------------------------------------------------------

  static void setPlayerId({required String id}) {
    _prefs.setString(playerId, id);
  }

  static String getPlayerId() {
    return _prefs.getString(playerId) ?? "";
  }

  //-------------------------------------------------------------------

  static void clearShareCache() {
    _prefs.clear();
  }

  //
}
