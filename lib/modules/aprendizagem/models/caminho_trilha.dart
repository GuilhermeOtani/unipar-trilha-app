import 'package:unipar_trilha_app/modules/catalogo_aluno/models/trilha_resumo.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/dto/caminho_aluno_response.dart';

enum StatusLicao { bloqueada, disponivel, atual, concluida }

/// Nó do caminho da trilha (tela 2).
class LicaoCaminho {
  const LicaoCaminho({
    required this.id,
    required this.titulo,
    required this.status,
    this.recompensa = false,
  });

  final int id;
  final String titulo;
  final StatusLicao status;

  /// Exibe o baú ao lado do nó, ligado por pontos (4º nó no wireframe).
  final bool recompensa;

  bool get interativa =>
      status == StatusLicao.atual || status == StatusLicao.disponivel;
}

/// Trilha com as lições na ordem de estudo (a primeira fica embaixo).
class CaminhoTrilha {
  const CaminhoTrilha({required this.trilha, required this.licoes});

  final TrilhaResumo trilha;
  final List<LicaoCaminho> licoes;

  factory CaminhoTrilha.fromResponse(
    CaminhoAlunoResponse response,
    TrilhaResumo trilha,
  ) {
    return CaminhoTrilha(
      trilha: trilha,
      licoes: [
        for (final modulo in response.modulos)
          for (final licao in modulo.licoes)
            LicaoCaminho(
              id: licao.id,
              titulo: licao.titulo,
              status: switch (licao.status) {
                StatusLicaoResponse.concluida => StatusLicao.concluida,
                StatusLicaoResponse.atual => StatusLicao.atual,
                StatusLicaoResponse.bloqueada => StatusLicao.bloqueada,
              },
            ),
      ],
    );
  }

  /// Lição atual ou, na falta dela, a primeira disponível.
  LicaoCaminho? get licaoAtual {
    for (final status in [StatusLicao.atual, StatusLicao.disponivel]) {
      for (final licao in licoes) {
        if (licao.status == status) return licao;
      }
    }
    return null;
  }
}
