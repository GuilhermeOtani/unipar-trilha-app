import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipar_trilha_app/core/api_error.dart';
import 'package:unipar_trilha_app/core/theme/app_theme.dart';
import 'package:unipar_trilha_app/modules/login/page/login_page.dart';

import 'support/fake_login_service.dart';

void main() {
  Widget app(FakeLoginService service) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: LoginPage(service: service),
    );
  }

  Finder field(String key) => find.descendant(
    of: find.byKey(Key(key)),
    matching: find.byType(TextFormField),
  );

  Future<void> fillForm(WidgetTester tester) async {
    await tester.enterText(field('login-field'), 'professor');
    await tester.enterText(field('password-field'), 'prof123');
  }

  testWidgets('campos obrigatórios impedem chamada', (tester) async {
    final service = FakeLoginService();
    await tester.pumpWidget(app(service));

    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();

    expect(find.text('Informe seu login.'), findsOneWidget);
    expect(find.text('Informe sua senha.'), findsOneWidget);
    expect(service.requests, isEmpty);
  });

  testWidgets('mostra e oculta a senha sem perder conteúdo', (tester) async {
    final service = FakeLoginService();
    await tester.pumpWidget(app(service));
    await tester.enterText(field('password-field'), 'segredo');

    final passwordInput = find.descendant(
      of: find.byKey(const Key('password-field')),
      matching: find.byType(EditableText),
    );
    EditableText password = tester.widget(passwordInput);
    expect(password.obscureText, isTrue);
    await tester.tap(find.byKey(const Key('password-visibility')));
    await tester.pump();

    password = tester.widget(passwordInput);
    expect(password.obscureText, isFalse);
    expect(find.text('segredo'), findsOneWidget);
  });

  testWidgets('envia por Enter com login normalizado', (tester) async {
    final service = FakeLoginService();
    await tester.pumpWidget(app(service));
    await tester.enterText(field('login-field'), '  professor  ');
    await tester.enterText(field('password-field'), 'prof123');

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(service.requests, hasLength(1));
    expect(service.requests.single.login, 'professor');
    expect(service.requests.single.senha, 'prof123');
  });

  testWidgets('bloqueia envio duplicado durante carregamento', (tester) async {
    final response = Completer<void>();
    final service = FakeLoginService(
      handler: (_) => response.future.then((_) => professorLogin),
    );
    await tester.pumpWidget(app(service));
    await fillForm(tester);

    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();

    expect(service.requests, hasLength(1));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    response.complete();
    await tester.pumpAndSettle();
  });

  for (final error in [
    const ApiError(statusCode: 401, message: 'Login ou senha inválidos.'),
    const ApiError(
      message: 'O servidor demorou para responder. Tente novamente.',
      isTimeout: true,
    ),
    const ApiError(
      message: 'Não foi possível conectar ao servidor.',
      isConnectionError: true,
    ),
  ]) {
    testWidgets('preserva os campos quando ocorre ${error.message}', (
      tester,
    ) async {
      final service = FakeLoginService(handler: (_) => throw error);
      await tester.pumpWidget(app(service));
      await fillForm(tester);

      await tester.tap(find.byKey(const Key('login-submit')));
      await tester.pumpAndSettle();

      expect(find.text(error.message), findsOneWidget);
      expect(
        tester.widget<TextFormField>(field('login-field')).controller?.text,
        'professor',
      );
      expect(
        tester.widget<TextFormField>(field('password-field')).controller?.text,
        'prof123',
      );
    });
  }

  for (final size in [const Size(360, 800), const Size(1200, 800)]) {
    testWidgets('não apresenta overflow em ${size.width.toInt()} px', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(app(FakeLoginService()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Trail Code'), findsOneWidget);
      expect(find.byKey(const Key('login-submit')), findsOneWidget);
    });
  }
}
