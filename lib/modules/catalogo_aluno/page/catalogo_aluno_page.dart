import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/theme/app_typography.dart';
import 'package:unipar_trilha_app/core/widgets/app_async_state.dart';
import 'package:unipar_trilha_app/core/widgets/app_design_frame.dart';
import 'package:unipar_trilha_app/core/widgets/app_empty_state.dart';
import 'package:unipar_trilha_app/core/widgets/app_scroll_indicator.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/models/trilha_resumo.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/widgets/trilha_card.dart';
import 'package:unipar_trilha_app/shared/models/aluno_resumo.dart';
import 'package:unipar_trilha_app/shared/widgets/aluno_header.dart';

/// Tela 3 — Trilhas de Aprendizado.
///
/// Canvas de 360 dp sem rolagem externa (medidas do wireframe):
///
/// | Bloco | Topo | Margens laterais |
/// |---|---|---|
/// | cabeçalho (62 dp) | 21 dp | 9,5 dp |
/// | título Montserrat 13 sp | 115 dp | 14 dp |
/// | lista de cards (113 dp, 30 dp entre cards) | 154,3 dp | 15,3 / 8,3 dp |
/// | barra de rolagem visível 4 × até o fim | 154,3 dp | x = 351 dp |
///
/// Cabeçalho e título ficam fixos; somente a lista rola.
class CatalogoAlunoPage extends StatefulWidget {
  const CatalogoAlunoPage({
    super.key,
    required this.aluno,
    required this.trilhas,
    required this.onAbrirTrilha,
    this.carregando = false,
    this.erro,
    this.onTentarNovamente,
  });

  final AlunoResumo aluno;
  final List<TrilhaResumo> trilhas;
  final ValueChanged<TrilhaResumo> onAbrirTrilha;

  /// Estado de `CatalogoAlunoService.listar`, controlado pela navegação.
  final bool carregando;
  final String? erro;
  final VoidCallback? onTentarNovamente;

  @override
  State<CatalogoAlunoPage> createState() => _CatalogoAlunoPageState();
}

class _CatalogoAlunoPageState extends State<CatalogoAlunoPage> {
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

    return AppDesignPage(
      scrollable: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 21),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9.5),
            child: AlunoHeader(aluno: widget.aluno),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: SizedBox(
              height: 16,
              child: Semantics(
                header: true,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Trilhas de Aprendizado',
                    maxLines: 1,
                    style: textTheme.titleMedium?.copyWith(
                      fontFamily: AppTypography.displayFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      color: colors.textOnSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 23.3),
          Expanded(
            child: widget.carregando
                ? const Center(
                    child: AppLoadingState(message: 'Carregando trilhas...'),
                  )
                : widget.erro != null
                ? Center(
                    child: AppErrorState(
                      message: widget.erro!,
                      onRetry: widget.onTentarNovamente,
                    ),
                  )
                : widget.trilhas.isEmpty
                ? const Center(
                    child: AppEmptyState(
                      title: 'Nenhuma trilha disponível',
                      message:
                          'Quando o professor liberar uma trilha, ela aparece aqui.',
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ListView.separated(
                          controller: _rolagem,
                          padding: const EdgeInsets.fromLTRB(15.3, 0, 8.3, 16),
                          itemCount: widget.trilhas.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 30),
                          itemBuilder: (context, index) => TrilhaCard(
                            trilha: widget.trilhas[index],
                            onAbrir: widget.onAbrirTrilha,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: AppScrollIndicator(controller: _rolagem),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
