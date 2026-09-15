class PublicacaoResumoResponse {
  const PublicacaoResumoResponse({
    required this.versaoId,
    required this.numeroVersao,
    required this.publicadaEm,
  });

  final int versaoId;
  final int numeroVersao;
  final DateTime publicadaEm;

  factory PublicacaoResumoResponse.fromJson(Map<String, dynamic> json) {
    return PublicacaoResumoResponse(
      versaoId: _int(json, 'versaoId'),
      numeroVersao: _int(json, 'numeroVersao'),
      publicadaEm: _date(json, 'publicadaEm'),
    );
  }
}

class TrilhaProfessorResumoResponse {
  const TrilhaProfessorResumoResponse({
    required this.id,
    required this.titulo,
    required this.status,
    required this.disciplinaId,
    required this.disciplinaNome,
    required this.atualizadoEm,
    required this.publicacoes,
    this.descricao,
  });

  final int id;
  final String titulo;
  final String? descricao;
  final String status;
  final int disciplinaId;
  final String disciplinaNome;
  final DateTime atualizadoEm;
  final List<PublicacaoResumoResponse> publicacoes;

  factory TrilhaProfessorResumoResponse.fromJson(Map<String, dynamic> json) {
    return TrilhaProfessorResumoResponse(
      id: _int(json, 'id'),
      titulo: _string(json, 'titulo'),
      descricao: json['descricao'] as String?,
      status: _string(json, 'status'),
      disciplinaId: _int(json, 'disciplinaId'),
      disciplinaNome: _string(json, 'disciplinaNome'),
      atualizadoEm: _date(json, 'atualizadoEm'),
      publicacoes: _maps(
        json,
        'publicacoes',
      ).map(PublicacaoResumoResponse.fromJson).toList(growable: false),
    );
  }
}

class TrilhaResponse {
  const TrilhaResponse({
    required this.id,
    required this.titulo,
    required this.status,
    required this.disciplinaId,
    required this.disciplinaNome,
    required this.modulos,
    this.descricao,
  });

  final int id;
  final String titulo;
  final String? descricao;
  final String status;
  final int disciplinaId;
  final String disciplinaNome;
  final List<ModuloTrilhaDto> modulos;

  factory TrilhaResponse.fromJson(Map<String, dynamic> json) {
    return TrilhaResponse(
      id: _int(json, 'id'),
      titulo: _string(json, 'titulo'),
      descricao: json['descricao'] as String?,
      status: _string(json, 'status'),
      disciplinaId: _int(json, 'disciplinaId'),
      disciplinaNome: _string(json, 'disciplinaNome'),
      modulos: _maps(
        json,
        'modulos',
      ).map(ModuloTrilhaDto.fromJson).toList(growable: false),
    );
  }
}

class TrilhaCreateRequest {
  const TrilhaCreateRequest({
    required this.titulo,
    required this.disciplinaId,
    this.descricao,
  });

  final String titulo;
  final String? descricao;
  final int disciplinaId;

  Map<String, dynamic> toJson() => {
    'titulo': titulo,
    'descricao': descricao,
    'disciplinaId': disciplinaId,
  };
}

class TrilhaConteudoRequest extends TrilhaCreateRequest {
  const TrilhaConteudoRequest({
    required super.titulo,
    required super.disciplinaId,
    required this.modulos,
    super.descricao,
  });

  final List<ModuloTrilhaDto> modulos;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'modulos': modulos.map((item) => item.toJson()).toList(growable: false),
  };
}

class ModuloTrilhaDto {
  const ModuloTrilhaDto({
    required this.titulo,
    required this.ordem,
    required this.licoes,
    this.id,
  });

  final int? id;
  final String titulo;
  final int ordem;
  final List<LicaoTrilhaDto> licoes;

  factory ModuloTrilhaDto.fromJson(Map<String, dynamic> json) =>
      ModuloTrilhaDto(
        id: _nullableInt(json['id']),
        titulo: _string(json, 'titulo'),
        ordem: _int(json, 'ordem'),
        licoes: _maps(json, 'licoes').map(LicaoTrilhaDto.fromJson).toList(),
      );

  Map<String, dynamic> toJson() => {
    'titulo': titulo,
    'ordem': ordem,
    'licoes': licoes.map((item) => item.toJson()).toList(growable: false),
  };
}

class LicaoTrilhaDto {
  const LicaoTrilhaDto({
    required this.titulo,
    required this.ordem,
    required this.desafios,
    this.id,
    this.resumo,
  });

  final int? id;
  final String titulo;
  final String? resumo;
  final int ordem;
  final List<DesafioTrilhaDto> desafios;

  factory LicaoTrilhaDto.fromJson(Map<String, dynamic> json) => LicaoTrilhaDto(
    id: _nullableInt(json['id']),
    titulo: _string(json, 'titulo'),
    resumo: json['resumo'] as String?,
    ordem: _int(json, 'ordem'),
    desafios: _maps(json, 'desafios').map(DesafioTrilhaDto.fromJson).toList(),
  );

  Map<String, dynamic> toJson() => {
    'titulo': titulo,
    'resumo': resumo,
    'ordem': ordem,
    'desafios': desafios.map((item) => item.toJson()).toList(growable: false),
  };
}

class DesafioTrilhaDto {
  const DesafioTrilhaDto({
    required this.enunciado,
    required this.dificuldade,
    required this.explicacao,
    required this.ordem,
    required this.opcoes,
    this.id,
  });

  final int? id;
  final String enunciado;
  final String dificuldade;
  final String explicacao;
  final int ordem;
  final List<OpcaoTrilhaDto> opcoes;

  factory DesafioTrilhaDto.fromJson(Map<String, dynamic> json) =>
      DesafioTrilhaDto(
        id: _nullableInt(json['id']),
        enunciado: _string(json, 'enunciado'),
        dificuldade: _string(json, 'dificuldade'),
        explicacao: _string(json, 'explicacao'),
        ordem: _int(json, 'ordem'),
        opcoes: _maps(json, 'opcoes').map(OpcaoTrilhaDto.fromJson).toList(),
      );

  Map<String, dynamic> toJson() => {
    'enunciado': enunciado,
    'tipo': 'MULTIPLA_ESCOLHA',
    'dificuldade': dificuldade,
    'explicacao': explicacao,
    'ordem': ordem,
    'opcoes': opcoes.map((item) => item.toJson()).toList(growable: false),
  };
}

class OpcaoTrilhaDto {
  const OpcaoTrilhaDto({
    required this.texto,
    required this.ordem,
    required this.correta,
    this.id,
  });

  final int? id;
  final String texto;
  final int ordem;
  final bool correta;

  factory OpcaoTrilhaDto.fromJson(Map<String, dynamic> json) => OpcaoTrilhaDto(
    id: _nullableInt(json['id']),
    texto: _string(json, 'texto'),
    ordem: _int(json, 'ordem'),
    correta: json['correta'] == true,
  );

  Map<String, dynamic> toJson() => {
    'texto': texto,
    'ordem': ordem,
    'correta': correta,
  };
}

class PublicacaoResponse {
  const PublicacaoResponse({
    required this.versaoId,
    required this.numeroVersao,
  });
  final int versaoId;
  final int numeroVersao;

  factory PublicacaoResponse.fromJson(Map<String, dynamic> json) =>
      PublicacaoResponse(
        versaoId: _int(json, 'versaoId'),
        numeroVersao: _int(json, 'numeroVersao'),
      );
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

DateTime _date(Map<String, dynamic> json, String key) {
  final value = json[key];
  final parsed = value is String ? DateTime.tryParse(value) : null;
  if (parsed != null) return parsed;
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
