import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(),
);

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const _key = 'isDarkMode';

  ThemeNotifier() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    if (sp.containsKey(_key)) {
      final isDark = sp.getBool(_key) ?? false;
      state = isDark ? ThemeMode.dark : ThemeMode.light;
    } else {
      state = ThemeMode.system;
    }
  }

  Future<void> setDark(bool isDark) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_key, isDark);
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setSystem() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_key);
    state = ThemeMode.system;
  }

  Future<void> toggle() async {
    final isDark = state == ThemeMode.dark;
    await setDark(!isDark);
  }
}
