import 'package:flutter/widgets.dart';
import 'package:unipar_trilha_app/core/theme/app_assets.dart';

/// Iguana renderizada como imagem completa, sempre com a proporção original.
///
/// Informe [height] ou [width]; a outra dimensão é calculada pela proporção do
/// arquivo. Sem nenhuma das duas, ocupa a largura disponível.
class AppMascot extends StatelessWidget {
  const AppMascot({
    super.key,
    required this.pose,
    this.height,
    this.width,
    this.semanticLabel,
  }) : assert(height == null || width == null);

  final MascotPose pose;
  final double? height;
  final double? width;

  /// Nulo quando a mascote for apenas decorativa.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      pose.asset,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      semanticLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
    );
    if (height != null) {
      return SizedBox(
        height: height,
        width: height! * pose.aspectRatio,
        child: image,
      );
    }
    if (width != null) {
      return SizedBox(
        width: width,
        height: width! / pose.aspectRatio,
        child: image,
      );
    }
    return AspectRatio(aspectRatio: pose.aspectRatio, child: image);
  }
}
