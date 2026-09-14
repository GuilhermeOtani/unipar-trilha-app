import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_assets.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';

/// Ação de retorno textual, como "Voltar à Trilha" (telas 4–6).
///
/// Medidas do wireframe: seta de 11,3 × 20,3 dp a 9 dp da borda e texto
/// Inter 10,5 sp a 8,7 dp da seta, ambos em `link`.
class AppBackLink extends StatelessWidget {
  const AppBackLink({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Semantics(
      button: true,
      label: label,
      onTap: onPressed,
      excludeSemantics: true,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(9, 2, 8, 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AppIcons.arrowBack,
                width: 11.3,
                height: 20.3,
                color: colors.link,
                colorBlendMode: BlendMode.srcIn,
              ),
              const SizedBox(width: 8.7),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 10.5,
                  height: 1,
                  color: colors.link,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
