/// Resposta de `GET /aluno/distribuicoes`.
class CatalogoAlunoResponse {
  const CatalogoAlunoResponse({required this.distribuicoes});

  final List<DistribuicaoAlunoResponse> distribuicoes;

  factory CatalogoAlunoResponse.fromJson(Map<String, dynamic> json) {
    final distribuicoes = json['distribuicoes'];
    if (distribuicoes is! List) {
      throw const FormatException(
        "Campo obrigatório 'distribuicoes' ausente ou inválido.",
      );
    }
    return CatalogoAlunoResponse(
      distribuicoes: [
        for (final item in distribuicoes)
          if (item is Map)
            DistribuicaoAlunoResponse.fromJson(Map<String, dynamic>.from(item))
          else
            throw const FormatException('Distribuição do catálogo inválida.'),
      ],
    );
  }
}

/// Item do catálogo: uma versão de trilha distribuída para a turma do aluno.
///
/// Não contém opções nem respostas corretas.
class DistribuicaoAlunoResponse {
  const DistribuicaoAlunoResponse({
    required this.distribuicaoId,
    required this.trilhaTitulo,
    required this.disciplinaNome,
    required this.numeroVersao,
    required this.totalDesafios,
    required this.percentualProgresso,
    required this.concluida,
  });

  final int distribuicaoId;
  final String trilhaTitulo;
  final String disciplinaNome;
  final int numeroVersao;
  final int totalDesafios;

  /// Progresso de 0 a 100 calculado pelo backend.
  final int percentualProgresso;
  final bool concluida;

  factory DistribuicaoAlunoResponse.fromJson(Map<String, dynamic> json) {
    final concluida = json['concluida'];
    if (concluida is! bool) {
      throw const FormatException(
        "Campo obrigatório 'concluida' ausente ou inválido.",
      );
    }
    return DistribuicaoAlunoResponse(
      distribuicaoId: _requiredInt(json, 'distribuicaoId'),
      trilhaTitulo: _requiredString(json, 'trilhaTitulo'),
      disciplinaNome: _requiredString(json, 'disciplinaNome'),
      numeroVersao: _requiredInt(json, 'numeroVersao'),
      totalDesafios: _requiredInt(json, 'totalDesafios'),
      percentualProgresso: _requiredInt(json, 'percentualProgresso'),
      concluida: concluida,
    );
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
    throw FormatException("Campo obrigatório '$key' ausente ou inválido.");
  }

  static int _requiredInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is num) return value.toInt();
    throw FormatException("Campo obrigatório '$key' ausente ou inválido.");
  }
}
