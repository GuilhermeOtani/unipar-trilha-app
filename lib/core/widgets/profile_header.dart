import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/theme/app_spacing.dart';
import 'package:unipar_trilha_app/core/widgets/app_avatar.dart';

/// Cabeçalho com avatar, nome e RA do usuário (telas 1, 2 e 3).
///
/// Medidas da tela 1: 62 dp de altura, formato pílula com gradiente ameixa,
/// foto de 48 dp, nome 16 sp e RA 11 sp. [trailing] recebe conteúdo opcional
/// à direita, como a sequência diária.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    this.registration,
    this.avatar,
    this.trailing,
  });

  static const double height = 62;

  final String name;

  /// RA do aluno; exibido como `RA: valor`.
  final String? registration;
  final ImageProvider? avatar;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      constraints: const BoxConstraints(minHeight: height),
      padding: const EdgeInsets.fromLTRB(22, 7, 10, 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.surfaceHeader,
            colors.surfaceHeaderShade,
            colors.surfaceHeader,
          ],
          stops: const [0, 0.55, 1],
        ),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        children: [
          AppAvatar(name: name, image: avatar, size: 48),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.15,
                    color: colors.textOnSurface,
                  ),
                ),
                if (registration != null)
                  Text(
                    'RA: $registration',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: 11,
                      height: 1.2,
                      color: colors.textAccent,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.xs),
            trailing!,
          ],
        ],
      ),
    );
  }
}
