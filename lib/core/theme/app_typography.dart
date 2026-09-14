import 'package:flutter/material.dart';

/// Famílias registradas em `pubspec.yaml` (arquivos em `assets/fonts/`).
///
/// Os wireframes usam fontes do Canva. As proprietárias foram trocadas por
/// equivalentes OFL que podem ser embutidas no APK e na Web:
///
/// | Fonte do wireframe | Família no app | Papel |
/// |---|---|---|
/// | SF Pro Display | [inter] | texto geral: nome, RA, meta, quiz |
/// | Code Pro | [montserrat] | títulos de seção e card, botões dos cards, percentuais |
/// | Canva Sans | [montserrat] | card da próxima lição |
/// | Open Sans | [openSans] | explicações e dados de leitura |
/// | Fira Code | [firaCode] | código e fala da mascote |
/// | Fredoka | [fredoka] | elementos arredondados |
abstract final class AppFonts {
  static const inter = 'Inter';
  static const montserrat = 'Montserrat';
  static const openSans = 'OpenSans';
  static const firaCode = 'FiraCode';
  static const fredoka = 'Fredoka';
}

/// Escala tipográfica do app.
abstract final class AppTypography {
  /// Família padrão do tema.
  static const String fontFamily = AppFonts.inter;

  /// Títulos e rótulos com o peso geométrico do Code Pro.
  static const String displayFamily = AppFonts.montserrat;

  /// Textos corridos de explicação.
  static const String readingFamily = AppFonts.openSans;

  static const String codeFontFamily = AppFonts.firaCode;
  static const String roundedFamily = AppFonts.fredoka;

  static TextTheme textTheme(Color primary, Color secondary) {
    return TextTheme(
      // Nome no card do perfil.
      headlineMedium: _style(28, FontWeight.w500, primary, height: 1.15),
      // Títulos de destaque (Code Pro no wireframe).
      headlineSmall: _style(
        22,
        FontWeight.w800,
        primary,
        height: 1.2,
        family: displayFamily,
      ),
      // Enunciado de questão, nome no cabeçalho.
      titleLarge: _style(22, FontWeight.w500, primary, height: 1.25),
      // Título de card e alternativas.
      titleMedium: _style(18, FontWeight.w700, primary, height: 1.25),
      titleSmall: _style(16, FontWeight.w700, primary, height: 1.3),
      bodyLarge: _style(16, FontWeight.w400, primary, height: 1.45),
      bodyMedium: _style(14, FontWeight.w400, primary, height: 1.45),
      bodySmall: _style(13, FontWeight.w400, secondary, height: 1.4),
      // Botões.
      labelLarge: _style(16, FontWeight.w700, primary, height: 1.2),
      labelMedium: _style(14, FontWeight.w600, primary, height: 1.2),
      labelSmall: _style(12, FontWeight.w600, secondary, height: 1.2),
    );
  }

  /// Estilo para trechos de código e fala da mascote.
  static TextStyle code(Color color) {
    return TextStyle(
      fontFamily: codeFontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: color,
    );
  }

  static TextStyle _style(
    double size,
    FontWeight weight,
    Color color, {
    required double height,
    String family = fontFamily,
  }) {
    return TextStyle(
      fontFamily: family,
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
    );
  }
}
