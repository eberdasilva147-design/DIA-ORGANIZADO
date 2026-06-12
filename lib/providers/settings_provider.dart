import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/data_service.dart';

class SettingsProvider extends ChangeNotifier {
  bool _darkMode = true;
  bool _notifications = true;
  bool _sound = true;
  bool _recurringReminders = false;

  bool get darkMode => _darkMode;
  bool get notifications => _notifications;
  bool get sound => _sound;
  bool get recurringReminders => _recurringReminders;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool('darkMode') ?? true;
    _notifications = prefs.getBool('notifications') ?? true;
    _sound = prefs.getBool('sound') ?? true;
    _recurringReminders = prefs.getBool('recurringReminders') ?? false;
    notifyListeners();
  }

  Future<void> setDarkMode(bool val) async {
    _darkMode = val;
    notifyListeners();
    await _persist();
  }

  Future<void> setNotifications(bool val) async {
    _notifications = val;
    notifyListeners();
    await _persist();
  }

  Future<void> setSound(bool val) async {
    _sound = val;
    notifyListeners();
    await _persist();
  }

  Future<void> setRecurringReminders(bool val) async {
    _recurringReminders = val;
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _darkMode);
    await prefs.setBool('notifications', _notifications);
    await prefs.setBool('sound', _sound);
    await prefs.setBool('recurringReminders', _recurringReminders);

    await DataService.instance.saveSettings({
      'tema': _darkMode ? 'escuro' : 'claro',
      'somNotificacao': _sound,
      'lembretesRecorrentes': _recurringReminders,
    });
  }
}
