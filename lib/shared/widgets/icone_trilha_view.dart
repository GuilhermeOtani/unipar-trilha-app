import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unipar_trilha_app/core/theme/app_assets.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/widgets/app_icon.dart';
import 'package:unipar_trilha_app/shared/models/icone_trilha.dart';

/// Desenha o ícone de uma trilha. Cor e tamanho vêm do `IconTheme`, exceto o
/// XAMPP, que usa o quadrado laranja da marca como no wireframe da tela 3.
class IconeTrilhaView extends StatelessWidget {
  const IconeTrilhaView({super.key, required this.icone, this.size = 26});

  final IconeTrilha icone;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return switch (icone) {
      IconeTrilha.codigo => FaIcon(FontAwesomeIcons.code, size: size),
      IconeTrilha.objetos => FaIcon(FontAwesomeIcons.cube, size: size),
      IconeTrilha.xampp => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.brandXampp,
          borderRadius: BorderRadius.circular(size * 0.23),
        ),
        child: FaIcon(
          FontAwesomeIcons.bone,
          size: size * 0.58,
          color: colors.onBrand,
        ),
      ),
      IconeTrilha.livro => AppIcon(AppIcons.learningBook, size: size),
    };
  }
}
