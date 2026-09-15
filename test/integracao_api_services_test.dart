import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipar_trilha_app/modules/acompanhamento/service/acompanhamento_service.dart';
import 'package:unipar_trilha_app/modules/distribuicao/dto/distribuicao_dto.dart';
import 'package:unipar_trilha_app/modules/distribuicao/service/distribuicao_service.dart';
import 'package:unipar_trilha_app/modules/home/service/professor_contexto_service.dart';
import 'package:unipar_trilha_app/modules/login/dto/perfil_usuario.dart';
import 'package:unipar_trilha_app/modules/trilha/dto/trilha_dto.dart';
import 'package:unipar_trilha_app/modules/trilha/service/trilha_service.dart';
import 'package:unipar_trilha_app/modules/usuarios/dto/usuario_create_request.dart';
import 'package:unipar_trilha_app/modules/usuarios/service/usuario_service.dart';

import 'support/fake_http_client_adapter.dart';

void main() {
  Dio dio(FakeResponseHandler handler) {
    final value = Dio(BaseOptions(baseUrl: 'http://teste'));
    value.httpClientAdapter = FakeHttpClientAdapter(handler);
    return value;
  }

  test('services do professor usam os contratos reais', () async {
    final client = dio((request) {
      if (request.path == '/professor/contexto') {
        return jsonResponse('''{
          "professorId":2,"professorNome":"Professor",
          "turmas":[{"turmaId":1,"turmaNome":"Piloto","periodo":"2026/2",
          "disciplinaId":3,"disciplinaNome":"Algoritmos","disciplinaCodigo":"ALG"}]
        }''');
      }
      if (request.path == '/trilhas') {
        return jsonResponse('''[{
          "id":4,"titulo":"Lógica","descricao":"Base","status":"RASCUNHO",
          "disciplinaId":3,"disciplinaNome":"Algoritmos",
          "atualizadoEm":"2026-09-14T10:00:00",
          "publicacoes":[{"versaoId":8,"numeroVersao":2,
          "publicadaEm":"2026-09-14T11:00:00"}]
        }]''');
      }
      if (request.path == '/professor/turmas/1/indicadores') {
        return jsonResponse('''{
          "turmaId":1,"turmaNome":"Piloto","matriculados":4,"iniciaram":3,
          "concluiram":2,"percentualConclusao":50,"acertos":8,"erros":2,
          "acuracia":80,"desafiosComMaisErros":[]
        }''');
      }
      throw StateError('Rota inesperada: ${request.path}');
    });

    final contexto = await ProfessorContextoService(dio: client).obter();
    final trilhas = await TrilhaService(dio: client).listar();
    final indicadores = await AcompanhamentoService(dio: client).obter(1);

    expect(contexto.turmas.single.disciplinaId, 3);
    expect(trilhas.single.publicacoes.single.numeroVersao, 2);
    expect(indicadores.acuracia, 80);
  });

  test('trilha salva árvore e publica sem repetir POST', () async {
    final requests = <RequestOptions>[];
    final client = dio((request) {
      requests.add(request);
      if (request.path.endsWith('/publicacoes')) {
        return jsonResponse(
          '{"trilhaId":4,"versaoId":8,"numeroVersao":1,'
          '"publicadaEm":"2026-09-14T11:00:00"}',
          statusCode: 201,
        );
      }
      return jsonResponse('''{
        "id":4,"titulo":"Lógica","descricao":null,"status":"RASCUNHO",
        "disciplinaId":3,"disciplinaNome":"Algoritmos","professorId":2,
        "modulos":[],"criadoEm":"2026-09-14T10:00:00",
        "atualizadoEm":"2026-09-14T10:00:00"
      }''');
    });
    final service = TrilhaService(dio: client);
    final criada = await service.criar(
      const TrilhaCreateRequest(titulo: 'Lógica', disciplinaId: 3),
    );
    await service.atualizar(
      criada.id,
      const TrilhaConteudoRequest(
        titulo: 'Lógica',
        disciplinaId: 3,
        modulos: [
          ModuloTrilhaDto(
            titulo: 'Base',
            ordem: 1,
            licoes: [
              LicaoTrilhaDto(
                titulo: 'If',
                ordem: 1,
                desafios: [
                  DesafioTrilhaDto(
                    enunciado: 'Verdadeiro?',
                    dificuldade: 'FACIL',
                    explicacao: 'Sim.',
                    ordem: 1,
                    opcoes: [
                      OpcaoTrilhaDto(texto: 'Sim', ordem: 1, correta: true),
                      OpcaoTrilhaDto(texto: 'Não', ordem: 2, correta: false),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
    final publicacao = await service.publicar(criada.id);

    expect(publicacao.versaoId, 8);
    expect(requests.map((item) => item.method), ['POST', 'PUT', 'POST']);
    expect((requests[1].data as Map<String, dynamic>)['modulos'], isNotEmpty);
  });

  test(
    'distribuição e usuários enviam os dados definidos pela interface',
    () async {
      final requests = <RequestOptions>[];
      final client = dio((request) {
        requests.add(request);
        if (request.path == '/usuarios' && request.method == 'GET') {
          return jsonResponse(
            '[{"id":5,"login":"aluno2","nome":"Aluno 2",'
            '"perfil":"ALUNO","ativo":true}]',
          );
        }
        if (request.path == '/usuarios') {
          return jsonResponse(
            '{"id":6,"login":"novo","nome":"Novo",'
            '"perfil":"PROFESSOR","ativo":true}',
            statusCode: 201,
          );
        }
        if (request.path == '/distribuicoes' && request.method == 'GET') {
          return jsonResponse('[]');
        }
        return jsonResponse('''{
        "id":9,"versaoId":8,"numeroVersao":1,"trilhaTitulo":"Lógica",
        "turmaId":1,"turmaNome":"Piloto","disponivelDe":"2026-09-14T08:00:00",
        "disponivelAte":null
      }''', statusCode: 201);
      });

      final usuarios = UsuarioService(dio: client);
      expect(
        (await usuarios.listar(PerfilUsuario.aluno)).single.login,
        'aluno2',
      );
      await usuarios.criar(
        const UsuarioCreateRequest(
          login: 'novo',
          nome: 'Novo',
          senha: 'segredo',
          perfil: PerfilUsuario.professor,
        ),
      );
      final distribuicoes = DistribuicaoService(dio: client);
      await distribuicoes.listar(1);
      await distribuicoes.criar(
        DistribuicaoRequest(
          versaoId: 8,
          turmaId: 1,
          disponivelDe: DateTime(2026, 9, 14, 8),
        ),
      );

      expect(requests[0].queryParameters['perfil'], 'ALUNO');
      expect((requests[1].data as Map)['senha'], 'segredo');
      expect(requests[2].queryParameters['turmaId'], 1);
      expect((requests[3].data as Map)['versaoId'], 8);
    },
  );
}
