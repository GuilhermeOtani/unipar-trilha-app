import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipar_trilha_app/core/theme/app_theme.dart';
import 'package:unipar_trilha_app/core/widgets/app_async_state.dart';
import 'package:unipar_trilha_app/core/widgets/trail_card.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/service/aprendizagem_service.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/service/catalogo_aluno_service.dart';
import 'package:unipar_trilha_app/modules/home/page/aluno_navegacao_page.dart';
import 'package:unipar_trilha_app/shared/preview/aluno_preview_api.dart';
import 'package:unipar_trilha_app/shared/preview/aluno_preview_conteudo.dart';

import '../support/design_system_harness.dart';
import '../support/fake_http_client_adapter.dart';

void main() {
  testWidgets('catálogo: carregando, erro com retry e sucesso', (tester) async {
    var chamadas = 0;
    final dio = Dio(BaseOptions(baseUrl: 'http://teste'))
      ..httpClientAdapter = FakeHttpClientAdapter((options) async {
        chamadas++;
        await Future<void>.delayed(const Duration(milliseconds: 50));
        if (chamadas == 1) {
          return jsonResponse(
            '{"status":503,"detail":"Serviço indisponível."}',
            statusCode: 503,
          );
        }
        return AlunoPreviewApi(
          atraso: Duration.zero,
        ).fetch(options, null, null);
      });

    useSurface(tester, const Size(1366, 2400));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: AlunoNavegacaoPage(
          conteudo: AlunoPreviewConteudo.conteudo(),
          catalogoService: CatalogoAlunoService(dio: dio),
          aprendizagemService: AprendizagemService(dio: dio),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(AppLoadingState), findsWidgets);

    await tester.pumpAndSettle();
    expect(find.text('Serviço indisponível.'), findsOneWidget);
    expect(find.byType(TrailCard), findsNothing);

    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(chamadas, 2);
    expect(find.byType(TrailCard), findsNWidgets(2));
  });

  testWidgets('catálogo vazio informa que não há trilhas', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://teste'))
      ..httpClientAdapter = FakeHttpClientAdapter(
        (_) => jsonResponse('{"distribuicoes": []}'),
      );

    useSurface(tester, const Size(1366, 2400));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: AlunoNavegacaoPage(
          conteudo: AlunoPreviewConteudo.conteudo(),
          catalogoService: CatalogoAlunoService(dio: dio),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma trilha disponível no momento.'), findsOneWidget);
  });
}
