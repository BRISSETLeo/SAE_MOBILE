import 'package:shared_preferences/shared_preferences.dart';

class SettingRepository {
  // ignore: constant_identifier_names
  static const THEME_KEY = "darkMode";
  // ignore: constant_identifier_names
  static const IDENTIFIANT_KEY = "identifiant";
  // ignore: constant_identifier_names
  static const MOTDEPASSE_KEY = "motdepasse";

  saveSettingsDark(bool value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(THEME_KEY, value);
  }

  saveSettingsIdentifiant(String value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(IDENTIFIANT_KEY, value);
  }

  saveSettingsMotdepasse(String value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(MOTDEPASSE_KEY, value);
  }

  Future<bool> getSettingsDark() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(THEME_KEY) ?? false;
  }

  Future<String> getSettingsIdentifiant() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(IDENTIFIANT_KEY) ?? "";
  }

  Future<String> getSettingsMotdepasse() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(MOTDEPASSE_KEY) ?? "";
  }

  clearSettings() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear();
  }
}
