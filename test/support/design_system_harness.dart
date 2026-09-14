import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipar_trilha_app/core/theme/app_theme.dart';

const compactSize = Size(360, 800);
const desktopSize = Size(1366, 900);

/// Envolve [child] com o tema do app dentro de uma área rolável.
Widget themed(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark,
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    ),
  );
}

/// Define o tamanho lógico da tela durante o teste.
void useSurface(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}
