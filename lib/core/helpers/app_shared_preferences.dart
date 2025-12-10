import 'package:shared_preferences/shared_preferences.dart';

class AppSharedPreferences {
  static final AppSharedPreferences _instance =
      AppSharedPreferences._internal();

  late SharedPreferences _prefs;

  AppSharedPreferences._internal();

  factory AppSharedPreferences() => _instance;

  Future<void> init() async => _prefs = await SharedPreferences.getInstance();

  // Setters
  Future<void> setString(String key, String value) async =>
      await _prefs.setString(key, value);

  Future<void> setBool(String key, bool value) async =>
      await _prefs.setBool(key, value);

  Future<void> setInt(String key, int value) async =>
      await _prefs.setInt(key, value);

  Future<void> setDouble(String key, double value) async =>
      await _prefs.setDouble(key, value);

  // Getters
  String? getString(String key) => _prefs.getString(key);

  bool? getBool(String key) => _prefs.getBool(key);

  int? getInt(String key) => _prefs.getInt(key);

  double? getDouble(String key) => _prefs.getDouble(key);

  // Clear all data
  Future<bool> clear() async => await _prefs.clear();
  // Clear specific key
  Future<bool> removeKey(String key) async => await _prefs.remove(key);
}
