import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/theme/app_theme.dart';
import 'package:unipar_trilha_app/core/theme/app_typography.dart';

void main() {
  test('tema registra os tokens semânticos como extensão', () {
    final theme = AppTheme.dark;

    expect(theme.useMaterial3, isTrue);
    expect(theme.brightness, Brightness.dark);
    expect(theme.extension<AppColors>(), AppColors.dark);
    expect(theme.scaffoldBackgroundColor, AppColors.dark.backgroundApp);
    expect(theme.colorScheme.primary, AppColors.dark.actionPrimary);
    expect(theme.colorScheme.onPrimary, AppColors.dark.onAction);
  });

  test('AppColors implementa lerp e copyWith', () {
    final lerped = AppColors.dark.lerp(AppColors.dark, 0.5);
    expect(lerped.actionPrimary, AppColors.dark.actionPrimary);
    expect(
      AppColors.dark.copyWith(link: AppColors.dark.textPrimary).link,
      AppColors.dark.textPrimary,
    );
  });

  test('somente app_palette.dart declara cores hexadecimais em lib/', () {
    final hex = RegExp(r'Color\(0x[0-9A-Fa-f]{8}\)');
    final offenders = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where((file) => !file.path.endsWith('app_palette.dart'))
        .where((file) => hex.hasMatch(file.readAsStringSync()))
        .map((file) => file.path)
        .toList();

    expect(offenders, isEmpty);
  });

  test('fontes registradas existem e têm licença OFL', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final arquivos = RegExp(
      r'- asset: (assets/fonts/[^\s]+\.ttf)',
    ).allMatches(pubspec).map((match) => match.group(1)!).toList();

    expect(arquivos, hasLength(16));
    for (final arquivo in arquivos) {
      expect(File(arquivo).existsSync(), isTrue, reason: arquivo);
      expect(
        File('${File(arquivo).parent.path}/OFL.txt').existsSync(),
        isTrue,
        reason: arquivo,
      );
    }
    for (final familia in [
      AppFonts.inter,
      AppFonts.montserrat,
      AppFonts.openSans,
      AppFonts.firaCode,
      AppFonts.fredoka,
    ]) {
      expect(pubspec, contains('- family: $familia'));
    }
    expect(AppTheme.dark.textTheme.bodyLarge?.fontFamily, AppFonts.inter);
    expect(
      AppTheme.dark.textTheme.headlineSmall?.fontFamily,
      AppFonts.montserrat,
    );
  });

  test('ativos registrados existem no projeto', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final folders = RegExp(
      r'- (assets/[^\s]+/)',
    ).allMatches(pubspec).map((match) => match.group(1)!);

    expect(folders, isNotEmpty);
    for (final folder in folders) {
      final directory = Directory(folder);
      expect(directory.existsSync(), isTrue, reason: folder);
      expect(
        directory.listSync().whereType<File>().any(
          (f) => f.path.endsWith('.png'),
        ),
        isTrue,
        reason: folder,
      );
    }
  });
}
