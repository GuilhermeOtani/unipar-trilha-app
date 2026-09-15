class DistribuicaoRequest {
  const DistribuicaoRequest({
    required this.versaoId,
    required this.turmaId,
    required this.disponivelDe,
    this.disponivelAte,
  });

  final int versaoId;
  final int turmaId;
  final DateTime disponivelDe;
  final DateTime? disponivelAte;

  Map<String, dynamic> toJson() => {
    'versaoId': versaoId,
    'turmaId': turmaId,
    'disponivelDe': disponivelDe.toIso8601String(),
    'disponivelAte': disponivelAte?.toIso8601String(),
  };
}

class DistribuicaoResponse {
  const DistribuicaoResponse({
    required this.id,
    required this.versaoId,
    required this.numeroVersao,
    required this.trilhaTitulo,
    required this.turmaId,
    required this.turmaNome,
    required this.disponivelDe,
    this.disponivelAte,
  });

  final int id;
  final int versaoId;
  final int numeroVersao;
  final String trilhaTitulo;
  final int turmaId;
  final String turmaNome;
  final DateTime disponivelDe;
  final DateTime? disponivelAte;

  factory DistribuicaoResponse.fromJson(Map<String, dynamic> json) =>
      DistribuicaoResponse(
        id: _int(json, 'id'),
        versaoId: _int(json, 'versaoId'),
        numeroVersao: _int(json, 'numeroVersao'),
        trilhaTitulo: _string(json, 'trilhaTitulo'),
        turmaId: _int(json, 'turmaId'),
        turmaNome: _string(json, 'turmaNome'),
        disponivelDe: _date(json, 'disponivelDe'),
        disponivelAte: _nullableDate(json['disponivelAte']),
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

DateTime _date(Map<String, dynamic> json, String key) {
  final date = _nullableDate(json[key]);
  if (date != null) return date;
  throw FormatException("Campo '$key' inválido.");
}

DateTime? _nullableDate(Object? value) {
  if (value == null) return null;
  return value is String ? DateTime.tryParse(value) : null;
}
