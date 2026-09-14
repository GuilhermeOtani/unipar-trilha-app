import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';

enum AppMessageKind { error, info }

class AppMessageBanner extends StatelessWidget {
  const AppMessageBanner({
    super.key,
    required this.message,
    this.kind = AppMessageKind.error,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final AppMessageKind kind;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final error = kind == AppMessageKind.error;
    final color = error ? colors.feedbackDangerText : colors.actionInfo;
    final surface = error ? colors.feedbackDangerSurface : colors.surfaceBrand;
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surface,
          border: Border.all(color: color.withValues(alpha: 0.72)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              error ? Icons.error_outline : Icons.info_outline,
              color: color,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: colors.textPrimary),
              ),
            ),
            if (actionLabel != null && onAction != null)
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ),
      ),
    );
  }
}
