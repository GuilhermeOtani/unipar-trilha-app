import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipar_trilha_app/core/theme/app_assets.dart';
import 'package:unipar_trilha_app/core/widgets/app_bottom_navigation.dart';
import 'package:unipar_trilha_app/core/widgets/app_button.dart';
import 'package:unipar_trilha_app/core/widgets/app_empty_state.dart';
import 'package:unipar_trilha_app/core/widgets/app_progress.dart';
import 'package:unipar_trilha_app/core/widgets/page_section.dart';
import 'package:unipar_trilha_app/core/widgets/profile_header.dart';
import 'package:unipar_trilha_app/core/widgets/trail_card.dart';

import '../support/design_system_harness.dart';

void main() {
  group('TrailCard', () {
    testWidgets('em 360 px mantém anel, barra e sino, como na tela 1', (
      tester,
    ) async {
      useSurface(tester, compactSize);
      await tester.pumpWidget(
        themed(
          TrailCard(
            title: 'Algoritmos e Lógica',
            progress: 0.4,
            status: TrailStatus.inProgress,
            hasNotification: true,
            onAction: () {},
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(AppProgressRing), findsOneWidget);
      expect(
        find.bySemanticsLabel('Novidade em Algoritmos e Lógica'),
        findsOneWidget,
      );
      expect(find.byType(AppProgressBar), findsOneWidget);
      expect(find.text('40% concluído'), findsOneWidget);
      expect(find.text('Continuar'), findsOneWidget);
    });

    testWidgets('desktop exibe o anel de progresso', (tester) async {
      useSurface(tester, desktopSize);
      await tester.pumpWidget(
        themed(
          TrailCard(
            title: 'Orientação a Objetos',
            progress: 0,
            status: TrailStatus.notStarted,
            tone: TrailCardTone.purple,
            onAction: () {},
          ),
        ),
      );

      expect(find.byType(AppProgressRing), findsOneWidget);
      expect(find.text('Começar'), findsOneWidget);
    });

    testWidgets('bloqueada desabilita a ação', (tester) async {
      await tester.pumpWidget(
        themed(
          TrailCard(
            title: 'XAMPP',
            progress: 0,
            status: TrailStatus.locked,
            onAction: () => fail('não deveria executar'),
          ),
        ),
      );

      final button = tester.widget<AppButton>(find.byType(AppButton));
      expect(button.onPressed, isNull);
      expect(find.text('Bloqueada'), findsOneWidget);
    });

    testWidgets('carregando mantém o card sem ação', (tester) async {
      await tester.pumpWidget(
        themed(
          TrailCard(
            title: 'Algoritmos',
            progress: 0.4,
            status: TrailStatus.inProgress,
            isLoading: true,
            onAction: () {},
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  testWidgets('navegação indica destino ativo e troca de índice', (
    tester,
  ) async {
    const destinos = [
      AppNavigationDestination(icon: AppIcons.home, label: 'Início'),
      AppNavigationDestination(icon: AppIcons.ranking, label: 'Desempenho'),
      AppNavigationDestination(icon: AppIcons.learningBook, label: 'Trilhas'),
    ];
    var selected = 0;
    await tester.pumpWidget(
      themed(
        StatefulBuilder(
          builder: (context, setState) => AppBottomNavigation(
            destinations: destinos,
            currentIndex: selected,
            onSelected: (index) => setState(() => selected = index),
          ),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel('Início')),
      isSemantics(isSelected: true),
    );
    await tester.tap(find.byTooltip('Trilhas'));
    await tester.pump();
    expect(selected, 2);
  });

  testWidgets('PageSection e ProfileHeader exibem conteúdo', (tester) async {
    await tester.pumpWidget(
      themed(
        PageSection(
          title: 'Suas trilhas',
          actionLabel: 'Ver todas',
          onAction: () {},
          child: const ProfileHeader(
            name: 'Maria Joaquina',
            registration: '60020223',
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Suas trilhas'), findsOneWidget);
    expect(find.text('Ver todas'), findsOneWidget);
    expect(find.text('RA: 60020223'), findsOneWidget);
    expect(find.text('MJ'), findsOneWidget);
  });

  testWidgets('estado vazio exibe título e mensagem', (tester) async {
    await tester.pumpWidget(
      themed(const AppEmptyState(title: 'Vazio', message: 'Nada por aqui.')),
    );

    expect(find.text('Vazio'), findsOneWidget);
    expect(find.text('Nada por aqui.'), findsOneWidget);
  });
}
