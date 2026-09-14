import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipar_trilha_app/core/api_error.dart';
import 'package:unipar_trilha_app/core/theme/app_theme.dart';
import 'package:unipar_trilha_app/core/widgets/app_button.dart';
import 'package:unipar_trilha_app/core/widgets/feedback_card.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/models/desafio_pratica.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/page/pratica_page.dart';
import 'package:unipar_trilha_app/shared/preview/aluno_preview_conteudo.dart';

import '../support/design_system_harness.dart';

void main() {
  Future<void> abrir(
    WidgetTester tester, {
    ResponderDesafio? responder,
    ValueChanged<CorrecaoPratica>? onContinuar,
    VoidCallback? onVoltar,
  }) async {
    useSurface(tester, const Size(1366, 2000));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: PraticaPage(
            desafio: AlunoPreviewConteudo.desafio,
            onResponder: responder ?? AlunoPreviewConteudo.responder,
            onVoltar: onVoltar ?? () {},
            onContinuar: onContinuar ?? (_) {},
          ),
        ),
      ),
    );
  }

  AppButton enviar(WidgetTester tester) => tester.widget<AppButton>(
    find.widgetWithText(AppButton, 'Enviar resposta'),
  );

  testWidgets('tela 4: enviar só habilita após selecionar', (tester) async {
    await abrir(tester);

    expect(enviar(tester).onPressed, isNull);
    await tester.tap(find.bySemanticsLabel('a) <h1>'));
    await tester.pump();
    expect(enviar(tester).onPressed, isNotNull);
  });

  testWidgets('tela 5: erro mostra feedback e permite nova tentativa', (
    tester,
  ) async {
    var envios = 0;
    await abrir(
      tester,
      responder: (desafio, opcao) {
        envios++;
        return AlunoPreviewConteudo.responder(desafio, opcao);
      },
    );

    await tester.tap(find.bySemanticsLabel('a) <h1>'));
    await tester.pump();
    await tester.tap(find.text('Enviar resposta'));
    await tester.pump();
    expect(enviar(tester).isLoading, isTrue);
    await tester.tap(find.text('Enviar resposta'));
    await tester.pump(const Duration(seconds: 1));

    expect(envios, 1);
    expect(find.text('Não foi dessa vez...'), findsOneWidget);
    expect(find.text('Incorreta'), findsOneWidget);
    expect(find.text('Dica: pense na inicial de parágrafo.'), findsOneWidget);

    // Nova tentativa: escolher outra alternativa limpa o feedback, como no
    // wireframe (sem botão extra no card de erro).
    await tester.tap(find.bySemanticsLabel('b) <th>'));
    await tester.pump();
    expect(find.byType(FeedbackCard), findsNothing);
    expect(enviar(tester).onPressed, isNotNull);
  });

  testWidgets('tela 6: acerto mostra feedback e continua', (tester) async {
    var continuou = false;
    await abrir(tester, onContinuar: (_) => continuou = true);

    await tester.tap(find.bySemanticsLabel('d) <p>'));
    await tester.pump();
    await tester.tap(find.text('Enviar resposta'));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Isso aí, excelente!'), findsOneWidget);
    expect(find.text('Correta'), findsOneWidget);
    await tester.tap(find.text('Continuar'));
    expect(continuou, isTrue);
  });

  testWidgets('falha no envio mantém a seleção e informa o erro', (
    tester,
  ) async {
    await abrir(
      tester,
      responder: (_, _) async =>
          throw const ApiError(message: 'Sem conexão com o servidor.'),
    );

    await tester.tap(find.bySemanticsLabel('b) <th>'));
    await tester.pump();
    await tester.tap(find.text('Enviar resposta'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Sem conexão com o servidor.'), findsOneWidget);
    expect(find.byType(FeedbackCard), findsNothing);
    expect(enviar(tester).onPressed, isNotNull);
  });

  testWidgets('voltar à trilha chama o callback', (tester) async {
    var voltou = false;
    await abrir(tester, onVoltar: () => voltou = true);

    await tester.tap(find.text('Voltar à Trilha'));
    expect(voltou, isTrue);
  });
}
