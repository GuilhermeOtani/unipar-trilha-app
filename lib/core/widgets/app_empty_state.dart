import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_assets.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/theme/app_spacing.dart';
import 'package:unipar_trilha_app/core/widgets/app_mascot.dart';

/// Estado vazio com mascote, título, mensagem e ação opcional.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.action,
    this.pose = MascotPose.side,
  });

  final String title;
  final String message;
  final Widget? action;
  final MascotPose pose;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppMascot(pose: pose, height: 120),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
          ),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.md),
            action!,
          ],
        ],
      ),
    );
  }
}
