import 'package:unipar_trilha_app/core/widgets/trail_card.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/dto/catalogo_aluno_response.dart';
import 'package:unipar_trilha_app/shared/models/icone_trilha.dart';

export 'package:unipar_trilha_app/shared/models/icone_trilha.dart';

/// Trilha exibida nos cards da home (tela 1) e do catálogo (tela 3).
///
/// [id] é o `distribuicaoId` do catálogo: é ele que abre a sessão de prática.
class TrilhaResumo {
  const TrilhaResumo({
    required this.id,
    required this.titulo,
    required this.progresso,
    required this.status,
    this.disciplina,
    this.tom = TrailCardTone.blue,
    this.icone = IconeTrilha.livro,
    this.temNotificacao = false,
  });

  /// Converte um item de `GET /aluno/distribuicoes`.
  ///
  /// O contrato não informa cor nem ícone; eles alternam pela posição
  /// ([indice]) para manter o ritmo visual dos wireframes.
  factory TrilhaResumo.fromDistribuicao(
    DistribuicaoAlunoResponse item, {
    required int indice,
  }) {
    final progresso = (item.percentualProgresso / 100).clamp(0.0, 1.0);
    return TrilhaResumo(
      id: item.distribuicaoId,
      titulo: item.trilhaTitulo,
      disciplina: item.disciplinaNome,
      progresso: progresso,
      status: item.concluida
          ? TrailStatus.completed
          : progresso > 0
          ? TrailStatus.inProgress
          : TrailStatus.notStarted,
      tom: _tons[indice % _tons.length],
      icone: _icones[indice % _icones.length],
    );
  }

  static const _tons = [
    TrailCardTone.blue,
    TrailCardTone.purple,
    TrailCardTone.cyan,
  ];
  static const _icones = [
    IconeTrilha.codigo,
    IconeTrilha.objetos,
    IconeTrilha.xampp,
  ];

  final int id;
  final String titulo;
  final String? disciplina;

  /// Progresso de 0 a 1.
  final double progresso;
  final TrailStatus status;
  final TrailCardTone tom;
  final IconeTrilha icone;

  /// Exibe o sino de novidade no card (ainda sem campo no contrato).
  final bool temNotificacao;
}
