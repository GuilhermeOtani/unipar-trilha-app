import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipar_trilha_app/core/theme/app_theme.dart';
import 'package:unipar_trilha_app/modules/home/dto/professor_contexto_response.dart';
import 'package:unipar_trilha_app/modules/trilha/dto/trilha_dto.dart';
import 'package:unipar_trilha_app/modules/trilha/page/trilha_editor_page.dart';
import 'package:unipar_trilha_app/modules/trilha/service/trilha_service.dart';

void main() {
  testWidgets('editor cria rascunho, salva árvore e bloqueia POST duplicado', (
    tester,
  ) async {
    final service = _FakeTrilhaService();
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: TrilhaEditorPage(contexto: _contexto, service: service),
      ),
    );
    expect(tester.takeException(), isNull, reason: 'etapa básica');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Título'),
      'Trilha de testes',
    );
    final action = find.byKey(const Key('trilha-primary-action'));
    await tester.ensureVisible(action);
    await tester.tap(action);
    await tester.tap(action);
    await tester.pump();
    expect(service.criacoes, 1);

    service.criacao.complete(_rascunho);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'etapa de conteúdo');
    expect(find.text('2. Conteúdo'), findsNothing);
    expect(find.text('Módulo 1'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Título do módulo'),
      'Módulo inicial',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Título da lição'),
      'Primeira lição',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enunciado'),
      'Qual opção está correta?',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Explicação do feedback'),
      'A primeira opção está correta.',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Opção 1'),
      'Correta',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Opção 2'),
      'Incorreta',
    );
    await tester.ensureVisible(action);
    await tester.tap(action);
    await tester.pumpAndSettle();

    expect(service.atualizacoes, 1);
    expect(find.text('3. Revisão e publicação'), findsOneWidget);
    expect(find.text('Publicar versão'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

const _contexto = ProfessorContextoResponse(
  professorId: 2,
  professorNome: 'Professor',
  turmas: [
    TurmaProfessorResponse(
      turmaId: 1,
      turmaNome: 'Turma Piloto',
      periodo: '2026/2',
      disciplinaId: 3,
      disciplinaNome: 'Algoritmos',
      disciplinaCodigo: 'ALG',
    ),
  ],
);

const _rascunho = TrilhaResponse(
  id: 4,
  titulo: 'Trilha de testes',
  status: 'RASCUNHO',
  disciplinaId: 3,
  disciplinaNome: 'Algoritmos',
  modulos: [],
);

class _FakeTrilhaService implements TrilhaServiceContract {
  final criacao = Completer<TrilhaResponse>();
  int criacoes = 0;
  int atualizacoes = 0;

  @override
  Future<TrilhaResponse> criar(TrilhaCreateRequest request) {
    criacoes++;
    return criacao.future;
  }

  @override
  Future<TrilhaResponse> atualizar(
    int id,
    TrilhaConteudoRequest request,
  ) async {
    atualizacoes++;
    return _rascunho;
  }

  @override
  Future<TrilhaResponse> buscar(int id) async => _rascunho;

  @override
  Future<List<TrilhaProfessorResumoResponse>> listar() async => const [];

  @override
  Future<PublicacaoResponse> publicar(int id) async =>
      const PublicacaoResponse(versaoId: 8, numeroVersao: 1);
}
