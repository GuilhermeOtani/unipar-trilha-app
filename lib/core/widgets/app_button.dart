import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/theme/app_spacing.dart';
import 'package:unipar_trilha_app/core/theme/app_typography.dart';
import 'package:unipar_trilha_app/core/widgets/app_icon.dart';

enum AppButtonVariant { primary, secondary, info, confirm, outline }

enum AppButtonSize {
  /// 28 dp: botões internos dos cards dos wireframes (telas 1 e 3). Atende
  /// ao alvo mínimo de 24 × 24 px da WCAG 2.2 AA.
  small(height: 28, horizontalPadding: 12, iconSize: 12),

  /// 48 dp: ações principais de formulário e quiz.
  large(height: 48, horizontalPadding: 24, iconSize: 18);

  const AppButtonSize({
    required this.height,
    required this.horizontalPadding,
    required this.iconSize,
  });

  final double height;
  final double horizontalPadding;
  final double iconSize;
}

/// Botão em formato pílula do design system.
///
/// Estados:
/// - habilitado: [onPressed] não nulo;
/// - desabilitado: [onPressed] nulo;
/// - carregando: [isLoading] verdadeiro, mostra indicador e ignora toques,
///   evitando envio duplicado.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.large,
    this.icon,
    this.isLoading = false,
    this.expanded = false,
    this.backgroundColor,
    this.foregroundColor,
    this.iconColor,
    this.labelStyle,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;

  /// Caminho de um ícone de `AppIcons`, tingido com a cor do texto.
  final String? icon;
  final bool isLoading;

  /// Ocupa toda a largura disponível.
  final bool expanded;

  /// Sobrescritas por token, usadas por componentes com tons próprios.
  final Color? backgroundColor;
  final Color? foregroundColor;

  /// Cor do ícone quando difere do texto (ex.: card da próxima lição).
  final Color? iconColor;

  /// Estilo do rótulo quando o wireframe foge do padrão do tamanho.
  final TextStyle? labelStyle;

  bool get _enabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    final isOutline = variant == AppButtonVariant.outline;
    final background =
        backgroundColor ??
        switch (variant) {
          AppButtonVariant.primary => colors.actionPrimary,
          AppButtonVariant.secondary => colors.actionSecondary,
          AppButtonVariant.info => colors.actionInfo,
          AppButtonVariant.confirm => colors.actionConfirm,
          AppButtonVariant.outline => Colors.transparent,
        };
    final foreground =
        foregroundColor ??
        (isOutline
            ? colors.link
            : variant == AppButtonVariant.confirm
            ? colors.textOnSurface
            : colors.onAction);
    // Durante o carregamento o botão mantém a aparência ativa.
    final active = _enabled || isLoading;
    final effectiveForeground = active ? foreground : colors.textSecondary;
    final effectiveIconColor = active
        ? (iconColor ?? foreground)
        : colors.textSecondary;

    final baseLabel = size == AppButtonSize.small
        ? textTheme.labelLarge?.copyWith(
            fontFamily: AppTypography.displayFamily,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
          )
        : textTheme.labelLarge;

    final style = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          if (isLoading) return background;
          return isOutline ? Colors.transparent : colors.progressTrack;
        }
        if (states.contains(WidgetState.pressed) &&
            variant == AppButtonVariant.primary &&
            backgroundColor == null) {
          return colors.actionPrimaryPressed;
        }
        return background;
      }),
      foregroundColor: WidgetStatePropertyAll(effectiveForeground),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return foreground.withValues(alpha: 0.12);
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          return foreground.withValues(alpha: 0.08);
        }
        return null;
      }),
      minimumSize: WidgetStatePropertyAll(
        Size(expanded ? double.infinity : 0, size.height),
      ),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: size.horizontalPadding),
      ),
      shape: const WidgetStatePropertyAll(StadiumBorder()),
      side: WidgetStatePropertyAll(
        isOutline
            ? BorderSide(color: colors.borderDefault, width: 1.5)
            : BorderSide.none,
      ),
      textStyle: WidgetStatePropertyAll(labelStyle ?? baseLabel),
      elevation: const WidgetStatePropertyAll(0),
      visualDensity: VisualDensity.standard,
      tapTargetSize: size == AppButtonSize.small
          ? MaterialTapTargetSize.shrinkWrap
          : MaterialTapTargetSize.padded,
    );

    final Widget? leading = isLoading
        ? SizedBox.square(
            dimension: size.iconSize + 4,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: effectiveIconColor,
            ),
          )
        : icon == null
        ? null
        : AppIcon(icon!, size: size.iconSize, color: effectiveIconColor);

    return Semantics(
      value: isLoading ? 'Carregando' : null,
      child: FilledButton(
        onPressed: _enabled ? onPressed : null,
        style: style,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              leading,
              SizedBox(
                width: size == AppButtonSize.small ? AppSpacing.xs + 2 : 12,
              ),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
