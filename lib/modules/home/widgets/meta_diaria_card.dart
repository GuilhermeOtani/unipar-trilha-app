import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_assets.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/theme/app_spacing.dart';
import 'package:unipar_trilha_app/core/widgets/app_progress.dart';
import 'package:unipar_trilha_app/modules/home/models/home_aluno.dart';

/// Card "Meta Diária" da home (tela 1).
///
/// Pílula de 37 dp contornada: couve 28 dp → título/legenda → barra 8 dp →
/// percentual. Tudo em uma linha, como no wireframe.
class MetaDiariaCard extends StatelessWidget {
  const MetaDiariaCard({super.key, required this.meta});

  final MetaDiaria meta;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final percent = (meta.progresso.clamp(0.0, 1.0) * 100).round();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 3, 18, 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: colors.borderGoal),
      ),
      child: Row(
        children: [
          ExcludeSemantics(
            child: Image.asset(
              AppIllustrations.cabbage,
              width: 29,
              height: 28,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 11),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Meta Diária',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    height: 1.1,
                    color: colors.textOnSurface,
                  ),
                ),
                Text(
                  '${meta.xpRestante} XP para concluir',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 8,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: AppProgressBar(
              value: meta.progresso,
              height: 8,
              semanticLabel: 'Meta diária',
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          ExcludeSemantics(
            child: Text(
              '$percent%',
              style: textTheme.titleMedium?.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
                color: colors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
