import 'package:flutter/material.dart';

/// Sistema de cores dinâmico do Sacred Order.
/// Cores sensíveis ao tema (fundo, card, texto) ficam aqui.
/// Cores fixas (prioridade, marca, erro) permanecem em AppColors.
@immutable
class DiaColors extends ThemeExtension<DiaColors> {
  final Color background;
  final Color backgroundSecondary;
  final Color card;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;

  const DiaColors({
    required this.background,
    required this.backgroundSecondary,
    required this.card,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
  });

  /// Tema claro — Sacred Order original (creme santuário)
  static const light = DiaColors(
    background: Color(0xFFFCF9F8),
    backgroundSecondary: Color(0xFFF6F3F2),
    card: Color(0xFFFFFFFF),
    border: Color(0xFFE7E0D2),
    textPrimary: Color(0xFF1B1C1C),
    textSecondary: Color(0xFF7F7663),
  );

  /// Tema escuro — Sacred Order Dark (quente e sofisticado)
  static const dark = DiaColors(
    background: Color(0xFF1A1614),
    backgroundSecondary: Color(0xFF221A17),
    card: Color(0xFF2A1F1B),
    border: Color(0xFF3D2E27),
    textPrimary: Color(0xFFEDE8E4),
    textSecondary: Color(0xFF9C8A7B),
  );

  @override
  DiaColors copyWith({
    Color? background,
    Color? backgroundSecondary,
    Color? card,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
  }) =>
      DiaColors(
        background: background ?? this.background,
        backgroundSecondary: backgroundSecondary ?? this.backgroundSecondary,
        card: card ?? this.card,
        border: border ?? this.border,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
      );

  @override
  DiaColors lerp(ThemeExtension<DiaColors>? other, double t) {
    if (other is! DiaColors) return this;
    return DiaColors(
      background: Color.lerp(background, other.background, t)!,
      backgroundSecondary:
          Color.lerp(backgroundSecondary, other.backgroundSecondary, t)!,
      card: Color.lerp(card, other.card, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    );
  }
}

/// Atalho para acessar as cores do tema atual.
/// Uso: `context.colors.background`
extension DiaColorsX on BuildContext {
  DiaColors get colors =>
      Theme.of(this).extension<DiaColors>() ?? DiaColors.light;
}
