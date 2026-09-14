import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/theme/app_spacing.dart';
import 'package:unipar_trilha_app/core/widgets/app_button.dart';
import 'package:unipar_trilha_app/core/widgets/app_empty_state.dart';

/// Carregamento de uma tela ou seção enquanto o service responde.
class AppLoadingState extends StatelessWidget {
  const AppLoadingState({super.key, this.message = 'Carregando...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Semantics(
      liveRegion: true,
      label: message,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: colors.actionPrimary),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Falha ao carregar, com a mensagem do `ApiError` e "Tentar novamente".
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.title = 'Não foi possível carregar',
  });

  final String title;
  final String message;

  /// Nulo oculta o botão.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: AppEmptyState(
        title: title,
        message: message,
        action: onRetry == null
            ? null
            : AppButton(
                label: 'Tentar novamente',
                size: AppButtonSize.small,
                onPressed: onRetry,
              ),
      ),
    );
  }
}
