import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';

/// Foto circular do usuário com contorno de destaque.
///
/// Sem [image], exibe as iniciais de [name].
class AppAvatar extends StatelessWidget {
  const AppAvatar({super.key, required this.name, this.image, this.size = 64});

  final String name;
  final ImageProvider? image;
  final double size;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      image: true,
      label: 'Foto de $name',
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: colors.avatarBorder, width: 2),
        ),
        child: CircleAvatar(
          backgroundColor: colors.surfaceBrand,
          foregroundColor: colors.textPrimary,
          backgroundImage: image,
          child: image == null
              ? Text(
                  _initials,
                  style: (size >= 96
                      ? textTheme.headlineMedium
                      : textTheme.titleMedium),
                )
              : null,
        ),
      ),
    );
  }
}
