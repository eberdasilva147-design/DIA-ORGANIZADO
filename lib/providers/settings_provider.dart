import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/data_service.dart';

class SettingsProvider extends ChangeNotifier {
  bool _darkMode = false;
  bool _notifications = true;
  bool _sound = true;
  bool _vibration = true;
  bool _silentMode = false;
  bool _doNotDisturb = false;
  bool _quietHoursEnabled = false;
  TimeOfDay _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietHoursEnd = const TimeOfDay(hour: 7, minute: 0);
  bool _recurringReminders = false;
  Locale _locale = const Locale('pt');

  bool get darkMode => _darkMode;
  bool get notifications => _notifications;
  bool get sound => _sound;
  bool get vibration => _vibration;
  bool get silentMode => _silentMode;
  bool get doNotDisturb => _doNotDisturb;
  bool get quietHoursEnabled => _quietHoursEnabled;
  TimeOfDay get quietHoursStart => _quietHoursStart;
  TimeOfDay get quietHoursEnd => _quietHoursEnd;
  bool get recurringReminders => _recurringReminders;
  Locale get locale => _locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool('darkMode') ?? false;
    _notifications = prefs.getBool('notifications') ?? true;
    _sound = prefs.getBool('sound') ?? true;
    _vibration = prefs.getBool('vibration') ?? true;
    _silentMode = prefs.getBool('silentMode') ?? false;
    _doNotDisturb = prefs.getBool('doNotDisturb') ?? false;
    _quietHoursEnabled = prefs.getBool('quietHoursEnabled') ?? false;
    _quietHoursStart = _parseTime(prefs.getString('quietHoursStart'), const TimeOfDay(hour: 22, minute: 0));
    _quietHoursEnd = _parseTime(prefs.getString('quietHoursEnd'), const TimeOfDay(hour: 7, minute: 0));
    _recurringReminders = prefs.getBool('recurringReminders') ?? false;
    _locale = Locale(prefs.getString('locale') ?? 'pt');
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

  Future<void> setVibration(bool val) async {
    _vibration = val;
    notifyListeners();
    await _persist();
  }

  Future<void> setSilentMode(bool val) async {
    _silentMode = val;
    notifyListeners();
    await _persist();
  }

  Future<void> setDoNotDisturb(bool val) async {
    _doNotDisturb = val;
    notifyListeners();
    await _persist();
  }

  Future<void> setQuietHoursEnabled(bool val) async {
    _quietHoursEnabled = val;
    notifyListeners();
    await _persist();
  }

  Future<void> setQuietHoursStart(TimeOfDay val) async {
    _quietHoursStart = val;
    notifyListeners();
    await _persist();
  }

  Future<void> setQuietHoursEnd(TimeOfDay val) async {
    _quietHoursEnd = val;
    notifyListeners();
    await _persist();
  }

  Future<void> setRecurringReminders(bool val) async {
    _recurringReminders = val;
    notifyListeners();
    await _persist();
  }

  Future<void> setLocale(Locale val) async {
    _locale = val;
    notifyListeners();
    await _persist();
  }

  TimeOfDay _parseTime(String? raw, TimeOfDay fallback) {
    if (raw == null) return fallback;
    final parts = raw.split(':');
    if (parts.length != 2) return fallback;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return fallback;
    return TimeOfDay(hour: h, minute: m);
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _darkMode);
    await prefs.setBool('notifications', _notifications);
    await prefs.setBool('sound', _sound);
    await prefs.setBool('vibration', _vibration);
    await prefs.setBool('silentMode', _silentMode);
    await prefs.setBool('doNotDisturb', _doNotDisturb);
    await prefs.setBool('quietHoursEnabled', _quietHoursEnabled);
    await prefs.setString('quietHoursStart', _formatTime(_quietHoursStart));
    await prefs.setString('quietHoursEnd', _formatTime(_quietHoursEnd));
    await prefs.setBool('recurringReminders', _recurringReminders);
    await prefs.setString('locale', _locale.languageCode);

    await DataService.instance.saveSettings({
      'tema': _darkMode ? 'escuro' : 'claro',
      'somNotificacao': _sound,
      'lembretesRecorrentes': _recurringReminders,
    });
  }
}
