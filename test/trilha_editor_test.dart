import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipar_trilha_app/core/theme/app_assets.dart';
import 'package:unipar_trilha_app/core/theme/app_theme.dart';
import 'package:unipar_trilha_app/core/widgets/app_bottom_navigation.dart';
import 'package:unipar_trilha_app/core/widgets/app_shell.dart';
import 'package:unipar_trilha_app/modules/trilha/dto/trilha_dto.dart';
import 'package:unipar_trilha_app/modules/trilha/page/trilha_editor_page.dart';
import 'support/trilha_editor_fixtures.dart';

Finder campo(String label) => find.widgetWithText(TextFormField, label);
Future<void> tocar(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> preencher(WidgetTester tester, String label, String texto) async {
  await tester.ensureVisible(campo(label));
  await tester.enterText(campo(label), texto);
  await tester.pump();
}

Future<void> montar(
  WidgetTester tester,
  FakeTrilhaEditorService service, {
  int? id,
  Size size = const Size(360, 800),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      home: RepaintBoundary(
        key: const Key('captura'),
        child: AppShell(
          bottomNavigation: AppBottomNavigation(
            destinations: const [
              AppNavigationDestination(icon: AppIcons.home, label: 'Início'),
              AppNavigationDestination(
                icon: AppIcons.learningBook,
                label: 'Trilhas',
              ),
              AppNavigationDestination(
                icon: AppIcons.play,
                label: 'Distribuir',
              ),
              AppNavigationDestination(
                icon: AppIcons.ranking,
                label: 'Acompanhar',
              ),
              AppNavigationDestination(icon: AppIcons.menu, label: 'Perfil'),
            ],
            currentIndex: 1,
            onSelected: (_) {},
          ),
          body: TrilhaEditorPage(
            contexto: contextoEditor,
            service: service,
            trilhaId: id,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> abrirDesafios(WidgetTester tester) async {
  await tocar(tester, find.text('Continuar'));
  await tocar(tester, find.text('Abrir lições'));
  await tocar(tester, find.text('Abrir desafios'));
}

void main() {
  testWidgets(
    'cria quatro etapas, salva disciplina selecionada e bloqueia POST duplicado',
    (tester) async {
      final service = FakeTrilhaEditorService()
        ..criacaoPendente = Completer<TrilhaResponse>();
      await montar(tester, service);
      await preencher(tester, 'Título', 'Trilha nova');
      await tocar(tester, find.byType(DropdownButtonFormField<int>));
      await tocar(tester, find.text('Banco de Dados').last);
      await tester.ensureVisible(find.text('Criar'));
      await tester.tap(find.text('Criar'));
      await tester.tap(find.text('Criar'));
      await tester.pump();
      expect(service.criacoes, 1);
      expect(service.criacaoRecebida!.disciplinaId, 7);
      service.criacaoPendente!.complete(trilhaCompletaEditor);
      await tester.pumpAndSettle();
      expect(find.text('Criação de Módulos'), findsOneWidget);
      await preencher(tester, 'Título', 'Módulo A');
      await tocar(tester, find.text('Criar'));
      await preencher(tester, 'Título', 'Lição A');
      await preencher(tester, 'Resumo', 'Resumo da lição');
      await tocar(tester, find.text('Criar'));
      await preencher(tester, 'Enunciado', 'Qual opção?');
      await preencher(tester, 'Feedback', 'Explicação');
      await preencher(tester, 'Opção 1', 'Sim');
      await preencher(tester, 'Opção 2', 'Não');
      await tocar(tester, find.byKey(const Key('salvar-trilha')));
      expect(service.atualizacoes, 1);
      expect(service.publicacoes, 0);
      final request = service.conteudoRecebido!;
      expect(request.disciplinaId, 7);
      expect(request.modulos.single.licoes.single.resumo, 'Resumo da lição');
      expect(
        request
            .modulos
            .single
            .licoes
            .single
            .desafios
            .single
            .opcoes
            .first
            .correta,
        isTrue,
      );
      expect(find.text('Criação de Desafios'), findsOneWidget);
      expect(
        tester
            .widget<TextButton>(
              find.widgetWithText(TextButton, 'Revisar e publicar'),
            )
            .onPressed,
        isNotNull,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'reabre, preserva dados ao voltar e valida opções sem perder texto',
    (tester) async {
      final service = FakeTrilhaEditorService();
      await montar(tester, service, id: 4);
      await abrirDesafios(tester);
      await preencher(tester, 'Enunciado', 'Enunciado alterado');
      await tocar(tester, find.text('Voltar para Lições'));
      expect(find.text('Primeira lição'), findsWidgets);
      await tocar(tester, find.text('Abrir desafios'));
      expect(find.text('Enunciado alterado'), findsWidgets);
      expect(
        tester
            .widget<TextButton>(
              find.widgetWithText(TextButton, 'Revisar e publicar'),
            )
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<IconButton>(
              find.byWidgetPredicate(
                (w) => w is IconButton && w.tooltip == 'Remover opção 1',
              ),
            )
            .onPressed,
        isNull,
      );
      await tocar(tester, find.text('Adicionar mais opções'));
      await preencher(tester, 'Opção 3', 'Terceira');
      await tocar(tester, find.byTooltip('Marcar opção 3 como correta'));
      await tocar(tester, find.byTooltip('Remover opção 2'));
      await tocar(tester, find.byKey(const Key('salvar-trilha')));
      expect(
        service
            .conteudoRecebido!
            .modulos
            .single
            .licoes
            .single
            .desafios
            .single
            .opcoes
            .last
            .texto,
        'Terceira',
      );
      expect(
        service
            .conteudoRecebido!
            .modulos
            .single
            .licoes
            .single
            .desafios
            .single
            .opcoes
            .last
            .correta,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'erro de carga oferece retry; erro ao salvar mantém dados e bloqueia envio duplicado',
    (tester) async {
      final service = FakeTrilhaEditorService()..falharCarga = true;
      await montar(tester, service, id: 4);
      expect(find.text('Falha ao carregar'), findsOneWidget);
      service.falharCarga = false;
      await tocar(tester, find.text('Tentar novamente'));
      await abrirDesafios(tester);
      service.falharSalvar = true;
      await preencher(tester, 'Feedback', 'Feedback preservado');
      await tocar(tester, find.byKey(const Key('salvar-trilha')));
      expect(
        find.textContaining('Seus dados continuam preenchidos'),
        findsOneWidget,
      );
      expect(find.text('Feedback preservado'), findsOneWidget);
      service.falharSalvar = false;
      service.salvamentoPendente = Completer<TrilhaResponse>();
      await tester.ensureVisible(find.byKey(const Key('salvar-trilha')));
      await tester.tap(find.byKey(const Key('salvar-trilha')));
      await tester.tap(find.byKey(const Key('salvar-trilha')));
      await tester.pump();
      expect(service.atualizacoes, 2);
      service.salvamentoPendente!.complete(trilhaCompletaEditor);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'validação abre módulo pendente e permite criar múltiplos módulos',
    (tester) async {
      final service = FakeTrilhaEditorService();
      await montar(tester, service, id: 4);
      await tocar(tester, find.text('Continuar'));
      await tocar(tester, find.text('Adicionar módulo'));
      await tocar(tester, find.text('Salvar rascunho'));
      expect(find.text('Preencha o título do módulo.'), findsOneWidget);
      expect(service.atualizacoes, 0);
      await preencher(tester, 'Título', 'Módulo dois');
      await tocar(tester, find.text('Criar'));
      await preencher(tester, 'Título', 'Lição dois');
      await tocar(tester, find.text('Criar'));
      await preencher(tester, 'Enunciado', 'Questão dois');
      await preencher(tester, 'Feedback', 'Feedback dois');
      await preencher(tester, 'Opção 1', 'A');
      await preencher(tester, 'Opção 2', 'B');
      await tocar(tester, find.byKey(const Key('salvar-trilha')));
      expect(service.conteudoRecebido!.modulos.length, 2);
      expect(service.conteudoRecebido!.modulos.last.ordem, 2);
      expect(
        service
            .conteudoRecebido!
            .modulos
            .first
            .licoes
            .single
            .desafios
            .single
            .enunciado,
        desafioEditor.enunciado,
      );
    },
  );

  testWidgets(
    'saída avisa sobre alterações e publicação é independente do salvamento',
    (tester) async {
      final service = FakeTrilhaEditorService();
      await montar(tester, service, id: 4);
      await preencher(tester, 'Título', 'Título alterado');
      await tocar(tester, find.byTooltip('Voltar para Trilhas'));
      expect(find.text('Sair sem salvar?'), findsOneWidget);
      await tocar(tester, find.text('Continuar editando'));
      expect(find.text('Título alterado'), findsOneWidget);
      await tocar(tester, find.text('Salvar rascunho'));
      service.falharPublicar = true;
      await tocar(tester, find.text('Revisar e publicar'));
      expect(find.text('Primeira lição · 1 desafio(s)'), findsOneWidget);
      await tocar(tester, find.text('Publicar versão'));
      expect(find.textContaining('O rascunho está salvo'), findsOneWidget);
      expect(service.atualizacoes, 1);
      service.falharPublicar = false;
      service.publicacaoPendente = Completer<PublicacaoResponse>();
      await tocar(tester, find.text('Revisar e publicar'));
      await tester.tap(find.text('Publicar versão'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(service.publicacoes, 2);
      service.publicacaoPendente!.complete(
        const PublicacaoResponse(versaoId: 8, numeroVersao: 1),
      );
      await tester.pumpAndSettle();
      expect(service.atualizacoes, 1);
    },
  );

  for (final size in [
    const Size(360, 640),
    const Size(412, 915),
    const Size(1366, 900),
  ]) {
    testWidgets('quatro telas sem overflow em $size, textos longos e teclado', (
      tester,
    ) async {
      const captures = String.fromEnvironment('EDITOR_SCREENSHOTS');
      if (captures.isNotEmpty) {
        final manifest =
            jsonDecode(await rootBundle.loadString('FontManifest.json'))
                as List<dynamic>;
        for (final entry in manifest) {
          final loader = FontLoader(entry['family'] as String);
          for (final font in entry['fonts'] as List<dynamic>) {
            loader.addFont(rootBundle.load(font['asset'] as String));
          }
          await loader.load();
        }
      }
      final service = FakeTrilhaEditorService();
      await montar(tester, service, size: size);
      if (captures.isNotEmpty) {
        await tester.runAsync(() async {
          final context = tester.element(find.byType(AppBottomNavigation));
          for (final asset in [
            AppIcons.home,
            AppIcons.learningBook,
            AppIcons.play,
            AppIcons.ranking,
            AppIcons.menu,
          ]) {
            await precacheImage(AssetImage(asset), context);
          }
        });
        await tester.pumpAndSettle();
      }
      Future<void> capturar(String etapa) async {
        expect(tester.takeException(), isNull, reason: etapa);
        if (captures.isEmpty) return;
        await tester.pumpAndSettle();
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const Key('captura')),
        );
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File('$captures/${size.width.toInt()}-$etapa.png');
          await file.parent.create(recursive: true);
          await file.writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
      }

      await capturar('dados');
      await preencher(tester, 'Título', 'Algoritmos e lógica de programação');
      await tocar(tester, find.text('Criar'));
      await capturar('modulos');
      await preencher(
        tester,
        'Título',
        'Módulo com título longo para conferir o comportamento em celulares',
      );
      await tocar(tester, find.text('Criar'));
      await capturar('licoes');
      await preencher(
        tester,
        'Título',
        'Lição com título longo para conferir a navegação',
      );
      await tocar(tester, find.text('Criar'));
      await capturar('desafios');
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await preencher(
        tester,
        'Feedback',
        'Um feedback longo que permanece acessível com o teclado aberto. ' * 8,
      );
      await tester.pumpAndSettle();
      await capturar('teclado');
      expect(find.byType(AppBottomNavigation), findsOneWidget);
    });
  }
}
