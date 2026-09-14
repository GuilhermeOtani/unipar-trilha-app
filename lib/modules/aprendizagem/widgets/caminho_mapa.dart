import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_assets.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/theme/app_typography.dart';
import 'package:unipar_trilha_app/core/widgets/app_icon.dart';
import 'package:unipar_trilha_app/core/widgets/app_mascot.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/models/caminho_trilha.dart';

/// Mapa de lições da tela 2, nas posições exatas do wireframe.
///
/// O mapa começa logo abaixo do banner (139 dp no canvas) e tem 428,7 dp de
/// altura para até 7 lições. A primeira lição fica embaixo. Com mais lições,
/// o mapa cresce 62 dp por lição acima da sétima e a página rola.
///
/// Elementos: nós ovais 40 × 23 dp com cadeado de 16 dp; nó atual branco
/// 52 × 34 dp com anel de 4 dp e balão "Comece aqui"; baú de 36 dp e quatro
/// pontos ao lado da lição com recompensa; iguana de frente (122 dp) à
/// direita e notebook (89,4 dp) no canto inferior esquerdo.
class CaminhoMapa extends StatelessWidget {
  const CaminhoMapa({
    super.key,
    required this.licoes,
    required this.onSelecionar,
  });

  static const double alturaBase = 428.7;
  static const double passoExtra = 62;

  /// Centros dos nós no wireframe, do início (base) ao fim, relativos ao topo
  /// do mapa.
  static const List<Offset> padrao = [
    Offset(182.3, 383.9),
    Offset(136.3, 338.4),
    Offset(87, 292.7),
    Offset(87, 223.7),
    Offset(136.3, 168.4),
    Offset(185.7, 113.4),
    Offset(144.3, 50.8),
  ];

  static const List<double> _xExtras = [185.7, 136.3, 87, 87, 136.3, 182.3];

  /// Pontos entre a lição com recompensa e o baú, relativos ao centro do nó.
  static const List<Offset> _pontosRecompensa = [
    Offset(-45.3, -20),
    Offset(-37, -15.4),
    Offset(-29.7, -10.7),
    Offset(-22.7, -5.7),
  ];

  final List<LicaoCaminho> licoes;
  final ValueChanged<LicaoCaminho> onSelecionar;

  static int _extras(int quantidade) => math.max(0, quantidade - padrao.length);

  static double alturaPara(int quantidade) =>
      alturaBase + _extras(quantidade) * passoExtra;

  static List<Offset> centros(int quantidade) {
    final deslocamento = _extras(quantidade) * passoExtra;
    return [
      for (var i = 0; i < quantidade; i++)
        i < padrao.length
            ? padrao[i].translate(0, deslocamento)
            : Offset(
                _xExtras[(i - padrao.length) % _xExtras.length],
                padrao.last.dy +
                    deslocamento -
                    (i - padrao.length + 1) * passoExtra,
              ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final altura = alturaPara(licoes.length);
    final pontos = centros(licoes.length);
    final indiceAtual = licoes.indexWhere(
      (licao) => licao.status == StatusLicao.atual,
    );

    return SizedBox(
      height: altura,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 14.3,
            top: altura - 101.7,
            child: ExcludeSemantics(
              child: Image.asset(AppIllustrations.codingLaptop, width: 89.4),
            ),
          ),
          Positioned(
            left: 222.2,
            top: altura - 327.7,
            child: const AppMascot(pose: MascotPose.front, height: 122),
          ),
          for (var i = 0; i < licoes.length; i++)
            if (licoes[i].recompensa) ...[
              for (final ponto in _pontosRecompensa)
                Positioned(
                  left: pontos[i].dx + ponto.dx - 3,
                  top: pontos[i].dy + ponto.dy - 2.25,
                  child: Container(
                    width: 6,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: colors.pathDots,
                      borderRadius: const BorderRadius.all(
                        Radius.elliptical(3, 2.25),
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: pontos[i].dx - 73.7,
                top: pontos[i].dy - 53.7,
                child: Semantics(
                  label: 'Recompensa ao concluir ${licoes[i].titulo}',
                  excludeSemantics: true,
                  child: Image.asset(
                    AppIllustrations.treasureChest,
                    height: 36,
                  ),
                ),
              ),
            ],
          for (var i = 0; i < licoes.length; i++)
            Positioned(
              left: pontos[i].dx - (i == indiceAtual ? 26 : 20),
              top: pontos[i].dy - (i == indiceAtual ? 17.85 : 19.5),
              child: _NoLicao(
                licao: licoes[i],
                ordem: i + 1,
                onTap: licoes[i].interativa
                    ? () => onSelecionar(licoes[i])
                    : null,
              ),
            ),
          if (indiceAtual >= 0)
            Positioned(
              left: pontos[indiceAtual].dx - 15.6,
              top: pontos[indiceAtual].dy - 34.15,
              child: _BalaoAtual(
                texto: indiceAtual == 0 ? 'Comece aqui' : 'Continue aqui',
              ),
            ),
        ],
      ),
    );
  }
}

class _NoLicao extends StatelessWidget {
  const _NoLicao({required this.licao, required this.ordem, this.onTap});

  final LicaoCaminho licao;
  final int ordem;
  final VoidCallback? onTap;

  String get _statusTexto => switch (licao.status) {
    StatusLicao.bloqueada => 'bloqueada',
    StatusLicao.disponivel => 'disponível',
    StatusLicao.atual => 'atual',
    StatusLicao.concluida => 'concluída',
  };

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final sombra = [
      BoxShadow(
        color: colors.shadowStrong.withValues(alpha: 0.8),
        offset: const Offset(0, 1.7),
      ),
    ];

    final Widget visual = licao.status == StatusLicao.atual
        ? SizedBox(
            width: 52,
            height: 35.7,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 52,
                height: 34,
                decoration: BoxDecoration(
                  color: colors.pathNodeCurrent,
                  border: Border.all(color: colors.pathNodeRing, width: 4),
                  borderRadius: const BorderRadius.all(
                    Radius.elliptical(26, 17),
                  ),
                  boxShadow: sombra,
                ),
              ),
            ),
          )
        : SizedBox(
            width: 40,
            height: 39,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  bottom: 1.7,
                  child: Container(
                    width: 40,
                    height: 23,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.pathNode,
                      borderRadius: const BorderRadius.all(
                        Radius.elliptical(20, 11.5),
                      ),
                      boxShadow: sombra,
                    ),
                    child: licao.status == StatusLicao.disponivel
                        ? AppIcon(
                            AppIcons.play,
                            size: 9,
                            color: colors.textOnSurface,
                          )
                        : null,
                  ),
                ),
                if (licao.status == StatusLicao.bloqueada)
                  Positioned(
                    top: 0,
                    child: AppIcon(
                      AppIcons.lock,
                      size: 16,
                      color: colors.iconActive,
                    ),
                  ),
                if (licao.status == StatusLicao.concluida)
                  Positioned(
                    top: 1,
                    child: Image.asset(
                      AppIcons.statusSuccess,
                      width: 14,
                      height: 14,
                    ),
                  ),
              ],
            ),
          );

    return Semantics(
      button: onTap != null,
      enabled: onTap != null,
      label: 'Lição $ordem: ${licao.titulo}, $_statusTexto',
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: visual,
      ),
    );
  }
}

/// Balão "Comece aqui": pílula 89,3 × 25 dp com cauda apontando para o nó.
class _BalaoAtual extends StatelessWidget {
  const _BalaoAtual({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return ExcludeSemantics(
      child: SizedBox(
        width: 89.3,
        height: 31.3,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 5,
              top: 24,
              child: CustomPaint(
                size: const Size(12, 7.3),
                painter: _CaudaPainter(color: colors.pathNodeRing),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              height: 25,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: colors.pathNodeRing,
                  borderRadius: BorderRadius.circular(12.5),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    texto,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontFamily: AppTypography.roundedFamily,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      height: 1,
                      color: colors.textPrimary,
                    ),
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

class _CaudaPainter extends CustomPainter {
  const _CaudaPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.2, 0)
      ..lineTo(size.width, 0)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_CaudaPainter oldDelegate) => oldDelegate.color != color;
}
