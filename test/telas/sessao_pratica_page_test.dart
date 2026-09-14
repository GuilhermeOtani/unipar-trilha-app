import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipar_trilha_app/core/theme/app_theme.dart';
import 'package:unipar_trilha_app/core/widgets/app_async_state.dart';
import 'package:unipar_trilha_app/core/widgets/app_progress.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/page/pratica_page.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/page/sessao_pratica_page.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/service/aprendizagem_service.dart';
import 'package:unipar_trilha_app/shared/preview/aluno_preview_api.dart';

import '../support/design_system_harness.dart';
import '../support/fake_http_client_adapter.dart';

void main() {
  Future<void> abrir(
    WidgetTester tester,
    AprendizagemService service, {
    int distribuicaoId = 4,
  }) async {
    useSurface(tester, const Size(1366, 2000));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: SessaoPraticaPage(
            distribuicaoId: distribuicaoId,
            service: service,
            onVoltar: () {},
          ),
        ),
      ),
    );
  }

  Future<void> responder(WidgetTester tester, String opcao) async {
    await tester.tap(find.bySemanticsLabel(RegExp('^[a-d]\\) $opcao')));
    await tester.pump();
    await tester.tap(find.text('Enviar resposta'));
    await tester.pumpAndSettle();
  }

  testWidgets('carrega a sessão, corrige e avança com proximoDesafio', (
    tester,
  ) async {
    final dio = AlunoPreviewApi.dio(atraso: const Duration(milliseconds: 50));
    await abrir(tester, AprendizagemService(dio: dio));

    expect(find.byType(AppLoadingState), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(PraticaPage), findsOneWidget);
    expect(find.text('Qual tag HTML cria um parágrafo?'), findsOneWidget);

    await responder(tester, '<h1>');
    expect(find.text('Não foi dessa vez...'), findsOneWidget);

    await responder(tester, '<p>');
    expect(find.text('Isso aí, excelente!'), findsOneWidget);

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Qual tag HTML cria um link?'), findsOneWidget);
    expect(tester.widget<QuizStepper>(find.byType(QuizStepper)).current, 2);
  });

  testWidgets('falha ao carregar mostra erro e tenta novamente', (
    tester,
  ) async {
    var tentativas = 0;
    final dio = Dio(BaseOptions(baseUrl: 'http://teste'))
      ..httpClientAdapter = FakeHttpClientAdapter((options) {
        tentativas++;
        if (tentativas == 1) {
          return jsonResponse(
            '{"status":404,"detail":"Distribuição não encontrada."}',
            statusCode: 404,
          );
        }
        return AlunoPreviewApi().fetch(options, null, null);
      });
    await abrir(tester, AprendizagemService(dio: dio));
    await tester.pumpAndSettle();

    expect(find.text('Distribuição não encontrada.'), findsOneWidget);
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(tentativas, 2);
    expect(find.byType(PraticaPage), findsOneWidget);
  });
}
