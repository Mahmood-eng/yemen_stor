import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isBiometricEnabled = false;
  bool _notificationsEnabled = true;

  SettingsProvider() {
    _loadSettings();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get notificationsEnabled => _notificationsEnabled;

  // تحميل الإعدادات من التخزين المحلي
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // تحميل الثيم
    final themeIndex = prefs.getInt('theme_mode') ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    
    // تحميل البصمة
    _isBiometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    
    // تحميل الإشعارات
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    
    notifyListeners();
  }

  // تغيير الثيم
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    notifyListeners();
  }

  // تفعيل/تعطيل البصمة
  Future<void> toggleBiometric(bool value) async {
    _isBiometricEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', value);
    notifyListeners();
  }

  // تفعيل/تعطيل الإشعارات
  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    notifyListeners();
  }
}
