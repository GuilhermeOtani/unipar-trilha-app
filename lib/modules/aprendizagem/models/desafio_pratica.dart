import 'package:unipar_trilha_app/modules/aprendizagem/dto/resposta_aluno_response.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/dto/sessao_response.dart';

/// Alternativa exibida ao aluno. Não possui o campo `correta`: a correção só
/// chega depois do envio (regra do plano de implementação).
class OpcaoPratica {
  const OpcaoPratica({required this.id, required this.texto});

  final int id;
  final String texto;
}

/// Questão de múltipla escolha das telas 4–6.
class DesafioPratica {
  const DesafioPratica({
    required this.id,
    required this.enunciado,
    required this.numero,
    required this.total,
    required this.opcoes,
  });

  /// Converte o desafio da sessão. [numero] é o próximo após os acertos.
  factory DesafioPratica.fromSessao(
    DesafioAlunoResponse desafio,
    ProgressoResponse progresso,
  ) {
    final total = progresso.total < 1 ? 1 : progresso.total;
    return DesafioPratica(
      id: desafio.id,
      enunciado: desafio.enunciado,
      numero: (progresso.respondidos + 1).clamp(1, total),
      total: total,
      opcoes: [
        for (final opcao in desafio.opcoes)
          OpcaoPratica(id: opcao.id, texto: opcao.texto),
      ],
    );
  }

  final int id;
  final String enunciado;

  /// Posição da questão, começando em 1.
  final int numero;
  final int total;
  final List<OpcaoPratica> opcoes;
}

/// Resultado da correção de uma resposta (telas 5 e 6).
class CorrecaoPratica {
  const CorrecaoPratica({
    required this.correta,
    required this.explicacao,
    this.codigo,
    this.dica,
    this.proximoDesafio,
    this.concluida = false,
  });

  /// Converte a resposta de `POST /aluno/sessoes/{id}/respostas`.
  ///
  /// O contrato atual não traz `codigo` nem `dica`; o `FeedbackCard` oculta
  /// esses blocos quando ausentes.
  factory CorrecaoPratica.fromResposta(RespostaAlunoResponse resposta) {
    final proximo = resposta.proximoDesafio;
    return CorrecaoPratica(
      correta: resposta.correta,
      explicacao: resposta.feedback,
      concluida: resposta.progresso.concluida,
      proximoDesafio: proximo == null
          ? null
          : DesafioPratica.fromSessao(proximo, resposta.progresso),
    );
  }

  final bool correta;
  final String explicacao;
  final String? codigo;
  final String? dica;

  /// Desafio seguinte, usado por "Continuar" após um acerto.
  final DesafioPratica? proximoDesafio;

  /// A sessão terminou com esta resposta.
  final bool concluida;
}

/// Envia a opção escolhida e devolve a correção.
typedef ResponderDesafio =
    Future<CorrecaoPratica> Function(
      DesafioPratica desafio,
      OpcaoPratica opcao,
    );
