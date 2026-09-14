import 'package:flutter_test/flutter_test.dart';
import 'package:unipar_trilha_app/core/widgets/trail_card.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/dto/resposta_aluno_request.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/dto/resposta_aluno_response.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/dto/sessao_response.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/models/desafio_pratica.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/dto/catalogo_aluno_response.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/models/trilha_resumo.dart';

void main() {
  const desafioJson = {
    'id': 7,
    'enunciado': 'Qual tag HTML cria um parágrafo?',
    'tipo': 'MULTIPLA_ESCOLHA',
    'dificuldade': 'FACIL',
    'opcoes': [
      {'id': 71, 'texto': '<h1>'},
      {'id': 74, 'texto': '<p>'},
    ],
  };

  test('interpreta catálogo real e converte para o card', () {
    final catalogo = CatalogoAlunoResponse.fromJson({
      'distribuicoes': [
        {
          'distribuicaoId': 9,
          'trilhaTitulo': 'Fundamentos da lógica',
          'disciplinaNome': 'Algoritmos',
          'numeroVersao': 1,
          'totalDesafios': 3,
          'percentualProgresso': 33,
          'concluida': false,
        },
      ],
    });

    final trilha = TrilhaResumo.fromDistribuicao(
      catalogo.distribuicoes.single,
      indice: 1,
    );
    expect(trilha.id, 9);
    expect(trilha.disciplina, 'Algoritmos');
    expect(trilha.progresso, closeTo(0.33, 0.001));
    expect(trilha.status, TrailStatus.inProgress);
    expect(trilha.tom, TrailCardTone.purple);
  });

  test('catálogo sem campo obrigatório é rejeitado', () {
    expect(
      () => CatalogoAlunoResponse.fromJson({
        'distribuicoes': [
          {'distribuicaoId': 1},
        ],
      }),
      throwsFormatException,
    );
  });

  test('sessão converte desafio sem campo correta', () {
    final sessao = SessaoResponse.fromJson({
      'sessaoId': 5,
      'distribuicaoId': 9,
      'trilhaTitulo': 'Fundamentos da lógica',
      'numeroVersao': 1,
      'licaoTitulo': 'If e else',
      'status': 'EM_ANDAMENTO',
      'progresso': {
        'respondidos': 1,
        'total': 3,
        'percentual': 33,
        'concluida': false,
      },
      'desafioAtual': desafioJson,
    });

    final desafio = DesafioPratica.fromSessao(
      sessao.desafioAtual!,
      sessao.progresso,
    );
    expect(sessao.status, StatusSessao.emAndamento);
    expect(desafio.numero, 2);
    expect(desafio.total, 3);
    expect(desafio.opcoes.map((o) => o.texto), ['<h1>', '<p>']);
  });

  test('sessão concluída não tem desafio atual', () {
    final sessao = SessaoResponse.fromJson({
      'sessaoId': 5,
      'distribuicaoId': 9,
      'trilhaTitulo': 'Fundamentos da lógica',
      'numeroVersao': 1,
      'licaoTitulo': null,
      'status': 'CONCLUIDA',
      'progresso': {
        'respondidos': 3,
        'total': 3,
        'percentual': 100,
        'concluida': true,
      },
      'desafioAtual': null,
    });
    expect(sessao.desafioAtual, isNull);
    expect(sessao.progresso.concluida, isTrue);
  });

  test('resposta envia somente desafioId e opcaoId', () {
    expect(const RespostaAlunoRequest(desafioId: 7, opcaoId: 74).toJson(), {
      'desafioId': 7,
      'opcaoId': 74,
    });
  });

  test('correção leva próximo desafio e conclusão', () {
    final correcao = CorrecaoPratica.fromResposta(
      RespostaAlunoResponse.fromJson({
        'correta': true,
        'feedback': 'Correto. A tag <p> cria um parágrafo.',
        'progresso': {
          'respondidos': 1,
          'total': 3,
          'percentual': 33,
          'concluida': false,
        },
        'proximoDesafio': desafioJson,
      }),
    );
    expect(correcao.correta, isTrue);
    expect(correcao.explicacao, startsWith('Correto.'));
    expect(correcao.proximoDesafio?.id, 7);
    expect(correcao.concluida, isFalse);
    expect(correcao.codigo, isNull);
  });
}
