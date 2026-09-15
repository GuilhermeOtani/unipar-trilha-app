enum StatusLicaoResponse { concluida, atual, bloqueada }

class CaminhoAlunoResponse {
  const CaminhoAlunoResponse({
    required this.distribuicaoId,
    required this.versaoId,
    required this.numeroVersao,
    required this.trilhaTitulo,
    required this.disciplinaNome,
    required this.percentualProgresso,
    required this.modulos,
    this.sessaoId,
  });

  final int distribuicaoId;
  final int? sessaoId;
  final int versaoId;
  final int numeroVersao;
  final String trilhaTitulo;
  final String disciplinaNome;
  final int percentualProgresso;
  final List<ModuloCaminhoResponse> modulos;

  factory CaminhoAlunoResponse.fromJson(Map<String, dynamic> json) {
    return CaminhoAlunoResponse(
      distribuicaoId: _int(json, 'distribuicaoId'),
      sessaoId: _nullableInt(json['sessaoId']),
      versaoId: _int(json, 'versaoId'),
      numeroVersao: _int(json, 'numeroVersao'),
      trilhaTitulo: _string(json, 'trilhaTitulo'),
      disciplinaNome: _string(json, 'disciplinaNome'),
      percentualProgresso: _int(json, 'percentualProgresso'),
      modulos: _list(
        json,
        'modulos',
      ).map(ModuloCaminhoResponse.fromJson).toList(growable: false),
    );
  }
}

class ModuloCaminhoResponse {
  const ModuloCaminhoResponse({
    required this.id,
    required this.titulo,
    required this.ordem,
    required this.licoes,
  });

  final int id;
  final String titulo;
  final int ordem;
  final List<LicaoCaminhoResponse> licoes;

  factory ModuloCaminhoResponse.fromJson(Map<String, dynamic> json) {
    return ModuloCaminhoResponse(
      id: _int(json, 'id'),
      titulo: _string(json, 'titulo'),
      ordem: _int(json, 'ordem'),
      licoes: _list(
        json,
        'licoes',
      ).map(LicaoCaminhoResponse.fromJson).toList(growable: false),
    );
  }
}

class LicaoCaminhoResponse {
  const LicaoCaminhoResponse({
    required this.id,
    required this.titulo,
    required this.ordem,
    required this.totalDesafios,
    required this.desafiosConcluidos,
    required this.status,
    this.resumo,
  });

  final int id;
  final String titulo;
  final String? resumo;
  final int ordem;
  final int totalDesafios;
  final int desafiosConcluidos;
  final StatusLicaoResponse status;

  factory LicaoCaminhoResponse.fromJson(Map<String, dynamic> json) {
    final status = _string(json, 'status');
    return LicaoCaminhoResponse(
      id: _int(json, 'id'),
      titulo: _string(json, 'titulo'),
      resumo: json['resumo'] as String?,
      ordem: _int(json, 'ordem'),
      totalDesafios: _int(json, 'totalDesafios'),
      desafiosConcluidos: _int(json, 'desafiosConcluidos'),
      status: switch (status) {
        'CONCLUIDA' => StatusLicaoResponse.concluida,
        'ATUAL' => StatusLicaoResponse.atual,
        'BLOQUEADA' => StatusLicaoResponse.bloqueada,
        _ => throw FormatException('Status de lição inválido: $status'),
      },
    );
  }
}

List<Map<String, dynamic>> _list(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! List) throw FormatException("Campo '$key' inválido.");
  return value
      .map((item) {
        if (item is! Map) throw FormatException("Item de '$key' inválido.");
        return Map<String, dynamic>.from(item);
      })
      .toList(growable: false);
}

int _int(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is num) return value.toInt();
  throw FormatException("Campo '$key' inválido.");
}

int? _nullableInt(Object? value) => value is num ? value.toInt() : null;

String _string(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) return value;
  throw FormatException("Campo '$key' inválido.");
}
