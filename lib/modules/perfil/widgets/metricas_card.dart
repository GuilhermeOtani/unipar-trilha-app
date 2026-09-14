import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_assets.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/theme/app_typography.dart';
import 'package:unipar_trilha_app/core/widgets/app_mascot.dart';
import 'package:unipar_trilha_app/modules/perfil/models/visao_geral_aluno.dart';

/// Card de métricas da tela 7, com as posições do wireframe.
///
/// 343 × 169 dp, raio 8, contorno `borderInfo` de 1,5 dp. Rótulos Montserrat
/// Bold 11 sp em `actionInfo`; valores Open Sans 12 sp; diamante 26,6 dp;
/// iguana com celular de 126 dp à direita.
class MetricasCard extends StatelessWidget {
  const MetricasCard({super.key, required this.visaoGeral});

  static const double height = 169;

  final VisaoGeralAluno visaoGeral;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final rotulo = textTheme.labelMedium?.copyWith(
      fontFamily: AppTypography.displayFamily,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: colors.actionInfo,
    );
    final valor = textTheme.bodyMedium?.copyWith(
      fontFamily: AppTypography.readingFamily,
      fontSize: 12,
      height: 1.2,
      color: colors.textOnSurface,
    );
    final professores = visaoGeral.professores;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colors.surfaceInfo,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.borderInfo, width: 1.5),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (visaoGeral.ranking != null) ...[
            Positioned(
              left: 22.4,
              top: 23.5,
              child: Text('Ranking', style: rotulo),
            ),
            Positioned(
              left: 37.7,
              top: 45.4,
              child: Semantics(
                label: 'Ranking: ${visaoGeral.ranking}',
                excludeSemantics: true,
                child: Image.asset(AppIcons.diamond, height: 26.6),
              ),
            ),
          ],
          Positioned(
            left: 126.4,
            top: 24.3,
            child: Text('Turma', style: rotulo),
          ),
          Positioned(
            left: 138,
            top: 44.8,
            width: 90,
            child: Text(visaoGeral.turma, style: valor),
          ),
          Positioned(left: 21.4, top: 88.2, child: Text('XP', style: rotulo)),
          Positioned(
            left: 37,
            top: 110.5,
            child: Text('${visaoGeral.xp}', style: valor),
          ),
          Positioned(
            left: 121,
            top: 87.5,
            child: Text(
              professores.length == 1 ? 'Professor' : 'Professores',
              style: rotulo,
            ),
          ),
          Positioned(
            left: 133.7,
            top: 108.7,
            width: 97,
            child: Text(professores.join(', '), style: valor),
          ),
          const Positioned(
            left: 230.7,
            top: 19.7,
            child: AppMascot(pose: MascotPose.phone, height: 126),
          ),
        ],
      ),
    );
  }
}
