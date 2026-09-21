import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipar_trilha_app/core/api_client.dart';
import 'package:unipar_trilha_app/core/auth_session.dart';
import 'package:unipar_trilha_app/core/theme/app_theme.dart';
import 'package:unipar_trilha_app/core/widgets/app_bottom_navigation.dart';
import 'package:unipar_trilha_app/modules/home/dto/professor_contexto_response.dart';
import 'package:unipar_trilha_app/modules/home/page/professor_navegacao_page.dart';
import 'package:unipar_trilha_app/modules/home/service/professor_contexto_service.dart';
import 'package:unipar_trilha_app/modules/login/dto/perfil_usuario.dart';
import 'package:unipar_trilha_app/modules/login/dto/usuario_response.dart';
import 'support/fake_http_client_adapter.dart';
import 'support/memory_auth_storage.dart';
import 'support/trilha_editor_fixtures.dart';
import 'trilha_editor_test.dart' show tocar, preencher;

class _ContextoService implements ProfessorContextoServiceContract {
  @override
  Future<ProfessorContextoResponse> obter() async => contextoEditor;
}

void main() {
  testWidgets(
    'cadastro mantém barra e estado entre abas; voltar e sair recarregam lista',
    (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final dio = ApiClient.shared.dio;
      final original = dio.httpClientAdapter;
      dio.httpClientAdapter = FakeHttpClientAdapter(
        (request) => request.path == '/distribuicoes'
            ? jsonResponse('[]')
            : jsonResponse('''{
      "turmaId":1,"turmaNome":"Turma A","matriculados":0,"iniciaram":0,"concluiram":0,
      "percentualConclusao":0,"acertos":0,"erros":0,"acuracia":0,"desafiosComMaisErros":[]
    }'''),
      );
      addTearDown(() => dio.httpClientAdapter = original);
      final service = FakeTrilhaEditorService();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: ProfessorNavegacaoPage(
            usuario: const UsuarioResponse(
              id: 2,
              login: 'professor',
              nome: 'Prof. Jaime',
              perfil: PerfilUsuario.professor,
              ativo: true,
            ),
            authSession: AuthSession.forTesting(
              storage: MemoryAuthStorage(),
              dio: Dio(),
            ),
            contextoService: _ContextoService(),
            trilhaService: service,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tocar(tester, find.byTooltip('Trilhas'));
      await tocar(tester, find.byTooltip('Editar rascunho'));
      expect(find.byType(AppBottomNavigation), findsOneWidget);
      await preencher(tester, 'Título', 'Título preservado entre abas');
      await tocar(tester, find.byTooltip('Início'));
      await tocar(tester, find.byTooltip('Trilhas'));
      expect(find.text('Título preservado entre abas'), findsOneWidget);
      await tocar(tester, find.text('Continuar'));
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Informações da Trilha'), findsOneWidget);
      await tocar(tester, find.text('Salvar rascunho'));
      await tocar(tester, find.byTooltip('Voltar para Trilhas'));
      expect(find.text('Minhas trilhas'), findsOneWidget);
      expect(find.text('Título preservado entre abas'), findsOneWidget);
      expect(service.listagens, 2);
      await tocar(tester, find.byTooltip('Editar rascunho'));
      await preencher(tester, 'Título', 'Alteração descartada');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Sair sem salvar?'), findsOneWidget);
      await tocar(tester, find.text('Sair sem salvar'));
      expect(find.text('Minhas trilhas'), findsOneWidget);
      expect(find.text('Título preservado entre abas'), findsOneWidget);
      expect(service.listagens, 2);
      expect(tester.takeException(), isNull);
    },
  );
}
