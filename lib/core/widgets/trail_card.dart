import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_assets.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/theme/app_spacing.dart';
import 'package:unipar_trilha_app/core/theme/app_typography.dart';
import 'package:unipar_trilha_app/core/widgets/app_button.dart';
import 'package:unipar_trilha_app/core/widgets/app_icon.dart';
import 'package:unipar_trilha_app/core/widgets/app_progress.dart';

enum TrailCardTone { blue, purple, cyan }

enum TrailStatus { notStarted, inProgress, completed, locked }

/// Card de trilha (telas 1 e 3).
///
/// Medidas da tela 1 (360 dp): 113 dp de altura, raio 16, caixa do ícone
/// 47 dp, título 12 sp extra-negrito (reduz
/// proporcionalmente se não couber), barra 5,5 dp, botão 28 dp e anel de
/// 82 dp à direita. O anel aparece em qualquer largura, como no wireframe.
class TrailCard extends StatelessWidget {
  const TrailCard({
    super.key,
    required this.title,
    required this.progress,
    required this.status,
    this.tone = TrailCardTone.blue,
    this.leading,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.isLoading = false,
    this.hasNotification = false,
  });

  final String title;

  /// Progresso de 0 a 1, conforme retornado pela API.
  final double progress;
  final TrailStatus status;
  final TrailCardTone tone;

  /// Ícone do curso, tingido pela cor do tom. Padrão: livro.
  final Widget? leading;

  /// Padrão: `n% concluído`.
  final String? subtitle;

  /// Padrão derivado de [status]: Começar, Continuar, Concluída ou Bloqueada.
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isLoading;

  /// Exibe o sino vermelho no canto superior direito (tela 1, 2º card).
  final bool hasNotification;

  static const double ringSize = 82;

  String get _defaultActionLabel => switch (status) {
    TrailStatus.notStarted => 'Começar',
    TrailStatus.inProgress => 'Continuar',
    TrailStatus.completed => 'Concluída',
    TrailStatus.locked => 'Bloqueada',
  };

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final percent = (progress.clamp(0.0, 1.0) * 100).round();
    final locked = status == TrailStatus.locked;

    final (surface, action, track, iconColor) = switch (tone) {
      TrailCardTone.blue => (
        colors.trailBlueSurface,
        colors.trailBlueAction,
        colors.trailBlueTrack,
        colors.trailBlueIcon,
      ),
      TrailCardTone.purple => (
        colors.trailPurpleSurface,
        colors.trailPurpleAction,
        colors.trailPurpleTrack,
        colors.trailPurpleIcon,
      ),
      TrailCardTone.cyan => (
        colors.trailCyanSurface,
        colors.trailCyanAction,
        colors.trailCyanTrack,
        colors.trailCyanIcon,
      ),
    };

    final caixaSolida = tone == TrailCardTone.cyan;
    final iconBox = Container(
      width: 47,
      height: 47,
      decoration: BoxDecoration(
        color: caixaSolida
            ? colors.trailCyanIconBox
            : colors.textOnSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: caixaSolida
              ? colors.trailCyanIconBoxBorder
              : colors.textOnSurface.withValues(alpha: 0.07),
        ),
      ),
      alignment: Alignment.center,
      child: IconTheme(
        data: IconThemeData(color: iconColor, size: 26),
        child: leading ?? const AppIcon(AppIcons.learningBook),
      ),
    );

    // Alturas fixas por faixa, medidas no wireframe, para que o card tenha
    // 113 dp independentemente das métricas da fonte.
    final texts = SizedBox(
      height: 52.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 3),
          SizedBox(
            height: 16,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                maxLines: 1,
                style: (textTheme.titleMedium ?? const TextStyle()).copyWith(
                  fontFamily: AppTypography.displayFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  color: colors.textOnSurface,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8.5),
          SizedBox(
            height: 13,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                subtitle ?? '$percent% concluído',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  fontFamily: AppTypography.displayFamily,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                  color: colors.textOnSurface,
                ),
              ),
            ),
          ),
          const Spacer(),
          AppProgressBar(
            value: progress,
            height: 5.5,
            color: action,
            trackColor: track,
            semanticLabel: 'Progresso de $title',
          ),
        ],
      ),
    );

    final card = Material(
      color: surface,
      borderRadius: BorderRadius.circular(AppRadius.md + 4),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14.5, 12.5, 14.5, 9.5),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      iconBox,
                      const SizedBox(width: 13),
                      Expanded(child: texts),
                    ],
                  ),
                  const SizedBox(height: 10.5),
                  AppButton(
                    label: actionLabel ?? _defaultActionLabel,
                    icon: locked ? AppIcons.lock : AppIcons.play,
                    size: AppButtonSize.small,
                    onPressed: locked ? null : onAction,
                    isLoading: isLoading,
                    expanded: true,
                    backgroundColor: action,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 25),
            AppProgressRing(
              value: progress,
              size: ringSize,
              color: action,
              trackColor: track,
              semanticLabel: 'Progresso de $title',
            ),
          ],
        ),
      ),
    );

    if (!hasNotification) {
      return card;
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        card,
        Positioned(
          top: -2,
          right: -4,
          child: Semantics(
            label: 'Novidade em $title',
            excludeSemantics: true,
            child: Container(
              width: 19,
              height: 19,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.notification,
              ),
              child: AppIcon(
                AppIcons.notificationBell,
                size: 11,
                color: colors.surfaceBubble,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
