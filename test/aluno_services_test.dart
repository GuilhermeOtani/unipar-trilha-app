import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipar_trilha_app/core/api_error.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/dto/resposta_aluno_request.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/service/aprendizagem_service.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/service/catalogo_aluno_service.dart';

import 'support/fake_http_client_adapter.dart';

void main() {
  const sessaoJson = '''{
    "sessaoId": 5,
    "distribuicaoId": 9,
    "trilhaTitulo": "Fundamentos da lógica",
    "numeroVersao": 1,
    "licaoTitulo": "If e else",
    "status": "EM_ANDAMENTO",
    "progresso": {"respondidos": 0, "total": 3, "percentual": 0, "concluida": false},
    "desafioAtual": {
      "id": 7,
      "enunciado": "Qual saída será exibida?",
      "tipo": "MULTIPLA_ESCOLHA",
      "opcoes": [{"id": 3, "texto": "A"}]
    }
  }''';

  (Dio, FakeHttpClientAdapter) criar(FakeResponseHandler handler) {
    final dio = Dio(BaseOptions(baseUrl: 'http://teste'));
    final adapter = FakeHttpClientAdapter(handler);
    dio.httpClientAdapter = adapter;
    return (dio, adapter);
  }

  test('catálogo consulta GET /aluno/distribuicoes', () async {
    final (dio, adapter) = criar(
      (_) => jsonResponse('''{"distribuicoes": [{
        "distribuicaoId": 9, "trilhaTitulo": "Lógica", "disciplinaNome": "Algoritmos",
        "numeroVersao": 1, "totalDesafios": 3, "percentualProgresso": 0, "concluida": false
      }]}'''),
    );

    final catalogo = await CatalogoAlunoService(dio: dio).listar();

    expect(adapter.requests.single.method, 'GET');
    expect(adapter.requests.single.path, '/aluno/distribuicoes');
    expect(catalogo.distribuicoes.single.trilhaTitulo, 'Lógica');
  });

  test('catálogo converte Problem Details em ApiError', () async {
    final (dio, _) = criar(
      (_) => jsonResponse(
        '{"status":403,"detail":"Acesso negado."}',
        statusCode: 403,
      ),
    );

    await expectLater(
      CatalogoAlunoService(dio: dio).listar(),
      throwsA(
        isA<ApiError>()
            .having((e) => e.statusCode, 'statusCode', 403)
            .having((e) => e.message, 'message', 'Acesso negado.'),
      ),
    );
  });

  test('inicia sessão pela distribuição', () async {
    final (dio, adapter) = criar((_) => jsonResponse(sessaoJson));

    final sessao = await AprendizagemService(dio: dio).iniciarOuRetomar(9);

    expect(adapter.requests.single.method, 'POST');
    expect(adapter.requests.single.path, '/aluno/distribuicoes/9/sessoes');
    expect(sessao.desafioAtual?.id, 7);
  });

  test('responde com desafioId e opcaoId na sessão', () async {
    final (dio, adapter) = criar(
      (_) => jsonResponse('''{
        "correta": false,
        "feedback": "Ainda não. A condição é verdadeira.",
        "progresso": {"respondidos": 0, "total": 3, "percentual": 0, "concluida": false},
        "proximoDesafio": {"id": 7, "enunciado": "Qual saída será exibida?", "opcoes": [{"id": 3, "texto": "A"}]}
      }'''),
    );

    final resposta = await AprendizagemService(
      dio: dio,
    ).responder(5, const RespostaAlunoRequest(desafioId: 7, opcaoId: 3));

    expect(adapter.requests.single.path, '/aluno/sessoes/5/respostas');
    expect(adapter.requests.single.data, {'desafioId': 7, 'opcaoId': 3});
    expect(resposta.correta, isFalse);
    expect(resposta.proximoDesafio?.id, 7);
  });

  test('JSON fora do contrato vira ApiError', () async {
    final (dio, _) = criar((_) => jsonResponse('{"sessaoId": 5}'));

    await expectLater(
      AprendizagemService(dio: dio).buscarSessao(5),
      throwsA(isA<ApiError>()),
    );
  });
}
