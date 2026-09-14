import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipar_trilha_app/core/auth_session.dart';
import 'package:unipar_trilha_app/main.dart';
import 'package:unipar_trilha_app/modules/home/page/session_placeholder_page.dart';
import 'package:unipar_trilha_app/modules/login/dto/login_response.dart';
import 'package:unipar_trilha_app/modules/login/dto/perfil_usuario.dart';
import 'package:unipar_trilha_app/modules/login/dto/usuario_response.dart';
import 'package:unipar_trilha_app/modules/login/page/login_page.dart';

import 'support/fake_http_client_adapter.dart';
import 'support/fake_login_service.dart';
import 'support/memory_auth_storage.dart';

void main() {
  Finder field(String key) => find.descendant(
    of: find.byKey(Key(key)),
    matching: find.byType(TextFormField),
  );

  for (final perfil in PerfilUsuario.values) {
    testWidgets('login de ${perfil.apiValue} abre a página provisória', (
      tester,
    ) async {
      final storage = MemoryAuthStorage();
      final session = AuthSession.forTesting(storage: storage, dio: Dio());
      final response = LoginResponse(
        accessToken: 'jwt-${perfil.apiValue}',
        tokenType: 'Bearer',
        expiresInMinutes: 480,
        usuarioId: perfil.index + 1,
        login: perfil.apiValue.toLowerCase(),
        nome: 'Usuário ${perfil.label}',
        perfil: perfil,
      );
      final service = FakeLoginService(
        handler: (_) async {
          await session.salvarLogin(response);
          return response;
        },
      );

      await tester.pumpWidget(
        UniparTrilhaApp(authSession: session, loginService: service),
      );
      await tester.pumpAndSettle();
      await tester.enterText(field('login-field'), response.login);
      await tester.enterText(field('password-field'), 'senha');
      await tester.tap(find.byKey(const Key('login-submit')));
      await tester.pumpAndSettle();

      expect(find.byType(SessionPlaceholderPage), findsOneWidget);
      expect(find.text(response.nome), findsOneWidget);
      expect(find.text(perfil.label), findsOneWidget);
    });
  }

  testWidgets('restaura uma sessão válida consultando usuarios me', (
    tester,
  ) async {
    final storage = MemoryAuthStorage()
      ..value = const StoredAuthSession(
        token: 'jwt',
        usuario: UsuarioResponse(
          id: 2,
          login: 'professor',
          nome: 'Professor Salvo',
          perfil: PerfilUsuario.professor,
          ativo: true,
        ),
      );
    final dio = Dio(BaseOptions(baseUrl: 'http://teste'));
    dio.httpClientAdapter = FakeHttpClientAdapter(
      (_) => jsonResponse('''{
        "id":2,"login":"professor","nome":"Professor Atualizado",
        "perfil":"PROFESSOR","ativo":true
      }'''),
    );
    final session = AuthSession.forTesting(storage: storage, dio: dio);

    await tester.pumpWidget(
      UniparTrilhaApp(authSession: session, loginService: FakeLoginService()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SessionPlaceholderPage), findsOneWidget);
    expect(find.text('Professor Atualizado'), findsOneWidget);
  });

  testWidgets('falha de rede na restauração mostra aviso e nova tentativa', (
    tester,
  ) async {
    final storage = MemoryAuthStorage()
      ..value = const StoredAuthSession(
        token: 'jwt',
        usuario: UsuarioResponse(
          id: 2,
          login: 'professor',
          nome: 'Professor Demo',
          perfil: PerfilUsuario.professor,
          ativo: true,
        ),
      );
    final dio = Dio(BaseOptions(baseUrl: 'http://teste'));
    dio.httpClientAdapter = FakeHttpClientAdapter((options) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    });
    final session = AuthSession.forTesting(storage: storage, dio: dio);

    await tester.pumpWidget(
      UniparTrilhaApp(authSession: session, loginService: FakeLoginService()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byKey(const Key('session-message')), findsOneWidget);
    expect(find.text('Não foi possível conectar ao servidor.'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
    expect(storage.value, isNotNull);
  });

  testWidgets('logout limpa a sessão e volta ao login sem navegação', (
    tester,
  ) async {
    final storage = MemoryAuthStorage();
    final dio = Dio(BaseOptions(baseUrl: 'http://teste'));
    dio.httpClientAdapter = FakeHttpClientAdapter(
      (_) => jsonResponse('''{
        "id":2,"login":"professor","nome":"Professor Demo",
        "perfil":"PROFESSOR","ativo":true
      }'''),
    );
    final session = AuthSession.forTesting(storage: storage, dio: dio);
    await session.salvarLogin(professorLogin);

    await tester.pumpWidget(
      UniparTrilhaApp(authSession: session, loginService: FakeLoginService()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('session-logout')));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(SessionPlaceholderPage), findsNothing);
    expect(storage.value, isNull);
  });
}
