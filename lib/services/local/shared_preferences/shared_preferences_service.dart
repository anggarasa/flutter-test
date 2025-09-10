import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static Future<SharedPreferences> get _instance async {
    return preferences ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences? preferences;

  static Future<SharedPreferences> init() async {
    preferences = await _instance;
    return preferences ?? await SharedPreferences.getInstance();
  }

  static Future<void> clearAll() async {
    await preferences?.clear();
  }
}
