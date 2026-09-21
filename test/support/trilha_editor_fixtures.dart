import 'dart:async';
import 'package:unipar_trilha_app/core/api_error.dart';
import 'package:unipar_trilha_app/modules/home/dto/professor_contexto_response.dart';
import 'package:unipar_trilha_app/modules/trilha/dto/trilha_dto.dart';
import 'package:unipar_trilha_app/modules/trilha/service/trilha_service.dart';

const contextoEditor = ProfessorContextoResponse(
  professorId: 2,
  professorNome: 'Prof. Jaime',
  turmas: [
    TurmaProfessorResponse(
      turmaId: 1,
      turmaNome: 'Turma A',
      periodo: '2026/2',
      disciplinaId: 3,
      disciplinaNome: 'Algoritmos e Lógica de Programação',
      disciplinaCodigo: 'ALG',
    ),
    TurmaProfessorResponse(
      turmaId: 2,
      turmaNome: 'Turma B',
      periodo: '2026/2',
      disciplinaId: 7,
      disciplinaNome: 'Banco de Dados',
      disciplinaCodigo: 'BD',
    ),
    TurmaProfessorResponse(
      turmaId: 3,
      turmaNome: 'Turma C',
      periodo: '2026/2',
      disciplinaId: 3,
      disciplinaNome: 'Algoritmos e Lógica de Programação',
      disciplinaCodigo: 'ALG',
    ),
  ],
);

const desafioEditor = DesafioTrilhaDto(
  enunciado: 'Qual opção está correta?',
  dificuldade: 'MEDIA',
  explicacao: 'A primeira opção está correta.',
  ordem: 1,
  opcoes: [
    OpcaoTrilhaDto(texto: 'Correta', ordem: 1, correta: true),
    OpcaoTrilhaDto(texto: 'Incorreta', ordem: 2, correta: false),
  ],
);
const trilhaCompletaEditor = TrilhaResponse(
  id: 4,
  titulo: 'Trilha de testes',
  status: 'RASCUNHO',
  disciplinaId: 3,
  disciplinaNome: 'Algoritmos',
  modulos: [
    ModuloTrilhaDto(
      titulo: 'Módulo inicial',
      ordem: 1,
      licoes: [
        LicaoTrilhaDto(
          titulo: 'Primeira lição',
          resumo: 'Introdução',
          ordem: 1,
          desafios: [desafioEditor],
        ),
      ],
    ),
  ],
);

class FakeTrilhaEditorService implements TrilhaServiceContract {
  int criacoes = 0,
      atualizacoes = 0,
      publicacoes = 0,
      buscas = 0,
      listagens = 0;
  bool falharCriacao = false,
      falharCarga = false,
      falharSalvar = false,
      falharPublicar = false;
  Completer<TrilhaResponse>? criacaoPendente;
  Completer<TrilhaResponse>? salvamentoPendente;
  Completer<PublicacaoResponse>? publicacaoPendente;
  TrilhaCreateRequest? criacaoRecebida;
  TrilhaConteudoRequest? conteudoRecebido;
  TrilhaResponse armazenada = trilhaCompletaEditor;
  @override
  Future<TrilhaResponse> criar(TrilhaCreateRequest request) async {
    criacoes++;
    criacaoRecebida = request;
    if (falharCriacao) throw const ApiError(message: 'Falha ao criar');
    if (criacaoPendente != null) return criacaoPendente!.future;
    armazenada = TrilhaResponse(
      id: 4,
      titulo: request.titulo,
      descricao: request.descricao,
      status: 'RASCUNHO',
      disciplinaId: request.disciplinaId,
      disciplinaNome: 'Disciplina',
      modulos: [],
    );
    return armazenada;
  }

  @override
  Future<TrilhaResponse> buscar(int id) async {
    buscas++;
    if (falharCarga) throw const ApiError(message: 'Falha ao carregar');
    return armazenada;
  }

  @override
  Future<TrilhaResponse> atualizar(
    int id,
    TrilhaConteudoRequest request,
  ) async {
    atualizacoes++;
    conteudoRecebido = request;
    if (falharSalvar) throw const ApiError(message: 'Falha ao salvar');
    if (salvamentoPendente != null) return salvamentoPendente!.future;
    armazenada = TrilhaResponse(
      id: id,
      titulo: request.titulo,
      descricao: request.descricao,
      status: 'RASCUNHO',
      disciplinaId: request.disciplinaId,
      disciplinaNome: 'Disciplina',
      modulos: request.modulos,
    );
    return armazenada;
  }

  @override
  Future<PublicacaoResponse> publicar(int id) async {
    publicacoes++;
    if (falharPublicar) throw const ApiError(message: 'Falha ao publicar');
    return publicacaoPendente?.future ??
        const PublicacaoResponse(versaoId: 8, numeroVersao: 1);
  }

  @override
  Future<List<TrilhaProfessorResumoResponse>> listar() async {
    listagens++;
    return [
      TrilhaProfessorResumoResponse(
        id: 4,
        titulo: armazenada.titulo,
        status: 'RASCUNHO',
        disciplinaId: armazenada.disciplinaId,
        disciplinaNome: armazenada.disciplinaNome,
        atualizadoEm: DateTime(2026),
        publicacoes: const [],
      ),
    ];
  }
}
