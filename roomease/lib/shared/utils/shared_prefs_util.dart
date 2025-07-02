import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtility {
  static late final SharedPreferences sharedPrefs;
  static Future init() async {
    sharedPrefs = await SharedPreferences.getInstance();
  }

  static setValue(String key, Object value) {
    switch (value.runtimeType) {
      case String:
        sharedPrefs.setString(key, value as String);
        break;
      case bool:
        sharedPrefs.setBool(key, value as bool);
        break;
      case int:
        sharedPrefs.setInt(key, value as int);
        break;
      case List<String>:
        sharedPrefs.setStringList(key, value as List<String>);
        break;
      default:
    }
  }

  static String getString(String key) {
    return sharedPrefs.getString(key) ?? "";
  }

  static bool getBool(String key) {
    return sharedPrefs.getBool(key) ?? false;
  }

  static int getInt(String key) {
    return sharedPrefs.getInt(key) ?? -1;
  }

  static List<String> getStringList(String key) {
    return sharedPrefs.getStringList(key) ?? List.empty();
  }

  static void clear() async {
    await sharedPrefs.clear();
  }
}
