import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Adding dark mode
class ThemeProvider extends ChangeNotifier {
  static const _key = 'is_dark_mode';
  bool _isDark = false;

  bool get isDark => _isDark;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDark = prefs.getBool(_key) ?? false;
      notifyListeners();
    } catch (_) {
      // SharedPreferences unavailable on this platform/run — use default (light)
    }
  }

  //toggle bar as switch
  Future<void> toggle() async {
    _isDark = !_isDark;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, _isDark);
    } catch (_) {
      // Persistence unavailable — toggle still works in memory
    }
  }
}
