import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/theme/app_spacing.dart';
import 'package:unipar_trilha_app/core/widgets/app_async_state.dart';
import 'package:unipar_trilha_app/core/widgets/app_design_frame.dart';
import 'package:unipar_trilha_app/core/widgets/page_section.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/models/trilha_resumo.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/widgets/trilha_card.dart';
import 'package:unipar_trilha_app/modules/home/models/home_aluno.dart';
import 'package:unipar_trilha_app/modules/home/widgets/meta_diaria_card.dart';
import 'package:unipar_trilha_app/modules/home/widgets/proxima_licao_card.dart';
import 'package:unipar_trilha_app/shared/models/aluno_resumo.dart';
import 'package:unipar_trilha_app/shared/widgets/aluno_header.dart';

/// Tela 1 — Home do aluno.
///
/// Montada no canvas de 360 dp (`AppDesignPage`) com as medidas do wireframe
/// e escalada pela largura da tela:
///
/// | Bloco | Topo | Margens laterais |
/// |---|---|---|
/// | cabeçalho (62 dp) | 21 dp | 9,5 dp |
/// | meta diária (37 dp) | +7 dp | 10,5 / 10 dp |
/// | título da seção (24 dp) | +6 dp | 22 / 27 dp |
/// | cards de trilha (113 dp, espaço 8 dp) | +6 dp | 19 / 14 dp |
/// | próxima lição (135 dp) | +13 dp | sangra nas duas bordas |
/// | fim do conteúdo | +22,7 dp | — |
///
/// Em 360 × 640 dp o conteúdo ocupa exatamente a área acima da navegação.
/// Em telas proporcionalmente mais altas, a sobra vai para depois da meta
/// diária (1 parte) e antes da próxima lição (3 partes); o bloco da próxima
/// lição continua junto da navegação, como no wireframe.
class AlunoHomePage extends StatelessWidget {
  const AlunoHomePage({
    super.key,
    required this.aluno,
    required this.trilhas,
    required this.onAbrirTrilha,
    required this.onVerTodas,
    required this.onComecarProximaLicao,
    this.metaDiaria,
    this.proximaLicao,
    this.limiteTrilhas = 2,
    this.carregandoTrilhas = false,
    this.erroTrilhas,
    this.onTentarNovamente,
  });

  /// Estado de `CatalogoAlunoService.listar`, controlado pela navegação.
  final bool carregandoTrilhas;
  final String? erroTrilhas;
  final VoidCallback? onTentarNovamente;

  final AlunoResumo aluno;
  final List<TrilhaResumo> trilhas;
  final MetaDiaria? metaDiaria;
  final ProximaLicao? proximaLicao;
  final int limiteTrilhas;
  final ValueChanged<TrilhaResumo> onAbrirTrilha;
  final VoidCallback onVerTodas;
  final ValueChanged<ProximaLicao> onComecarProximaLicao;

  @override
  Widget build(BuildContext context) {
    final visiveis = trilhas.take(limiteTrilhas).toList();

    return AppDesignPage(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 21, 0, 22.7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9.5),
              child: AlunoHeader(aluno: aluno),
            ),
            if (metaDiaria != null) ...[
              const SizedBox(height: 7),
              Padding(
                padding: const EdgeInsets.fromLTRB(10.5, 0, 10, 0),
                child: MetaDiariaCard(meta: metaDiaria!),
              ),
            ],
            const SizedBox(height: 6),
            const Spacer(),
            PageSection(
              title: 'Suas trilhas de aprendizado',
              actionLabel: 'Ver todas',
              onAction: onVerTodas,
              spacing: 6,
              headerPadding: const EdgeInsets.fromLTRB(22, 0, 27, 0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(19, 0, 14, 0),
                child: carregandoTrilhas
                    ? const AppLoadingState(message: 'Carregando trilhas...')
                    : erroTrilhas != null
                    ? _AvisoTrilhas(
                        mensagem: erroTrilhas!,
                        onTentarNovamente: onTentarNovamente,
                      )
                    : visiveis.isEmpty
                    ? const _AvisoTrilhas(
                        mensagem: 'Nenhuma trilha disponível no momento.',
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < visiveis.length; i++) ...[
                            if (i > 0) const SizedBox(height: AppSpacing.xs),
                            TrilhaCard(
                              trilha: visiveis[i],
                              onAbrir: onAbrirTrilha,
                            ),
                          ],
                        ],
                      ),
              ),
            ),
            if (proximaLicao != null) ...[
              const SizedBox(height: 13),
              const Spacer(flex: 3),
              ProximaLicaoCard(
                proximaLicao: proximaLicao!,
                onComecar: () => onComecarProximaLicao(proximaLicao!),
                onAbrirTrilha: () => onAbrirTrilha(proximaLicao!.trilha),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Mensagem compacta no lugar dos cards (lista vazia ou falha ao carregar).
class _AvisoTrilhas extends StatelessWidget {
  const _AvisoTrilhas({required this.mensagem, this.onTentarNovamente});

  final String mensagem;
  final VoidCallback? onTentarNovamente;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        children: [
          Text(
            mensagem,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
          ),
          if (onTentarNovamente != null)
            TextButton(
              onPressed: onTentarNovamente,
              child: const Text('Tentar novamente'),
            ),
        ],
      ),
    );
  }
}
