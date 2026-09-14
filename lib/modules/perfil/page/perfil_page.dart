import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/theme/app_typography.dart';
import 'package:unipar_trilha_app/core/widgets/app_design_frame.dart';
import 'package:unipar_trilha_app/modules/perfil/models/visao_geral_aluno.dart';
import 'package:unipar_trilha_app/modules/perfil/widgets/cursos_card.dart';
import 'package:unipar_trilha_app/modules/perfil/widgets/metricas_card.dart';
import 'package:unipar_trilha_app/modules/perfil/widgets/perfil_resumo_card.dart';

/// Tela 7 — Perfil e visão geral do aluno.
///
/// Canvas de 360 dp (medidas do wireframe):
///
/// | Bloco | Topo | Margens laterais |
/// |---|---|---|
/// | card do perfil (182,7 dp) | 0 | 8 / 9 dp |
/// | "VISÃO GERAL" Montserrat Black 15 sp | 199 dp | 10,3 dp |
/// | cursos/trilhas (132 dp) | 233,3 dp | 8 / 9 dp |
/// | métricas (169 dp) | 384,3 dp | 10,3 / 6,7 dp |
class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key, required this.visaoGeral});

  final VisaoGeralAluno visaoGeral;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return AppDesignPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 9, 0),
            child: PerfilResumoCard(visaoGeral: visaoGeral),
          ),
          const SizedBox(height: 16.3),
          Padding(
            padding: const EdgeInsets.only(left: 10.3),
            child: Semantics(
              header: true,
              child: Text(
                'VISÃO GERAL',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontFamily: AppTypography.displayFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  color: colors.textOnSurface,
                ),
              ),
            ),
          ),
          const SizedBox(height: 17.5),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 9, 0),
            child: CursosCard(cursos: visaoGeral.cursos),
          ),
          const SizedBox(height: 19),
          Padding(
            padding: const EdgeInsets.fromLTRB(10.3, 0, 6.7, 0),
            child: MetricasCard(visaoGeral: visaoGeral),
          ),
          const SizedBox(height: 14.4),
        ],
      ),
    );
  }
}
