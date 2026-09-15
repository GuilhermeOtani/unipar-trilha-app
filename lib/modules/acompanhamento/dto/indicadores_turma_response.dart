class IndicadoresTurmaResponse {
  const IndicadoresTurmaResponse({
    required this.turmaId,
    required this.turmaNome,
    required this.matriculados,
    required this.iniciaram,
    required this.concluiram,
    required this.percentualConclusao,
    required this.acertos,
    required this.erros,
    required this.acuracia,
    required this.desafiosComMaisErros,
  });

  final int turmaId;
  final String turmaNome;
  final int matriculados;
  final int iniciaram;
  final int concluiram;
  final int percentualConclusao;
  final int acertos;
  final int erros;
  final int acuracia;
  final List<DesafioDificilResponse> desafiosComMaisErros;

  factory IndicadoresTurmaResponse.fromJson(Map<String, dynamic> json) =>
      IndicadoresTurmaResponse(
        turmaId: _int(json, 'turmaId'),
        turmaNome: _string(json, 'turmaNome'),
        matriculados: _int(json, 'matriculados'),
        iniciaram: _int(json, 'iniciaram'),
        concluiram: _int(json, 'concluiram'),
        percentualConclusao: _int(json, 'percentualConclusao'),
        acertos: _int(json, 'acertos'),
        erros: _int(json, 'erros'),
        acuracia: _int(json, 'acuracia'),
        desafiosComMaisErros: _maps(
          json,
          'desafiosComMaisErros',
        ).map(DesafioDificilResponse.fromJson).toList(growable: false),
      );
}

class DesafioDificilResponse {
  const DesafioDificilResponse({
    required this.desafioId,
    required this.enunciado,
    required this.numeroVersao,
    required this.tentativas,
    required this.erros,
    required this.taxaErro,
  });

  final int desafioId;
  final String enunciado;
  final int numeroVersao;
  final int tentativas;
  final int erros;
  final int taxaErro;

  factory DesafioDificilResponse.fromJson(Map<String, dynamic> json) =>
      DesafioDificilResponse(
        desafioId: _int(json, 'desafioId'),
        enunciado: _string(json, 'enunciado'),
        numeroVersao: _int(json, 'numeroVersao'),
        tentativas: _int(json, 'tentativas'),
        erros: _int(json, 'erros'),
        taxaErro: _int(json, 'taxaErro'),
      );
}

int _int(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is num) return value.toInt();
  throw FormatException("Campo '$key' inválido.");
}

String _string(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String) return value;
  throw FormatException("Campo '$key' inválido.");
}

List<Map<String, dynamic>> _maps(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! List) throw FormatException("Campo '$key' inválido.");
  return value
      .map((item) {
        if (item is! Map) throw FormatException("Item de '$key' inválido.");
        return Map<String, dynamic>.from(item);
      })
      .toList(growable: false);
}
