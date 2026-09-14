import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';

/// Barra de rolagem sempre visível, como nos wireframes das telas 3 e 7.
///
/// Desenha o trilho inteiro e o indicador proporcional à parte visível do
/// conteúdo de [controller]. Sem rolagem disponível, o indicador ocupa o
/// trilho todo. É decorativa: a rolagem continua pelo gesto no conteúdo.
class AppScrollIndicator extends StatelessWidget {
  const AppScrollIndicator({
    super.key,
    required this.controller,
    this.axis = Axis.vertical,
    this.thickness = 4,
  });

  final ScrollController controller;
  final Axis axis;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return ExcludeSemantics(
      child: CustomPaint(
        painter: _IndicatorPainter(
          controller: controller,
          axis: axis,
          trackColor: colors.scrollTrack,
          thumbColor: colors.scrollThumb,
        ),
        child: axis == Axis.vertical
            ? SizedBox(width: thickness, height: double.infinity)
            : SizedBox(width: double.infinity, height: thickness),
      ),
    );
  }
}

class _IndicatorPainter extends CustomPainter {
  _IndicatorPainter({
    required this.controller,
    required this.axis,
    required this.trackColor,
    required this.thumbColor,
  }) : super(repaint: controller);

  final ScrollController controller;
  final Axis axis;
  final Color trackColor;
  final Color thumbColor;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(
      (axis == Axis.vertical ? size.width : size.height) / 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, radius),
      Paint()..color = trackColor,
    );

    var fraction = 1.0;
    var start = 0.0;
    if (controller.hasClients) {
      final position = controller.position;
      if (position.hasContentDimensions && position.hasViewportDimension) {
        final range = position.maxScrollExtent - position.minScrollExtent;
        final total = range + position.viewportDimension;
        if (total > 0) {
          fraction = (position.viewportDimension / total).clamp(0.1, 1.0);
          if (range > 0) {
            final progress =
                ((position.pixels - position.minScrollExtent) / range).clamp(
                  0.0,
                  1.0,
                );
            start = progress * (1 - fraction);
          }
        }
      }
    }

    final length = axis == Axis.vertical ? size.height : size.width;
    final thumb = axis == Axis.vertical
        ? Rect.fromLTWH(0, start * length, size.width, fraction * length)
        : Rect.fromLTWH(start * length, 0, fraction * length, size.height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(thumb, radius),
      Paint()..color = thumbColor,
    );
  }

  @override
  bool shouldRepaint(_IndicatorPainter oldDelegate) => true;
}
