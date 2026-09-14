import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_assets.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/theme/app_typography.dart';
import 'package:unipar_trilha_app/core/widgets/app_icon.dart';

enum QuizOptionState { idle, selected, correct, incorrect }

/// Alternativa de múltipla escolha (telas 4–6).
///
/// Medidas do wireframe: 323,4 × 47,6 dp, raio 6, borda 1,5 dp; letra
/// Fredoka 16,5 sp, texto Fredoka 21 sp, marcador de 27 dp a 12 dp da borda.
/// O estado nunca depende só de cor: seleção usa o marcador preenchido e a
/// correção usa ícone e rótulo ("Correta"/"Incorreta"). Com [onTap] nulo a
/// opção fica desabilitada.
class QuizOption extends StatelessWidget {
  const QuizOption({
    super.key,
    required this.label,
    required this.text,
    this.state = QuizOptionState.idle,
    this.onTap,
  });

  static const double height = 47.6;

  /// Letra da alternativa, sem parêntese (ex.: "a").
  final String label;
  final String text;
  final QuizOptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final optionStyle = (textTheme.titleMedium ?? const TextStyle()).copyWith(
      fontFamily: AppTypography.roundedFamily,
      fontWeight: FontWeight.w500,
      height: 1,
      color: colors.textOnSurface,
    );

    final (surface, border) = switch (state) {
      QuizOptionState.idle => (colors.surfaceDefault, colors.borderDefault),
      QuizOptionState.selected => (
        colors.surfaceSelected,
        colors.borderDefault,
      ),
      QuizOptionState.correct => (
        colors.feedbackSuccessSurface,
        colors.feedbackSuccessBorder,
      ),
      QuizOptionState.incorrect => (
        colors.feedbackDangerSurface,
        colors.feedbackDangerBorder,
      ),
    };

    final semanticState = switch (state) {
      QuizOptionState.correct => ', resposta correta',
      QuizOptionState.incorrect => ', resposta incorreta',
      _ => '',
    };

    final Widget trailing = switch (state) {
      QuizOptionState.idle => _RadioMark(
        selected: false,
        color: colors.borderFocus,
      ),
      QuizOptionState.selected => _RadioMark(
        selected: true,
        color: colors.borderFocus,
      ),
      QuizOptionState.correct => Padding(
        padding: const EdgeInsets.only(right: 11.7),
        child: _StatusLabel(
          icon: Image.asset(AppIcons.statusSuccess, width: 21.7, height: 21.7),
          text: 'Correta',
          gap: 14.3,
          color: colors.feedbackSuccessTitle,
        ),
      ),
      QuizOptionState.incorrect => Padding(
        padding: const EdgeInsets.only(right: 6.7),
        child: _StatusLabel(
          icon: AppIcon(
            AppIcons.statusError,
            size: 21.7,
            color: colors.feedbackDangerText,
          ),
          text: 'Incorreta',
          gap: 9.6,
          color: colors.feedbackDangerText,
        ),
      ),
    };

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
      side: BorderSide(color: border, width: 1.5),
    );

    return Semantics(
      button: true,
      inMutuallyExclusiveGroup: true,
      checked: state == QuizOptionState.selected,
      enabled: onTap != null,
      label: '$label) $text$semanticState',
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: surface,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: shape,
          splashColor: colors.iconActive.withValues(alpha: 0.16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: height),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 4, 12, 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 26.7,
                    child: Text(
                      '$label)',
                      maxLines: 1,
                      style: optionStyle.copyWith(fontSize: 16.5),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: optionStyle.copyWith(fontSize: 21),
                    ),
                  ),
                  const SizedBox(width: 8),
                  trailing,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RadioMark extends StatelessWidget {
  const _RadioMark({required this.selected, required this.color});

  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 27,
      height: 27,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: selected
          ? Container(
              width: 17,
              height: 17,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            )
          : null,
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({
    required this.icon,
    required this.text,
    required this.gap,
    required this.color,
  });

  final Widget icon;
  final String text;
  final double gap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        SizedBox(width: gap),
        Text(
          text,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontSize: 14.7,
            fontWeight: FontWeight.w400,
            height: 1,
            color: color,
          ),
        ),
      ],
    );
  }
}
