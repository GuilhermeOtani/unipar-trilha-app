class ProfessorContextoResponse {
  const ProfessorContextoResponse({
    required this.professorId,
    required this.professorNome,
    required this.turmas,
  });

  final int professorId;
  final String professorNome;
  final List<TurmaProfessorResponse> turmas;

  factory ProfessorContextoResponse.fromJson(Map<String, dynamic> json) {
    return ProfessorContextoResponse(
      professorId: _int(json, 'professorId'),
      professorNome: _string(json, 'professorNome'),
      turmas: _maps(
        json,
        'turmas',
      ).map(TurmaProfessorResponse.fromJson).toList(growable: false),
    );
  }
}

class TurmaProfessorResponse {
  const TurmaProfessorResponse({
    required this.turmaId,
    required this.turmaNome,
    required this.periodo,
    required this.disciplinaId,
    required this.disciplinaNome,
    required this.disciplinaCodigo,
  });

  final int turmaId;
  final String turmaNome;
  final String periodo;
  final int disciplinaId;
  final String disciplinaNome;
  final String disciplinaCodigo;

  factory TurmaProfessorResponse.fromJson(Map<String, dynamic> json) {
    return TurmaProfessorResponse(
      turmaId: _int(json, 'turmaId'),
      turmaNome: _string(json, 'turmaNome'),
      periodo: _string(json, 'periodo'),
      disciplinaId: _int(json, 'disciplinaId'),
      disciplinaNome: _string(json, 'disciplinaNome'),
      disciplinaCodigo: _string(json, 'disciplinaCodigo'),
    );
  }
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
