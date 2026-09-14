import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipar_trilha_app/core/theme/app_theme.dart';
import 'package:unipar_trilha_app/core/widgets/app_bottom_navigation.dart';
import 'package:unipar_trilha_app/core/widgets/app_design_frame.dart';
import 'package:unipar_trilha_app/core/widgets/app_mascot.dart';
import 'package:unipar_trilha_app/core/widgets/trail_card.dart';
import 'package:unipar_trilha_app/modules/home/widgets/proxima_licao_card.dart';
import 'package:unipar_trilha_app/shared/preview/aluno_preview_conteudo.dart';
import 'package:unipar_trilha_app/shared/widgets/sequencia_badge.dart';

import '../support/design_system_harness.dart';

void main() {
  const telas = [
    Size(360, 640), // wireframe
    Size(398, 866), // celular grande
    Size(412, 915),
    Size(768, 1024), // tablet
    Size(1366, 900), // desktop
  ];

  Future<void> abrir(WidgetTester tester, Size size) async {
    useSurface(tester, size);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: AlunoPreviewConteudo.navegacao(atraso: Duration.zero),
      ),
    );
    // O catálogo chega pelo service (API simulada) após o primeiro quadro.
    await tester.pumpAndSettle();
  }

  for (final size in telas) {
    final nome = '${size.width.toInt()}×${size.height.toInt()}';

    testWidgets('home escala o canvas de 360 dp em $nome', (tester) async {
      await abrir(tester, size);
      final scale = AppDesignScale.forWidth(size.width);

      expect(tester.takeException(), isNull);

      // Card: 327 dp no wireframe (360 − 19 − 14) e 113 dp de altura.
      final card = tester.getRect(find.byType(TrailCard).first);
      expect(card.width, closeTo(327 * scale, 1));
      expect(card.height, closeTo(113 * scale, 2));

      // Navegação: 341 dp × 55 dp, na mesma escala e centralizada.
      final nav = tester.getRect(find.byType(AppBottomNavigation));
      expect(nav.width, closeTo(341 * scale, 1));
      expect(nav.height, closeTo(55 * scale, 1));
      expect(nav.center.dx, closeTo(size.width / 2, 1));

      // A próxima lição fica a 30,7 dp da navegação, como no wireframe.
      final promo = tester.getRect(find.byType(ProximaLicaoCard));
      expect(nav.top - promo.bottom, closeTo(30.7 * scale, 2));

      // Nada ultrapassa a coluna escalada.
      expect(card.left, greaterThanOrEqualTo(nav.left - 1));
    });
  }

  testWidgets('em telas mais altas a sobra fica entre os blocos', (
    tester,
  ) async {
    await abrir(tester, const Size(398, 866));
    final scale = AppDesignScale.forWidth(398);

    final segundoCard = tester.getRect(find.byType(TrailCard).last);
    final promo = tester.getRect(find.byType(ProximaLicaoCard));
    // No wireframe há 13 dp entre o 2º card e o balão; aqui deve haver mais.
    expect(promo.top - segundoCard.bottom, greaterThan(13 * scale + 40));
  });

  testWidgets('iguana do cabeçalho é espelhada para a esquerda', (
    tester,
  ) async {
    await abrir(tester, const Size(360, 640));

    final flip = tester.widget<Transform>(
      find
          .ancestor(
            of: find.descendant(
              of: find.byType(SequenciaBadge),
              matching: find.byType(AppMascot),
            ),
            matching: find.byType(Transform),
          )
          .first,
    );
    expect(flip.transform.entry(0, 0), -1);
  });
}
