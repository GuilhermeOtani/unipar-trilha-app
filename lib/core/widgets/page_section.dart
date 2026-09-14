import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/theme/app_spacing.dart';
import 'package:unipar_trilha_app/core/theme/app_typography.dart';

/// Seção de página com título, ação textual opcional e conteúdo.
///
/// O padrão segue "Suas trilhas de aprendizado" da tela 1: título 13 sp
/// extra-negrito em uma linha e ação "Ver todas" 8,5 sp em `linkEmphasis`.
class PageSection extends StatelessWidget {
  const PageSection({
    super.key,
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
    this.titleStyle,
    this.headerPadding = EdgeInsets.zero,
    this.spacing = AppSpacing.xs,
  });

  final String title;
  final Widget child;

  /// Ex.: "Ver todas". Exibida somente com [onAction].
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Sobrescreve o estilo do título (ex.: tela 3 usa um título maior).
  final TextStyle? titleStyle;

  /// Margens do título quando diferem das do conteúdo.
  final EdgeInsets headerPadding;

  /// Distância entre o título e o conteúdo.
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: headerPadding,
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  // Uma linha, como no wireframe; reduz proporcionalmente se
                  // a fonte não couber.
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      maxLines: 1,
                      style:
                          titleStyle ??
                          textTheme.titleMedium?.copyWith(
                            fontFamily: AppTypography.displayFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                            color: colors.textOnSurface,
                          ),
                    ),
                  ),
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(width: AppSpacing.sm),
                TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    foregroundColor: colors.linkEmphasis,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxs,
                    ),
                    minimumSize: const Size(48, 24),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.standard,
                    textStyle: textTheme.labelMedium?.copyWith(
                      fontFamily: AppTypography.displayFamily,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: spacing),
        child,
      ],
    );
  }
}
