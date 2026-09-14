/// Escala de espaçamento em múltiplos de 4 px.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Área mínima de toque recomendada (Material/WCAG).
  static const double minTouchTarget = 48;
}

/// Raios de borda usados pelos componentes.
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;
}
