import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/theme/app_typography.dart';
import 'package:unipar_trilha_app/core/widgets/app_scroll_indicator.dart';
import 'package:unipar_trilha_app/modules/perfil/models/visao_geral_aluno.dart';

/// Card "Cursos/Trilhas" da tela 7.
///
/// 343 × 132 dp, raio 8, contorno `borderCard`. Título Open Sans 15,5 sp em
/// (19,7; 14); grade de duas linhas preenchida por coluna (81 dp por coluna,
/// ícone de até 31 dp e quantidade Inter 10,5 sp) começando em (27,3; 36,7),
/// com rolagem horizontal e barra visível de 4,6 dp em y = 119,4.
class CursosCard extends StatefulWidget {
  const CursosCard({super.key, required this.cursos});

  static const double height = 132;

  final List<CursoResumo> cursos;

  @override
  State<CursosCard> createState() => _CursosCardState();
}

class _CursosCardState extends State<CursosCard> {
  final _rolagem = ScrollController();

  @override
  void dispose() {
    _rolagem.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final cursos = widget.cursos;
    final colunas = (cursos.length / 2).ceil();

    return Container(
      height: CursosCard.height,
      decoration: BoxDecoration(
        color: colors.surfaceDefault,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.borderCard),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 19.7,
            top: 14,
            child: Text(
              'Cursos/Trilhas',
              style: textTheme.titleMedium?.copyWith(
                fontFamily: AppTypography.readingFamily,
                fontSize: 15.5,
                fontWeight: FontWeight.w400,
                height: 1.2,
                color: colors.textOnSurface,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 36.7,
            height: 66,
            child: cursos.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(left: 27.3, top: 8),
                    child: Text(
                      'Nenhum curso iniciado.',
                      style: textTheme.bodySmall,
                    ),
                  )
                : SingleChildScrollView(
                    controller: _rolagem,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 27.3, right: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var coluna = 0; coluna < colunas; coluna++)
                          SizedBox(
                            width: 81,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _ItemCurso(curso: cursos[coluna * 2]),
                                const SizedBox(height: 10),
                                if (coluna * 2 + 1 < cursos.length)
                                  _ItemCurso(curso: cursos[coluna * 2 + 1]),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
          Positioned(
            left: 12.7,
            right: 11,
            top: 119.4,
            height: 4.6,
            child: AppScrollIndicator(
              controller: _rolagem,
              axis: Axis.horizontal,
              thickness: 4.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemCurso extends StatelessWidget {
  const _ItemCurso({required this.curso});

  final CursoResumo curso;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Semantics(
      label:
          '${curso.nome}: ${curso.quantidade} '
          '${curso.quantidade == 1 ? 'trilha' : 'trilhas'}',
      excludeSemantics: true,
      child: SizedBox(
        height: 28,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 31,
              height: 28,
              child: Center(child: _IconeCurso(curso: curso)),
            ),
            const SizedBox(width: 10),
            Text(
              '${curso.quantidade}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10.5,
                height: 1,
                color: colors.textOnSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconeCurso extends StatelessWidget {
  const _IconeCurso({required this.curso});

  final CursoResumo curso;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    return switch (curso.icone) {
      IconeCurso.spring => Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.brandSpring,
        ),
        child: FaIcon(FontAwesomeIcons.leaf, size: 13, color: colors.onBrand),
      ),
      IconeCurso.xampp => Container(
        width: 27.4,
        height: 27.4,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.brandXampp,
          borderRadius: BorderRadius.circular(6),
        ),
        child: FaIcon(FontAwesomeIcons.bone, size: 15, color: colors.onBrand),
      ),
      IconeCurso.javascript => Container(
        width: 24.4,
        height: 24.4,
        alignment: Alignment.bottomRight,
        padding: const EdgeInsets.fromLTRB(0, 0, 2, 1.5),
        decoration: BoxDecoration(
          color: colors.brandJs,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          'JS',
          style: textTheme.labelSmall?.copyWith(
            fontFamily: AppTypography.displayFamily,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            height: 1,
            color: colors.onBrandJs,
          ),
        ),
      ),
      IconeCurso.hibernate => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            FontAwesomeIcons.cubes,
            size: 19,
            color: colors.brandHibernate,
          ),
          const SizedBox(height: 2),
          Text(
            'HIBERNATE',
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
            style: textTheme.labelSmall?.copyWith(
              letterSpacing: 0,
              fontFamily: AppTypography.displayFamily,
              fontSize: 4.6,
              fontWeight: FontWeight.w600,
              height: 1,
              color: colors.brandHibernate,
            ),
          ),
        ],
      ),
      IconeCurso.generico => Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.surfaceBrand,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          curso.nome.isEmpty ? '?' : curso.nome.substring(0, 1).toUpperCase(),
          style: textTheme.labelSmall?.copyWith(
            fontSize: 11,
            color: colors.textPrimary,
          ),
        ),
      ),
    };
  }
}
