import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final action = loading ? null : onPressed;
    return Semantics(
      button: true,
      label: loading ? '$label, carregando' : label,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton(
          onPressed: action,
          style: FilledButton.styleFrom(
            backgroundColor: colors.actionPrimary,
            foregroundColor: colors.onAction,
            disabledBackgroundColor: colors.actionPrimary.withValues(
              alpha: 0.42,
            ),
            disabledForegroundColor: colors.onAction.withValues(alpha: 0.64),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          child: loading
              ? SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: colors.onAction,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      IconTheme(
                        data: const IconThemeData(size: 20),
                        child: icon!,
                      ),
                      const SizedBox(width: 10),
                    ],
                    Text(label),
                  ],
                ),
        ),
      ),
    );
  }
}
