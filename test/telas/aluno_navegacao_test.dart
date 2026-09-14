import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipar_trilha_app/core/theme/app_theme.dart';
import 'package:unipar_trilha_app/core/widgets/app_button.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/page/caminho_trilha_page.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/page/pratica_page.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/page/catalogo_aluno_page.dart';
import 'package:unipar_trilha_app/modules/home/page/aluno_home_page.dart';
import 'package:unipar_trilha_app/modules/perfil/page/perfil_page.dart';
import 'package:unipar_trilha_app/shared/preview/aluno_preview_conteudo.dart';

import '../support/design_system_harness.dart';

void main() {
  Future<void> abrir(WidgetTester tester) async {
    useSurface(tester, const Size(1366, 2400));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: AlunoPreviewConteudo.navegacao(atraso: Duration.zero),
      ),
    );
    // O catálogo chega pelo service (API simulada) após o primeiro quadro.
    await tester.pumpAndSettle();
  }

  Future<void> aba(WidgetTester tester, String nome) async {
    await tester.tap(find.byTooltip(nome));
    await tester.pumpAndSettle();
  }

  testWidgets('inicia na home e troca de aba pela navegação inferior', (
    tester,
  ) async {
    await abrir(tester);
    expect(find.byType(AlunoHomePage), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Início')),
      isSemantics(isSelected: true),
    );

    await aba(tester, 'Trilhas');
    expect(find.byType(CatalogoAlunoPage), findsOneWidget);

    await aba(tester, 'Perfil');
    expect(find.byType(PerfilPage), findsOneWidget);

    await aba(tester, 'Desempenho');
    expect(
      find.text('Em breve você poderá acompanhar seu desempenho aqui.'),
      findsOneWidget,
    );
  });

  testWidgets('card da home abre o caminho na aba Trilhas', (tester) async {
    await abrir(tester);

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.byType(CaminhoTrilhaPage), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Trilhas')),
      isSemantics(isSelected: true),
    );
  });

  testWidgets('caminho → prática → voltar → aba ativa volta ao catálogo', (
    tester,
  ) async {
    await abrir(tester);
    await aba(tester, 'Trilhas');

    await tester.tap(find.text('Começar').first);
    await tester.pumpAndSettle();
    expect(find.byType(CaminhoTrilhaPage), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(RegExp(r'^Lição 1: .*, atual$')));
    await tester.pumpAndSettle();
    expect(find.byType(PraticaPage), findsOneWidget);

    await tester.tap(find.text('Voltar à Trilha'));
    await tester.pumpAndSettle();
    expect(find.byType(CaminhoTrilhaPage), findsOneWidget);

    await aba(tester, 'Trilhas');
    expect(find.byType(CaminhoTrilhaPage), findsNothing);
    expect(find.byType(CatalogoAlunoPage), findsOneWidget);
  });

  testWidgets('lição bloqueada não abre a prática', (tester) async {
    await abrir(tester);
    await aba(tester, 'Trilhas');
    await tester.tap(find.text('Começar').first);
    await tester.pumpAndSettle();

    await tester.tap(
      find.bySemanticsLabel(RegExp(r'^Lição 2: .*, bloqueada$')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(PraticaPage), findsNothing);
  });

  testWidgets('"Começar" da próxima lição abre a prática', (tester) async {
    await abrir(tester);

    // O último "Começar" da home é o botão do card da próxima lição.
    await tester.tap(find.widgetWithText(AppButton, 'Começar').last);
    await tester.pumpAndSettle();

    expect(find.byType(PraticaPage), findsOneWidget);
  });
}
