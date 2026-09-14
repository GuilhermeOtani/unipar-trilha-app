enum StatusSessao {
  emAndamento('EM_ANDAMENTO'),
  concluida('CONCLUIDA');

  const StatusSessao(this.apiValue);

  final String apiValue;

  static StatusSessao fromJson(Object? value) {
    return StatusSessao.values.firstWhere(
      (status) => status.apiValue == value,
      orElse: () => throw FormatException('Status de sessão inválido: $value'),
    );
  }
}

/// Resposta de `POST /aluno/distribuicoes/{id}/sessoes` e
/// `GET /aluno/sessoes/{id}`.
class SessaoResponse {
  const SessaoResponse({
    required this.sessaoId,
    required this.distribuicaoId,
    required this.trilhaTitulo,
    required this.numeroVersao,
    required this.status,
    required this.progresso,
    this.licaoTitulo,
    this.desafioAtual,
  });

  final int sessaoId;
  final int distribuicaoId;
  final String trilhaTitulo;
  final int numeroVersao;

  /// Nulo quando a sessão está concluída.
  final String? licaoTitulo;
  final StatusSessao status;
  final ProgressoResponse progresso;

  /// Nulo quando a sessão está concluída.
  final DesafioAlunoResponse? desafioAtual;

  factory SessaoResponse.fromJson(Map<String, dynamic> json) {
    final licaoTitulo = json['licaoTitulo'];
    return SessaoResponse(
      sessaoId: _requiredInt(json, 'sessaoId'),
      distribuicaoId: _requiredInt(json, 'distribuicaoId'),
      trilhaTitulo: _requiredString(json, 'trilhaTitulo'),
      numeroVersao: _requiredInt(json, 'numeroVersao'),
      licaoTitulo: licaoTitulo is String ? licaoTitulo : null,
      status: StatusSessao.fromJson(json['status']),
      progresso: ProgressoResponse.fromJson(_requiredMap(json, 'progresso')),
      desafioAtual: DesafioAlunoResponse.fromNullableJson(json['desafioAtual']),
    );
  }
}

class ProgressoResponse {
  const ProgressoResponse({
    required this.respondidos,
    required this.total,
    required this.percentual,
    required this.concluida,
  });

  /// Desafios já acertados.
  final int respondidos;
  final int total;
  final int percentual;
  final bool concluida;

  factory ProgressoResponse.fromJson(Map<String, dynamic> json) {
    final concluida = json['concluida'];
    if (concluida is! bool) {
      throw const FormatException(
        "Campo obrigatório 'concluida' ausente ou inválido.",
      );
    }
    return ProgressoResponse(
      respondidos: _requiredInt(json, 'respondidos'),
      total: _requiredInt(json, 'total'),
      percentual: _requiredInt(json, 'percentual'),
      concluida: concluida,
    );
  }
}

/// Desafio enviado ao aluno. Não declara `correta` em nenhuma opção.
class DesafioAlunoResponse {
  const DesafioAlunoResponse({
    required this.id,
    required this.enunciado,
    required this.opcoes,
    this.tipo,
    this.dificuldade,
  });

  final int id;
  final String enunciado;
  final String? tipo;
  final String? dificuldade;
  final List<OpcaoAlunoResponse> opcoes;

  factory DesafioAlunoResponse.fromJson(Map<String, dynamic> json) {
    final opcoes = json['opcoes'];
    if (opcoes is! List) {
      throw const FormatException(
        "Campo obrigatório 'opcoes' ausente ou inválido.",
      );
    }
    final tipo = json['tipo'];
    final dificuldade = json['dificuldade'];
    return DesafioAlunoResponse(
      id: _requiredInt(json, 'id'),
      enunciado: _requiredString(json, 'enunciado'),
      tipo: tipo is String ? tipo : null,
      dificuldade: dificuldade is String ? dificuldade : null,
      opcoes: [
        for (final opcao in opcoes)
          if (opcao is Map)
            OpcaoAlunoResponse.fromJson(Map<String, dynamic>.from(opcao))
          else
            throw const FormatException('Opção do desafio inválida.'),
      ],
    );
  }

  static DesafioAlunoResponse? fromNullableJson(Object? value) {
    if (value == null) return null;
    if (value is! Map) throw const FormatException('Desafio inválido.');
    return DesafioAlunoResponse.fromJson(Map<String, dynamic>.from(value));
  }
}

/// Opção do aluno: apenas `id` e `texto`.
class OpcaoAlunoResponse {
  const OpcaoAlunoResponse({required this.id, required this.texto});

  final int id;
  final String texto;

  factory OpcaoAlunoResponse.fromJson(Map<String, dynamic> json) {
    return OpcaoAlunoResponse(
      id: _requiredInt(json, 'id'),
      texto: _requiredString(json, 'texto'),
    );
  }
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) return value;
  throw FormatException("Campo obrigatório '$key' ausente ou inválido.");
}

int _requiredInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is num) return value.toInt();
  throw FormatException("Campo obrigatório '$key' ausente ou inválido.");
}

Map<String, dynamic> _requiredMap(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is Map) return Map<String, dynamic>.from(value);
  throw FormatException("Campo obrigatório '$key' ausente ou inválido.");
}
