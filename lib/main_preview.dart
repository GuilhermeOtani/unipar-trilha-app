import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_theme.dart';
import 'package:unipar_trilha_app/shared/preview/aluno_preview_conteudo.dart';

/// Pré-visualização das telas do aluno (wireframes 1–7) com conteúdo de
/// exemplo, para inspeção visual em compacto e desktop.
///
/// `flutter run -d chrome -t lib/main_preview.dart`
///
/// Não faz parte do app entregue: `main.dart` não referencia este arquivo.
void main() {
  runApp(
    MaterialApp(
      title: 'Unipar Trilha — Pré-visualização',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: AlunoPreviewConteudo.navegacao(),
    ),
  );
}
