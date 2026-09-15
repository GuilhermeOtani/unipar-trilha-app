import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipar_trilha_app/core/auth_session.dart';
import 'package:unipar_trilha_app/core/theme/app_theme.dart';
import 'package:unipar_trilha_app/modules/login/dto/perfil_usuario.dart';
import 'package:unipar_trilha_app/modules/login/dto/usuario_response.dart';
import 'package:unipar_trilha_app/modules/usuarios/dto/usuario_create_request.dart';
import 'package:unipar_trilha_app/modules/usuarios/page/administrador_home_page.dart';
import 'package:unipar_trilha_app/modules/usuarios/service/usuario_service.dart';

import 'support/memory_auth_storage.dart';

void main() {
  for (final largura in [360.0, 1100.0]) {
    testWidgets('gestão administrativa funciona sem overflow em $largura px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(largura, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final service = _FakeUsuarioService();
      final session = AuthSession.forTesting(
        storage: MemoryAuthStorage(),
        dio: Dio(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: AdministradorHomePage(
            usuario: _admin,
            authSession: session,
            service: service,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Aluno Existente'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Login'),
        'professor.novo',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome'),
        'Professor Novo',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'segredo123',
      );
      final action = find.byKey(const Key('criar-usuario'));
      await tester.ensureVisible(action);
      await tester.tap(action);
      await tester.pumpAndSettle();

      expect(service.criacoes, 1);
      final password = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Senha'),
      );
      expect(password.controller?.text, isEmpty);
      expect(tester.takeException(), isNull);
    });
  }
}

const _admin = UsuarioResponse(
  id: 1,
  login: 'admin',
  nome: 'Administrador',
  perfil: PerfilUsuario.administrador,
  ativo: true,
);

class _FakeUsuarioService implements UsuarioServiceContract {
  int criacoes = 0;

  @override
  Future<UsuarioResponse> criar(UsuarioCreateRequest request) async {
    criacoes++;
    return UsuarioResponse(
      id: 9,
      login: request.login,
      nome: request.nome,
      perfil: request.perfil,
      ativo: true,
    );
  }

  @override
  Future<List<UsuarioResponse>> listar(PerfilUsuario perfil) async {
    if (perfil != PerfilUsuario.aluno) return const [];
    return const [
      UsuarioResponse(
        id: 4,
        login: 'aluno.existente',
        nome: 'Aluno Existente',
        perfil: PerfilUsuario.aluno,
        ativo: true,
      ),
    ];
  }
}
