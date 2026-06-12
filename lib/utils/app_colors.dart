import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF060f1c);
  static const Color backgroundSecondary = Color(0xFF0a1628);
  static const Color card = Color(0xFF0d1f3a);
  static const Color border = Color(0xFF1a3050);
  static const Color primary = Color(0xFF1a5aa8);
  static const Color accent = Color(0xFF4a9fd4);
  static const Color textPrimary = Color(0xFFc8ddf0);
  static const Color textSecondary = Color(0xFF4a7fa5);
  static const Color priorityHigh = Color(0xFFe05c5c);
  static const Color priorityMedium = Color(0xFFe0a83a);
  static const Color priorityLow = Color(0xFF3aad6e);
  static const Color white = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF3aad6e);
  static const Color error = Color(0xFFe05c5c);
  static const Color warning = Color(0xFFe0a83a);

  static Color priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'h':
      case 'alta':
        return priorityHigh;
      case 'm':
      case 'media':
      case 'média':
        return priorityMedium;
      default:
        return priorityLow;
    }
  }

  static String priorityLabel(String priority) {
    switch (priority.toLowerCase()) {
      case 'h':
        return 'Alta';
      case 'm':
        return 'Média';
      default:
        return 'Baixa';
    }
  }
}
