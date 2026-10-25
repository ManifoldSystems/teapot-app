import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../main.dart';

class ThemeManager extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _animationEnabled = true;
  Locale _locale = const Locale('en');

  bool get isDarkMode => _isDarkMode;
  bool get animationEnabled => _animationEnabled;
  Locale get locale => _locale;

  ThemeManager() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(PrefKeys.isDarkMode) ?? false;
      _animationEnabled = prefs.getBool(PrefKeys.animationEnabled) ?? true;
      final languageCode = prefs.getString('language_code') ?? 'en';
      _locale = Locale(languageCode);

      talker?.debug(
        'Settings loaded: darkMode=$_isDarkMode, animations=$_animationEnabled, locale=$languageCode',
      );
      notifyListeners();
    } catch (e, stack) {
      talker?.error('Failed to load settings', e, stack);
      rethrow;
    }
  }

  Future<void> toggleTheme() async {
    try {
      _isDarkMode = !_isDarkMode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(PrefKeys.isDarkMode, _isDarkMode);

      talker?.info('🌗 Theme changed: ${_isDarkMode ? 'Dark' : 'Light'}');
      notifyListeners();
    } catch (e, stack) {
      talker?.error('Failed to toggle theme', e, stack);
      rethrow;
    }
  }

  Future<void> toggleAnimation() async {
    try {
      _animationEnabled = !_animationEnabled;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(PrefKeys.animationEnabled, _animationEnabled);

      talker?.info(
        '✨ Animations ${_animationEnabled ? 'enabled' : 'disabled'}',
      );
      notifyListeners();
    } catch (e, stack) {
      talker?.error('Failed to toggle animations', e, stack);
      rethrow;
    }
  }

  Future<void> setLocale(Locale locale) async {
    try {
      if (_locale == locale) return;
      _locale = locale;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', locale.languageCode);

      talker?.info('🌐 Locale changed: ${locale.languageCode}');
      notifyListeners();
    } catch (e, stack) {
      talker?.error('Failed to set locale', e, stack);
      rethrow;
    }
  }

  ThemeData get currentTheme {
    return _isDarkMode ? ThemeData.dark() : ThemeData.light();
  }
}
