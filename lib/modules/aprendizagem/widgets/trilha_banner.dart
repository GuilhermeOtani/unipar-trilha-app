import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/theme/app_spacing.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/models/trilha_resumo.dart';
import 'package:unipar_trilha_app/shared/widgets/icone_trilha_view.dart';

/// Faixa com o nome da trilha no topo do caminho (tela 2).
///
/// Pílula de 342 × 39,7 dp; ícone do curso 22,7 dp a 15 dp da borda e título
/// Inter 16,5 sp a 13,3 dp do ícone.
class TrilhaBanner extends StatelessWidget {
  const TrilhaBanner({super.key, required this.trilha});

  static const double height = 39.7;

  final TrilhaResumo trilha;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Semantics(
      header: true,
      child: Container(
        height: height,
        padding: const EdgeInsets.fromLTRB(15, 0, 14, 0),
        decoration: BoxDecoration(
          color: colors.surfaceSelected,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: colors.borderDefault, width: 1.2),
        ),
        child: Row(
          children: [
            IconTheme(
              data: IconThemeData(color: colors.trailPurpleIcon),
              child: SizedBox(
                width: 22.7,
                child: Center(
                  child: IconeTrilhaView(icone: trilha.icone, size: 22.7),
                ),
              ),
            ),
            const SizedBox(width: 13.3),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  trilha.titulo,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w400,
                    height: 1.1,
                    color: colors.textOnSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
