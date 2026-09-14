import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.actionPrimary,
      onPrimary: AppColors.textOnAction,
      secondary: AppColors.actionSecondary,
      onSecondary: AppColors.textPrimary,
      surface: AppColors.surfaceDefault,
      onSurface: AppColors.textPrimary,
      error: AppColors.statusError,
      onError: AppColors.textOnAction,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.backgroundApp,
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 38,
          height: 1.05,
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 28,
          height: 1.15,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          height: 1.45,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundApp.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIconColor: AppColors.iconDefault,
        suffixIconColor: AppColors.iconDefault,
        errorStyle: const TextStyle(color: AppColors.statusError),
        border: _border(AppColors.textSecondary.withValues(alpha: 0.38)),
        enabledBorder: _border(AppColors.textSecondary.withValues(alpha: 0.38)),
        focusedBorder: _border(AppColors.actionPrimary, width: 2),
        errorBorder: _border(AppColors.statusError),
        focusedErrorBorder: _border(AppColors.statusError, width: 2),
        disabledBorder: _border(
          AppColors.textSecondary.withValues(alpha: 0.18),
        ),
      ),
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
