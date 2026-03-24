import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  String? _localPhotoUrl;

  ThemeMode get themeMode => _themeMode;
  String? get localPhotoUrl => _localPhotoUrl;

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _localPhotoUrl = prefs.getString('localPhotoUrl');
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setLocalPhotoUrl(String? url) async {
    _localPhotoUrl = url;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    if (url != null) {
      await prefs.setString('localPhotoUrl', url);
    } else {
      await prefs.remove('localPhotoUrl');
    }
  }
}
