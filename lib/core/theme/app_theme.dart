import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/theme/app_spacing.dart';
import 'package:unipar_trilha_app/core/theme/app_typography.dart';

/// `ThemeData` Material 3 montado exclusivamente a partir dos tokens.
abstract final class AppTheme {
  static ThemeData get dark {
    const colors = AppColors.dark;
    final textTheme = AppTypography.textTheme(
      colors.textPrimary,
      colors.textSecondary,
    );
    final scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: colors.actionPrimary,
      onPrimary: colors.onAction,
      secondary: colors.actionSecondary,
      onSecondary: colors.onAction,
      tertiary: colors.actionInfo,
      onTertiary: colors.onAction,
      error: colors.feedbackDangerText,
      onError: colors.onAction,
      surface: colors.surfaceDefault,
      onSurface: colors.textPrimary,
      onSurfaceVariant: colors.textSecondary,
      outline: colors.borderDefault,
      outlineVariant: colors.borderSubtle,
    );

    OutlineInputBorder outline(Color color, [double width = 1.5]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      fontFamily: AppTypography.fontFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor: colors.backgroundApp,
      extensions: const <ThemeExtension<dynamic>>[AppColors.dark],
      iconTheme: IconThemeData(color: colors.iconDefault, size: 24),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceDefault,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        labelStyle: textTheme.bodyLarge?.copyWith(color: colors.textSecondary),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(
          color: colors.borderFocus,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(color: colors.textSecondary),
        helperStyle: textTheme.bodySmall,
        errorStyle: textTheme.bodySmall?.copyWith(
          color: colors.feedbackDangerText,
        ),
        suffixIconColor: colors.iconDefault,
        border: outline(colors.borderDefault),
        enabledBorder: outline(colors.borderDefault),
        focusedBorder: outline(colors.borderFocus, 2),
        errorBorder: outline(colors.feedbackDangerBorder),
        focusedErrorBorder: outline(colors.feedbackDangerText, 2),
        disabledBorder: outline(colors.borderSubtle),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.link,
          textStyle: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          minimumSize: const Size(
            AppSpacing.minTouchTarget,
            AppSpacing.minTouchTarget,
          ),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.progressFill,
        linearTrackColor: colors.progressTrack,
        circularTrackColor: colors.progressTrack,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.surfaceBrand,
        contentTextStyle: textTheme.bodyMedium,
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: DividerThemeData(color: colors.borderSubtle, space: 1),
    );
  }
}
