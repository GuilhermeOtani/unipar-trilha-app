import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_assets.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/theme/app_typography.dart';
import 'package:unipar_trilha_app/core/widgets/app_icon.dart';
import 'package:unipar_trilha_app/core/widgets/app_mascot.dart';

enum FeedbackVariant { success, danger }

/// Feedback exibido após a correção de uma resposta (telas 5 e 6).
///
/// Medidas do wireframe (card de 323,4 dp de largura e altura mínima 206 dp,
/// raio 20, borda 1,5 dp):
///
/// | Parte | Erro (tela 5) | Acerto (tela 6) |
/// |---|---|---|
/// | mascote | `neutral` 75 dp em (9,7; 17) | `speaking` 96,7 dp em (5; 0) |
/// | ícone | 34 dp em (94,7; 26,3) | 36 dp em (95; 26,3) |
/// | título | Inter 16,2 sp em x = 141,7 | idem, em `feedbackSuccessTitle` |
/// | explicação | Open Sans 12,7 sp à esquerda, x = 104,7 | Montserrat 11,7 sp centralizada |
/// | código | Fira Code em caixa de 204 × 36,7 dp | Montserrat 12 sp em `codeText`, sem caixa |
/// | dica | Open Sans 12 sp | — |
///
/// É anunciado como região dinâmica para leitores de tela. [action], quando
/// informado, fica na parte inferior do card.
class FeedbackCard extends StatelessWidget {
  const FeedbackCard({
    super.key,
    required this.variant,
    required this.title,
    required this.message,
    this.code,
    this.hint,
    this.action,
    this.showMascot = true,
  });

  static const double minHeight = 206;

  final FeedbackVariant variant;
  final String title;
  final String message;

  /// Trecho de código.
  final String? code;

  /// Texto exibido após o prefixo "Dica:".
  final String? hint;

  /// Ação opcional, como "Continuar".
  final Widget? action;
  final bool showMascot;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final success = variant == FeedbackVariant.success;
    final accent = success
        ? colors.feedbackSuccessTitle
        : colors.feedbackDangerText;
    final border = success
        ? colors.feedbackSuccessBorder
        : colors.feedbackDangerBorder;
    final iconSize = success ? 36.0 : 34.0;

    final header = SizedBox(
      height: success ? 79.3 : 73,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (showMascot)
            Positioned(
              left: success ? 5 : 9.7,
              top: success ? 0 : 17,
              child: AppMascot(
                pose: success ? MascotPose.speaking : MascotPose.neutral,
                width: success ? 96.7 : 75,
              ),
            ),
          Positioned(
            left: success ? 95 : 94.7,
            top: 26.3,
            child: success
                ? Image.asset(
                    AppIcons.statusSuccess,
                    width: iconSize,
                    height: iconSize,
                    excludeFromSemantics: true,
                  )
                : AppIcon(AppIcons.statusError, size: iconSize, color: accent),
          ),
          Positioned(
            left: 141.7,
            right: 14,
            top: 26.3,
            height: iconSize,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  maxLines: 1,
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: 16.2,
                    fontWeight: FontWeight.w400,
                    height: 1,
                    color: accent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final hintStyle = textTheme.bodyMedium?.copyWith(
      fontFamily: AppTypography.readingFamily,
      fontSize: 12,
      height: 1.2,
      letterSpacing: 0,
      color: colors.textSecondary,
    );

    final Widget details = success
        ? Padding(
            padding: const EdgeInsets.fromLTRB(95, 0, 30, 0),
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 176),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      fontFamily: AppTypography.displayFamily,
                      fontSize: 11.7,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                if (code != null) ...[
                  const SizedBox(height: 13),
                  Text(
                    code!,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      fontFamily: AppTypography.displayFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      color: colors.codeText,
                    ),
                  ),
                ],
                if (hint != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Dica: $hint',
                    textAlign: TextAlign.center,
                    style: hintStyle,
                  ),
                ],
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.fromLTRB(104.7, 0, 8, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 172),
                  child: Text(
                    message,
                    style: textTheme.bodyMedium?.copyWith(
                      fontFamily: AppTypography.readingFamily,
                      fontSize: 12.7,
                      height: 1.2,
                      letterSpacing: 0,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                if (code != null) ...[
                  const SizedBox(height: 9),
                  Container(
                    width: 204,
                    constraints: const BoxConstraints(minHeight: 36.7),
                    padding: const EdgeInsets.symmetric(horizontal: 13.7),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: colors.backgroundApp,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.borderSubtle),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        code!,
                        maxLines: 1,
                        style: AppTypography.code(
                          colors.codeHighlight,
                        ).copyWith(fontSize: 13.6, height: 1.1),
                      ),
                    ),
                  ),
                ],
                if (hint != null) ...[
                  const SizedBox(height: 13.7),
                  Text('Dica: $hint', style: hintStyle),
                ],
              ],
            ),
          );

    return Semantics(
      container: true,
      liveRegion: true,
      label: success ? 'Resposta correta' : 'Resposta incorreta',
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: minHeight),
            decoration: BoxDecoration(
              color: colors.backgroundApp,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                details,
                SizedBox(height: action == null ? 16 : 52),
              ],
            ),
          ),
          if (action != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 14,
              child: Center(child: action),
            ),
        ],
      ),
    );
  }
}
