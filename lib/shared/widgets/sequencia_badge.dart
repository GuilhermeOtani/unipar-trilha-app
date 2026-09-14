import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_assets.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/widgets/app_mascot.dart';

/// Cabeça da iguana (espelhada, olhando para a esquerda) com fogo e contador
/// de dias seguidos (tela 1).
///
/// Composição de 52 × 48 dp: cabeça sorrindo 52 dp de largura, fogo 27 dp
/// de altura sobre o canto inferior direito e contador de 16 dp à esquerda
/// do fogo.
class SequenciaBadge extends StatelessWidget {
  const SequenciaBadge({super.key, required this.dias});

  final int dias;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Semantics(
      label: 'Sequência de $dias ${dias == 1 ? 'dia' : 'dias'}',
      excludeSemantics: true,
      child: SizedBox(
        width: 52,
        height: 48,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: 0,
              // O arquivo olha para a direita; no wireframe a cabeça olha para
              // a esquerda.
              child: Transform.flip(
                flipX: true,
                child: const AppMascot(pose: MascotPose.smile, width: 52),
              ),
            ),
            Positioned(
              left: 25,
              top: 19,
              child: Image.asset(AppIllustrations.flame, height: 27),
            ),
            Positioned(
              left: 9,
              top: 32,
              child: Container(
                width: 16,
                height: 16,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.badgeSurface,
                ),
                child: Text(
                  '$dias',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 1,
                    color: colors.textOnSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
