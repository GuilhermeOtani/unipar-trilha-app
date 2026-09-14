import 'package:unipar_trilha_app/modules/aprendizagem/dto/sessao_response.dart';

/// Resposta de `POST /aluno/sessoes/{id}/respostas`.
class RespostaAlunoResponse {
  const RespostaAlunoResponse({
    required this.correta,
    required this.feedback,
    required this.progresso,
    this.proximoDesafio,
  });

  final bool correta;
  final String feedback;
  final ProgressoResponse progresso;

  /// Em erro, é o mesmo desafio; em acerto, o seguinte; nulo ao concluir.
  final DesafioAlunoResponse? proximoDesafio;

  factory RespostaAlunoResponse.fromJson(Map<String, dynamic> json) {
    final correta = json['correta'];
    final feedback = json['feedback'];
    final progresso = json['progresso'];
    if (correta is! bool || feedback is! String || progresso is! Map) {
      throw const FormatException('Resposta da correção inválida.');
    }
    return RespostaAlunoResponse(
      correta: correta,
      feedback: feedback,
      progresso: ProgressoResponse.fromJson(
        Map<String, dynamic>.from(progresso),
      ),
      proximoDesafio: DesafioAlunoResponse.fromNullableJson(
        json['proximoDesafio'],
      ),
    );
  }
}
