import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipar_trilha_app/core/theme/app_breakpoints.dart';
import 'package:unipar_trilha_app/core/theme/app_theme.dart';
import 'package:unipar_trilha_app/core/widgets/app_mascot.dart';
import 'package:unipar_trilha_app/core/widgets/app_progress.dart';
import 'package:unipar_trilha_app/core/widgets/trail_card.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/page/caminho_trilha_page.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/page/pratica_page.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/page/catalogo_aluno_page.dart';
import 'package:unipar_trilha_app/modules/home/page/aluno_home_page.dart';
import 'package:unipar_trilha_app/modules/perfil/page/perfil_page.dart';
import 'package:unipar_trilha_app/shared/preview/aluno_preview_conteudo.dart';

import '../support/design_system_harness.dart';

typedef _Tela = ({String nome, Widget Function() build, List<String> textos});

void main() {
  final telas = <_Tela>[
    (
      nome: 'tela 1 — home',
      build: () => AlunoHomePage(
        aluno: AlunoPreviewConteudo.aluno,
        trilhas: AlunoPreviewConteudo.trilhas,
        metaDiaria: AlunoPreviewConteudo.conteudo().metaDiaria,
        proximaLicao: AlunoPreviewConteudo.conteudo().proximaLicao,
        onAbrirTrilha: (_) {},
        onVerTodas: () {},
        onComecarProximaLicao: (_) {},
      ),
      textos: [
        'Meta Diária',
        'Suas trilhas de aprendizado',
        'Ver todas',
        'Frontend - Básico',
        'Antes da ação,\na preparação.',
      ],
    ),
    (
      nome: 'tela 2 — caminho',
      build: () => CaminhoTrilhaPage(
        aluno: AlunoPreviewConteudo.aluno,
        caminho: AlunoPreviewConteudo.caminho(AlunoPreviewConteudo.trilhas[1]),
        onSelecionarLicao: (_) {},
      ),
      textos: ['Orientação a Objetos', 'Comece aqui'],
    ),
    (
      nome: 'tela 3 — catálogo',
      build: () => CatalogoAlunoPage(
        aluno: AlunoPreviewConteudo.aluno,
        trilhas: AlunoPreviewConteudo.trilhas,
        onAbrirTrilha: (_) {},
      ),
      textos: ['Trilhas de Aprendizado', 'XAMPP e Tomcat'],
    ),
    (
      nome: 'telas 4–6 — prática',
      build: () => PraticaPage(
        desafio: AlunoPreviewConteudo.desafio,
        onResponder: AlunoPreviewConteudo.responder,
        onVoltar: () {},
        onContinuar: (_) {},
      ),
      textos: [
        'Voltar à Trilha',
        'Selecione uma alternativa',
        'Enviar resposta',
      ],
    ),
    (
      nome: 'tela 7 — perfil',
      build: () =>
          const PerfilPage(visaoGeral: AlunoPreviewConteudo.visaoGeral),
      textos: ['VISÃO GERAL', 'Cursos/Trilhas', 'RA: 60020223', '16860'],
    ),
  ];

  for (final tela in telas) {
    for (final size in [compactSize, const Size(768, 1024), desktopSize]) {
      testWidgets('${tela.nome} sem overflow em ${size.width.toInt()} px', (
        tester,
      ) async {
        useSurface(tester, size);
        await tester.pumpWidget(
          MaterialApp(theme: AppTheme.dark, home: tela.build()),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        for (final texto in tela.textos) {
          expect(find.text(texto), findsWidgets, reason: texto);
        }
        for (final element in find.byType(AppMascot).evaluate()) {
          final mascot = element.widget as AppMascot;
          final box = element.size!;
          expect(
            box.width / box.height,
            closeTo(mascot.pose.aspectRatio, 0.01),
          );
        }
      });
    }
  }

  testWidgets('home limita os cards e o catálogo mostra todos', (tester) async {
    useSurface(tester, const Size(1366, 2400));
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark, home: telas[0].build()),
    );
    expect(find.byType(TrailCard), findsNWidgets(2));

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark, home: telas[2].build()),
    );
    expect(
      find.byType(TrailCard),
      findsNWidgets(AlunoPreviewConteudo.trilhas.length),
    );
    expect(
      find.byType(AppProgressRing),
      findsNWidgets(AlunoPreviewConteudo.trilhas.length),
    );
  });

  testWidgets('conteúdo respeita a largura máxima no desktop', (tester) async {
    useSurface(tester, desktopSize);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark, home: telas[2].build()),
    );

    final card = tester.getSize(find.byType(TrailCard).first);
    expect(card.width, lessThanOrEqualTo(AppBreakpoints.maxContentWidth));
  });
}
