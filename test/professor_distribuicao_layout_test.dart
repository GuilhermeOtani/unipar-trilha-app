import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipar_trilha_app/core/theme/app_theme.dart';
import 'package:unipar_trilha_app/modules/distribuicao/dto/distribuicao_dto.dart';
import 'package:unipar_trilha_app/modules/distribuicao/page/distribuicoes_professor_page.dart';
import 'package:unipar_trilha_app/modules/distribuicao/service/distribuicao_service.dart';
import 'package:unipar_trilha_app/modules/home/dto/professor_contexto_response.dart';
import 'package:unipar_trilha_app/modules/login/dto/perfil_usuario.dart';
import 'package:unipar_trilha_app/modules/login/dto/usuario_response.dart';
import 'package:unipar_trilha_app/modules/trilha/dto/trilha_dto.dart';

void main() {
  for (final largura in [360.0, 1100.0]) {
    testWidgets('distribuição do professor não transborda em $largura px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(largura, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: DistribuicoesProfessorPage(
            usuario: _professor,
            contexto: _contexto,
            trilhas: _trilhas,
            service: _FakeDistribuicaoService(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nova distribuição'), findsOneWidget);
      expect(
        find.text('Trilha com um título bastante longo — V1'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }
}

const _professor = UsuarioResponse(
  id: 2,
  login: 'professor',
  nome: 'Professor Demo',
  perfil: PerfilUsuario.professor,
  ativo: true,
);

const _contexto = ProfessorContextoResponse(
  professorId: 2,
  professorNome: 'Professor Demo',
  turmas: [
    TurmaProfessorResponse(
      turmaId: 1,
      turmaNome: 'Turma com um nome bastante longo',
      periodo: '2026/2',
      disciplinaId: 1,
      disciplinaNome: 'Algoritmos e Lógica de Programação',
      disciplinaCodigo: 'ALG-001',
    ),
  ],
);

final _trilhas = [
  TrilhaProfessorResumoResponse(
    id: 1,
    titulo: 'Trilha com um título bastante longo',
    status: 'RASCUNHO',
    disciplinaId: 1,
    disciplinaNome: 'Algoritmos e Lógica de Programação',
    atualizadoEm: DateTime(2026, 9, 14),
    publicacoes: [
      PublicacaoResumoResponse(
        versaoId: 7,
        numeroVersao: 1,
        publicadaEm: DateTime(2026, 9, 14),
      ),
    ],
  ),
];

class _FakeDistribuicaoService implements DistribuicaoServiceContract {
  @override
  Future<List<DistribuicaoResponse>> listar(int turmaId) async => const [];

  @override
  Future<DistribuicaoResponse> criar(DistribuicaoRequest request) {
    throw UnimplementedError();
  }
}
