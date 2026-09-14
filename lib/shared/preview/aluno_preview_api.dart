import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:unipar_trilha_app/core/constants_api.dart';

/// API simulada da pré-visualização (o `MockService` do plano).
///
/// Responde às rotas do aluno com **o mesmo JSON do backend**
/// (`CatalogoAlunoResponse`, `SessaoResponse`, `RespostaAlunoResponse`), para
/// que a pré-visualização passe pelos services e DTOs reais. Guarda o avanço
/// de cada sessão em memória.
///
/// Uso restrito a `main_preview.dart` e aos testes; `main.dart` não o
/// referencia.
class AlunoPreviewApi implements HttpClientAdapter {
  AlunoPreviewApi({this.atraso = const Duration(milliseconds: 600)});

  /// Tempo simulado de rede, para exibir os estados de carregamento.
  final Duration atraso;

  /// Dio da pré-visualização, pronto para os services.
  static Dio dio({Duration atraso = const Duration(milliseconds: 600)}) {
    return Dio(BaseOptions(baseUrl: 'http://preview.local'))
      ..httpClientAdapter = AlunoPreviewApi(atraso: atraso);
  }

  static const _distribuicoes = [
    (1, 'Algoritmos e Lógica', 'Lógica de Programação'),
    (2, 'Orientação a Objetos', 'Programação Orientada a Objetos'),
    (3, 'XAMPP e Tomcat', 'Servidores Web'),
    (4, 'Frontend - Básico', 'Desenvolvimento Web'),
  ];

  /// (enunciado, opções, índice da correta, explicação)
  static const _desafios = [
    (
      'Qual tag HTML cria um parágrafo?',
      ['<h1>', '<th>', '<td>', '<p>'],
      3,
      'A tag <p> em HTML, cria um parágrafo.',
    ),
    (
      'Qual tag HTML cria um link?',
      ['<link>', '<a>', '<href>', '<nav>'],
      1,
      'A tag <a> cria um link com o atributo href.',
    ),
    (
      'Qual tag HTML exibe uma imagem?',
      ['<img>', '<pic>', '<figure>', '<src>'],
      0,
      'A tag <img> exibe uma imagem a partir do atributo src.',
    ),
    (
      'Qual tag HTML cria uma lista não ordenada?',
      ['<ol>', '<li>', '<ul>', '<list>'],
      2,
      'A tag <ul> cria uma lista não ordenada; cada item usa <li>.',
    ),
    (
      'Qual tag HTML define o título da aba?',
      ['<head>', '<title>', '<h1>', '<meta>'],
      1,
      'A tag <title>, dentro de <head>, define o título da aba.',
    ),
  ];

  /// Desafios acertados por distribuição (Algoritmos começa em 40%).
  final Map<int, int> _acertos = {1: 2};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (atraso > Duration.zero) await Future<void>.delayed(atraso);
    final path = Uri.parse(options.path).path;
    final metodo = options.method.toUpperCase();

    if (metodo == 'GET' && path == ConstantsApi.alunoDistribuicoes) {
      return _json(catalogo());
    }
    final iniciar = RegExp(r'^/aluno/distribuicoes/(\d+)/sessoes$');
    final sessao = RegExp(r'^/aluno/sessoes/(\d+)$');
    final respostas = RegExp(r'^/aluno/sessoes/(\d+)/respostas$');

    if (metodo == 'POST' && iniciar.hasMatch(path)) {
      final id = int.parse(iniciar.firstMatch(path)!.group(1)!);
      if (!_existe(id)) return _naoEncontrado('Distribuição não encontrada.');
      return _json(this.sessao(id));
    }
    if (metodo == 'GET' && sessao.hasMatch(path)) {
      final id = int.parse(sessao.firstMatch(path)!.group(1)!) ~/ 100;
      if (!_existe(id)) return _naoEncontrado('Sessão não encontrada.');
      return _json(this.sessao(id));
    }
    if (metodo == 'POST' && respostas.hasMatch(path)) {
      final id = int.parse(respostas.firstMatch(path)!.group(1)!) ~/ 100;
      if (!_existe(id)) return _naoEncontrado('Sessão não encontrada.');
      final corpo = options.data is Map ? options.data as Map : const {};
      return _json(_responder(id, corpo['opcaoId']));
    }
    return _naoEncontrado('Rota não simulada: $metodo $path');
  }

  @override
  void close({bool force = false}) {}

  /// JSON de `GET /aluno/distribuicoes`.
  Map<String, dynamic> catalogo() => {
    'distribuicoes': [
      for (final (id, titulo, disciplina) in _distribuicoes)
        {
          'distribuicaoId': id,
          'trilhaTitulo': titulo,
          'disciplinaNome': disciplina,
          'numeroVersao': 1,
          'totalDesafios': _desafios.length,
          'percentualProgresso': _progresso(id)['percentual'],
          'concluida': _progresso(id)['concluida'],
        },
    ],
  };

  /// JSON de `SessaoResponse` da distribuição [distribuicaoId].
  Map<String, dynamic> sessao(int distribuicaoId) {
    final (_, titulo, _) = _distribuicoes.firstWhere(
      (item) => item.$1 == distribuicaoId,
    );
    final indice = _acertos[distribuicaoId] ?? 0;
    final concluida = indice >= _desafios.length;
    return {
      'sessaoId': distribuicaoId * 100,
      'distribuicaoId': distribuicaoId,
      'trilhaTitulo': titulo,
      'numeroVersao': 1,
      'licaoTitulo': concluida ? null : 'Preparando o ambiente',
      'status': concluida ? 'CONCLUIDA' : 'EM_ANDAMENTO',
      'progresso': _progresso(distribuicaoId),
      'desafioAtual': concluida ? null : _desafio(indice),
    };
  }

  Map<String, dynamic> _responder(int distribuicaoId, Object? opcaoId) {
    final indice = _acertos[distribuicaoId] ?? 0;
    final (_, _, correta, explicacao) = _desafios[indice];
    final acertou = opcaoId == _opcaoId(indice, correta);
    if (acertou) _acertos[distribuicaoId] = indice + 1;
    final proximo = acertou ? indice + 1 : indice;
    return {
      'correta': acertou,
      'feedback': acertou ? explicacao : 'Ainda não. $explicacao',
      'progresso': _progresso(distribuicaoId),
      'proximoDesafio': proximo < _desafios.length ? _desafio(proximo) : null,
    };
  }

  Map<String, dynamic> _progresso(int distribuicaoId) {
    final respondidos = _acertos[distribuicaoId] ?? 0;
    final total = _desafios.length;
    return {
      'respondidos': respondidos,
      'total': total,
      'percentual': (respondidos * 100 / total).round(),
      'concluida': respondidos >= total,
    };
  }

  Map<String, dynamic> _desafio(int indice) {
    final (enunciado, opcoes, _, _) = _desafios[indice];
    return {
      'id': indice + 1,
      'enunciado': enunciado,
      'tipo': 'MULTIPLA_ESCOLHA',
      'dificuldade': 'FACIL',
      'opcoes': [
        for (var i = 0; i < opcoes.length; i++)
          {'id': _opcaoId(indice, i), 'texto': opcoes[i]},
      ],
    };
  }

  static int _opcaoId(int desafio, int opcao) => (desafio + 1) * 10 + opcao + 1;

  bool _existe(int id) => _distribuicoes.any((item) => item.$1 == id);

  static ResponseBody _json(Object body, {int statusCode = 200}) {
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  static ResponseBody _naoEncontrado(String detalhe) =>
      _json({'status': 404, 'detail': detalhe}, statusCode: 404);
}
