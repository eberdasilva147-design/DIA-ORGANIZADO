import 'package:flutter/material.dart';

/// Paleta "Sacred Order" — creme santuário, dourado solar,
/// terracota e azul celeste (design Stitch).
class AppColors {
  // Superfícies
  static const Color background = Color(0xFFFCF9F8); // creme santuário
  static const Color backgroundSecondary = Color(0xFFF6F3F2);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE7E0D2); // contorno quente suave

  // Marca
  static const Color primary = Color(0xFF735C00); // dourado solar profundo
  static const Color accent = Color(0xFFB8860B); // dourado de destaque
  static const Color gold = Color(0xFFD4AF37); // dourado vivo (chips/ícones)
  static const Color terracotta = Color(0xFF9F402D); // secundária terrosa
  static const Color celestial = Color(0xFF0C6780); // terciária azul céu

  // Hero escuro (cartão do versículo)
  static const Color heroDark = Color(0xFF231C12);
  static const Color heroDarkSoft = Color(0xFF453518);

  // Texto
  static const Color textPrimary = Color(0xFF1B1C1C);
  static const Color textSecondary = Color(0xFF7F7663);

  // Prioridades (terracota / dourado / azul celeste)
  static const Color priorityHigh = Color(0xFF9F402D);
  static const Color priorityMedium = Color(0xFFB8860B);
  static const Color priorityLow = Color(0xFF0C6780);

  // Estados
  static const Color white = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF2E7D4F);
  static const Color error = Color(0xFFBA1A1A);
  static const Color warning = Color(0xFFB8860B);

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
