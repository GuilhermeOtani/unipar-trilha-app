/// Larguras de referência para layout responsivo.
///
/// O layout é validado em 360 px (compacto) e 1366 px (desktop). O conteúdo é
/// centralizado e limitado a [maxContentWidth] em telas largas.
abstract final class AppBreakpoints {
  static const double compactMin = 360;
  static const double medium = 600;
  static const double expanded = 1024;
  static const double maxContentWidth = 720;

  static bool isCompact(double width) => width < medium;

  /// Margem lateral do conteúdo conforme a largura disponível.
  static double horizontalPadding(double width) {
    if (width < medium) return 16;
    if (width < expanded) return 24;
    return 32;
  }
}
