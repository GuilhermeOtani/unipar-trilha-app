/// Corpo de `POST /aluno/sessoes/{id}/respostas`.
class RespostaAlunoRequest {
  const RespostaAlunoRequest({required this.desafioId, required this.opcaoId});

  final int desafioId;
  final int opcaoId;

  Map<String, dynamic> toJson() => {'desafioId': desafioId, 'opcaoId': opcaoId};
}
