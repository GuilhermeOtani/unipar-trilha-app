import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';

/// Escala de desenho dos wireframes.
///
/// Os wireframes têm 1080 × 1920 px em 3×, ou seja, um canvas de 360 × 640 dp.
/// As telas refinadas são montadas nesse canvas com as medidas exatas e
/// escaladas pela largura disponível:
///
/// | Largura útil | Fator | Resultado |
/// |---|---|---|
/// | 306 dp ou menos | 0,85 | canvas reduzido, com rolagem se necessário |
/// | 360 dp | 1,00 | idêntico ao wireframe |
/// | 398 dp (ex.: celular grande) | 1,106 | tudo 10,6% maior |
/// | 486 dp ou mais (tablet, desktop) | 1,35 | coluna de 486 dp centralizada |
abstract final class AppDesignScale {
  static const double designWidth = 360;
  static const double designHeight = 640;
  static const double minScale = 0.85;
  static const double maxScale = 1.35;

  /// Fator aplicado ao canvas de 360 dp para ocupar [width].
  static double forWidth(double width) {
    return (width / designWidth).clamp(minScale, maxScale).toDouble();
  }

  static double of(BuildContext context) {
    return forWidth(MediaQuery.sizeOf(context).width);
  }
}

/// Página desenhada no canvas de 360 dp e escalada pela largura da tela.
///
/// - `scrollable: true` (padrão): o canvas recebe ao menos a altura da área
///   visível (em unidades de desenho) para que `Spacer`s distribuam a sobra;
///   quando o conteúdo é maior, a página rola. O conteúdo é medido com
///   `IntrinsicHeight`, portanto não use `LayoutBuilder` nem `ListView`
///   dentro de [child].
/// - `scrollable: false`: o canvas tem exatamente a altura da área visível.
///   Use `Expanded` com rolagem interna (ex.: lista da tela 3).
class AppDesignPage extends StatelessWidget {
  const AppDesignPage({super.key, required this.child, this.scrollable = true});

  final Widget child;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Material(
      color: colors.backgroundApp,
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, viewport) {
            final scale = AppDesignScale.forWidth(viewport.maxWidth);
            final visibleHeight = viewport.hasBoundedHeight
                ? viewport.maxHeight / scale
                : AppDesignScale.designHeight;

            final Widget canvas = scrollable
                ? ConstrainedBox(
                    constraints: BoxConstraints(minHeight: visibleHeight),
                    child: IntrinsicHeight(child: child),
                  )
                : SizedBox(height: visibleHeight, child: child);

            final frame = Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: AppDesignScale.designWidth * scale,
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: AppDesignScale.designWidth,
                    child: canvas,
                  ),
                ),
              ),
            );
            return scrollable ? SingleChildScrollView(child: frame) : frame;
          },
        ),
      ),
    );
  }
}
