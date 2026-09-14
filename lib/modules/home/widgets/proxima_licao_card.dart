import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_assets.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/theme/app_typography.dart';
import 'package:unipar_trilha_app/core/widgets/app_button.dart';
import 'package:unipar_trilha_app/core/widgets/app_icon.dart';
import 'package:unipar_trilha_app/core/widgets/app_mascot.dart';
import 'package:unipar_trilha_app/modules/home/models/home_aluno.dart';

/// Destaque da próxima lição (parte inferior da tela 1).
///
/// Composição de 135 dp de altura que ocupa a largura toda da tela:
/// - iguana com celular (127 dp) à esquerda;
/// - balão de fala com cauda apontando para a iguana;
/// - card ciano que começa em 103 dp e sangra até a borda direita;
/// - couve com contador "+1" sobre o canto superior direito do card.
class ProximaLicaoCard extends StatelessWidget {
  const ProximaLicaoCard({
    super.key,
    required this.proximaLicao,
    required this.onComecar,
    required this.onAbrirTrilha,
  });

  static const double height = 135;

  final ProximaLicao proximaLicao;
  final VoidCallback onComecar;
  final VoidCallback onAbrirTrilha;

  @override
  Widget build(BuildContext context) {
    final recompensa = proximaLicao.recompensa;
    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 103,
            top: 48,
            right: 0,
            height: 80,
            child: _CardLicao(
              proximaLicao: proximaLicao,
              onComecar: onComecar,
              onAbrirTrilha: onAbrirTrilha,
            ),
          ),
          const Positioned(
            left: 4,
            top: 8,
            child: AppMascot(pose: MascotPose.phone, height: 127),
          ),
          Positioned(
            left: 94,
            top: 0,
            width: 138,
            height: 33,
            child: _BalaoFala(texto: proximaLicao.mensagemMascote),
          ),
          if (recompensa != null) ...[
            Positioned(
              right: 4,
              top: 29,
              child: ExcludeSemantics(
                child: Image.asset(
                  AppIllustrations.cabbage,
                  width: 35,
                  height: 33,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              right: 29,
              top: 51.5,
              child: _ContadorRecompensa(valor: recompensa),
            ),
          ],
        ],
      ),
    );
  }
}

class _CardLicao extends StatelessWidget {
  const _CardLicao({
    required this.proximaLicao,
    required this.onComecar,
    required this.onAbrirTrilha,
  });

  final ProximaLicao proximaLicao;
  final VoidCallback onComecar;
  final VoidCallback onAbrirTrilha;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceInfo,
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(28)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.5, 6, 4.5, 7.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 6, right: 44),
              child: Text(
                proximaLicao.trilha.titulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.headlineSmall?.copyWith(
                  fontFamily: AppTypography.displayFamily,
                  fontSize: 21,
                  fontWeight: FontWeight.w400,
                  height: 1.1,
                  color: colors.textOnSurface,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6.5),
              child: Text(
                'Próxima lição: ${proximaLicao.titulo}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  fontFamily: AppTypography.displayFamily,
                  fontSize: 8,
                  height: 1.2,
                  color: colors.textInfoMuted,
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Começar',
                    icon: AppIcons.play,
                    size: AppButtonSize.small,
                    variant: AppButtonVariant.info,
                    expanded: true,
                    foregroundColor: colors.textOnSurface,
                    iconColor: colors.onAction,
                    labelStyle: textTheme.labelLarge?.copyWith(
                      fontFamily: AppTypography.displayFamily,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                    ),
                    onPressed: onComecar,
                  ),
                ),
                const SizedBox(width: 10),
                Tooltip(
                  message: 'Abrir trilha ${proximaLicao.trilha.titulo}',
                  child: Semantics(
                    button: true,
                    label: 'Abrir trilha ${proximaLicao.trilha.titulo}',
                    excludeSemantics: true,
                    onTap: onAbrirTrilha,
                    child: InkResponse(
                      onTap: onAbrirTrilha,
                      radius: 20,
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: AppIcon(
                          AppIcons.arrowRight,
                          size: 28,
                          color: colors.actionPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Balão claro com fala em fonte monoespaçada e cauda à esquerda.
class _BalaoFala extends StatelessWidget {
  const _BalaoFala({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          bottom: -3,
          child: CustomPaint(
            size: const Size(14, 14),
            painter: _CaudaPainter(color: colors.surfaceBubble),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceBubble,
              borderRadius: BorderRadius.circular(16.5),
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                texto,
                textAlign: TextAlign.center,
                style: AppTypography.code(colors.onBubble).copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CaudaPainter extends CustomPainter {
  const _CaudaPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.35, 0)
      ..lineTo(size.width, size.height * 0.35)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_CaudaPainter oldDelegate) => oldDelegate.color != color;
}

class _ContadorRecompensa extends StatelessWidget {
  const _ContadorRecompensa({required this.valor});

  final int valor;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Semantics(
      label: 'Recompensa: $valor ${valor == 1 ? 'couve' : 'couves'}',
      excludeSemantics: true,
      child: Container(
        width: 15,
        height: 15,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.badgeSurface,
        ),
        child: Text(
          '+$valor',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 7.5,
            fontWeight: FontWeight.w600,
            height: 1,
            color: colors.textOnSurface,
          ),
        ),
      ),
    );
  }
}
