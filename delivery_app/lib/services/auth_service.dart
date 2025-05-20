import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  AuthService() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool('isDark') ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    } catch (e) {
      print('Erro ao carregar tema nas SharedPreferences: $e');
    }
  }

  void toggleTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = _themeMode == ThemeMode.dark;
      _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
      await prefs.setBool('isDark', !isDark);
      notifyListeners();
    } catch (e) {
      print('Erro ao salvar tema nas SharedPreferences: $e');
    }
  }

  void logout() {
    notifyListeners();
  }
}
