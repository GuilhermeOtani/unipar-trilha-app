import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/widgets/app_design_frame.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/models/caminho_trilha.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/widgets/caminho_mapa.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/widgets/trilha_banner.dart';
import 'package:unipar_trilha_app/shared/models/aluno_resumo.dart';
import 'package:unipar_trilha_app/shared/widgets/aluno_header.dart';

/// Tela 2 — Caminho da trilha.
///
/// Canvas de 360 dp (medidas do wireframe):
///
/// | Bloco | Topo | Margens laterais |
/// |---|---|---|
/// | cabeçalho (62 dp) | 21 dp | 9,5 dp |
/// | banner da trilha (39,7 dp) | 99,3 dp | 9 dp |
/// | mapa de lições (428,7 dp para até 7 lições) | 139 dp | posições absolutas |
class CaminhoTrilhaPage extends StatelessWidget {
  const CaminhoTrilhaPage({
    super.key,
    required this.aluno,
    required this.caminho,
    required this.onSelecionarLicao,
  });

  final AlunoResumo aluno;
  final CaminhoTrilha caminho;
  final ValueChanged<LicaoCaminho> onSelecionarLicao;

  @override
  Widget build(BuildContext context) {
    return AppDesignPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 21),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9.5),
            child: AlunoHeader(aluno: aluno),
          ),
          const SizedBox(height: 16.3),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9),
            child: TrilhaBanner(trilha: caminho.trilha),
          ),
          CaminhoMapa(licoes: caminho.licoes, onSelecionar: onSelecionarLicao),
        ],
      ),
    );
  }
}
