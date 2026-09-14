import 'package:unipar_trilha_app/modules/catalogo_aluno/models/trilha_resumo.dart';

/// Meta diária exibida no topo da home (tela 1).
class MetaDiaria {
  const MetaDiaria({required this.xpRestante, required this.progresso});

  final int xpRestante;

  /// Progresso de 0 a 1.
  final double progresso;
}

/// Destaque da próxima lição com a mascote (tela 1).
class ProximaLicao {
  const ProximaLicao({
    required this.trilha,
    required this.titulo,
    required this.mensagemMascote,
    this.recompensa,
  });

  final TrilhaResumo trilha;
  final String titulo;

  /// Fala do balão; aceita quebra de linha explícita.
  final String mensagemMascote;

  /// Couves ganhas ao concluir a lição. Nulo oculta a couve com o contador.
  final int? recompensa;
}
