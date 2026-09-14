import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_assets.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/widgets/app_avatar.dart';
import 'package:unipar_trilha_app/modules/perfil/models/visao_geral_aluno.dart';

/// Card azul do topo da tela 7.
///
/// 343 × 182,7 dp encostado no topo, cantos inferiores com raio 20. Nome
/// Inter 15 sp em (13,3; 22,3); foto de 95 dp centralizada a 42,7 dp do
/// topo com sombra; couve 29,4 × 27,7 dp e total Inter 12 sp em y = 140; RA
/// Inter 10 sp alinhado a 28 dp da direita.
class PerfilResumoCard extends StatelessWidget {
  const PerfilResumoCard({super.key, required this.visaoGeral});

  static const double height = 182.7;

  final VisaoGeralAluno visaoGeral;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final aluno = visaoGeral.aluno;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colors.surfaceProfile,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 13.3,
            top: 22.3,
            right: 120,
            child: Text(
              aluno.nome,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleLarge?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 1.2,
                color: colors.textOnSurface,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 42.7,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadowStrong.withValues(alpha: 0.35),
                      offset: const Offset(0, 14),
                      blurRadius: 28,
                    ),
                  ],
                ),
                child: AppAvatar(
                  name: aluno.nome,
                  image: aluno.fotoUrl == null
                      ? null
                      : NetworkImage(aluno.fotoUrl!),
                  size: 95,
                ),
              ),
            ),
          ),
          Positioned(
            left: 13.3,
            top: 140,
            child: Semantics(
              label: '${visaoGeral.pontos} couves',
              excludeSemantics: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    AppIllustrations.cabbage,
                    width: 29.4,
                    height: 27.7,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 15.6),
                  Text(
                    '${visaoGeral.pontos}',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1,
                      color: colors.textOnSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 28,
            top: 147,
            child: Text(
              'RA: ${aluno.ra}',
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 10,
                height: 1.1,
                letterSpacing: 0,
                color: colors.textOnSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
