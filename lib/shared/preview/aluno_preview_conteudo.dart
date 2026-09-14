import 'package:unipar_trilha_app/modules/aprendizagem/dto/sessao_response.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/models/caminho_trilha.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/models/desafio_pratica.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/service/aprendizagem_service.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/dto/catalogo_aluno_response.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/models/trilha_resumo.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/service/catalogo_aluno_service.dart';
import 'package:unipar_trilha_app/modules/home/models/aluno_conteudo.dart';
import 'package:unipar_trilha_app/modules/home/models/home_aluno.dart';
import 'package:unipar_trilha_app/modules/home/page/aluno_navegacao_page.dart';
import 'package:unipar_trilha_app/modules/perfil/models/visao_geral_aluno.dart';
import 'package:unipar_trilha_app/shared/models/aluno_resumo.dart';
import 'package:unipar_trilha_app/shared/preview/aluno_preview_api.dart';

/// Conteúdo de exemplo com os textos dos wireframes 1–7.
///
/// - Catálogo e prática passam pelos services reais sobre [AlunoPreviewApi],
///   que devolve o JSON dos contratos.
/// - Aluno, meta diária, próxima lição, lições do caminho e visão geral ainda
///   não têm endpoint e são entregues prontos em [conteudo].
///
/// Usado somente por `main_preview.dart` e pelos testes. Não é um service e
/// não pode ser referenciado por `main.dart`.
abstract final class AlunoPreviewConteudo {
  static const aluno = AlunoResumo(
    nome: 'Maria Joaquina',
    ra: '60020223',
    sequenciaDias: 3,
  );

  /// Trilhas convertidas do JSON inicial do catálogo simulado.
  static final List<TrilhaResumo> trilhas = [
    for (final (indice, item) in CatalogoAlunoResponse.fromJson(
      AlunoPreviewApi().catalogo(),
    ).distribuicoes.indexed)
      TrilhaResumo.fromDistribuicao(item, indice: indice),
  ];

  static TrilhaResumo get frontend => trilhas.last;

  /// Primeira questão da trilha Frontend, convertida do JSON da sessão.
  static final DesafioPratica desafio = () {
    final sessao = SessaoResponse.fromJson(AlunoPreviewApi().sessao(4));
    return DesafioPratica.fromSessao(sessao.desafioAtual!, sessao.progresso);
  }();

  /// Navegação completa ligada à API simulada.
  static AlunoNavegacaoPage navegacao({
    Duration atraso = const Duration(milliseconds: 600),
  }) {
    final dio = AlunoPreviewApi.dio(atraso: atraso);
    return AlunoNavegacaoPage(
      conteudo: conteudo(),
      catalogoService: CatalogoAlunoService(dio: dio),
      aprendizagemService: AprendizagemService(dio: dio),
    );
  }

  /// Sete lições, como na tela 2, com o baú ao lado da quarta.
  static CaminhoTrilha caminho(TrilhaResumo trilha) {
    const titulos = [
      'Primeiros passos',
      'Conceitos básicos',
      'Prática guiada',
      'Revisão parcial',
      'Aprofundamento',
      'Projeto',
      'Avaliação final',
    ];
    final concluidas = (trilha.progresso * titulos.length).floor();
    return CaminhoTrilha(
      trilha: trilha,
      licoes: [
        for (var i = 0; i < titulos.length; i++)
          LicaoCaminho(
            id: trilha.id * 10 + i,
            titulo: titulos[i],
            recompensa: i == 3,
            status: i < concluidas
                ? StatusLicao.concluida
                : i == concluidas
                ? StatusLicao.atual
                : StatusLicao.bloqueada,
          ),
      ],
    );
  }

  /// Correções locais com código e dica, como nos wireframes 5 e 6.
  ///
  /// Usado pelos testes de `PraticaPage`; o contrato atual da API ainda não
  /// envia `codigo` nem `dica`.
  static Future<CorrecaoPratica> responder(
    DesafioPratica desafio,
    OpcaoPratica opcao, {
    Duration atraso = const Duration(milliseconds: 900),
  }) async {
    await Future<void>.delayed(atraso);
    final texto = opcao.texto;
    if (texto == '<p>') {
      return const CorrecaoPratica(
        correta: true,
        explicacao: 'A tag <p> em HTML, cria um parágrafo.',
        codigo: '<p>Meu parágrafo!</p>',
      );
    }
    return CorrecaoPratica(
      correta: false,
      explicacao: switch (texto) {
        '<th>' => 'A tag <th> cria uma célula de cabeçalho de tabela.',
        '<td>' => 'A tag <td> cria uma célula de dados de tabela.',
        _ => 'A tag <h1> cria um título, não um parágrafo.',
      },
      codigo: switch (texto) {
        '<th>' => '<th>Nome</th>',
        '<td>' => '<td>Maria</td>',
        _ => '<h1>Meu título</h1>',
      },
      dica: 'pense na inicial de parágrafo.',
    );
  }

  static const visaoGeral = VisaoGeralAluno(
    aluno: aluno,
    pontos: 115,
    xp: 16860,
    turma: '2º série',
    professores: ['Jaime William Dias'],
    ranking: 'Diamante',
    // Ordem por coluna: Spring e JavaScript na 1ª, XAMPP e Hibernate na 2ª.
    cursos: [
      CursoResumo(nome: 'Spring', quantidade: 2, icone: IconeCurso.spring),
      CursoResumo(
        nome: 'JavaScript',
        quantidade: 4,
        icone: IconeCurso.javascript,
      ),
      CursoResumo(nome: 'XAMPP', quantidade: 1, icone: IconeCurso.xampp),
      CursoResumo(
        nome: 'Hibernate',
        quantidade: 3,
        icone: IconeCurso.hibernate,
      ),
    ],
  );

  static AlunoConteudo conteudo() {
    return AlunoConteudo(
      aluno: aluno,
      metaDiaria: const MetaDiaria(xpRestante: 20, progresso: 0.8),
      proximaLicao: ProximaLicao(
        trilha: frontend,
        titulo: 'Preparando o ambiente',
        mensagemMascote: 'Antes da ação,\na preparação.',
        recompensa: 1,
      ),
      caminhoDe: caminho,
      visaoGeral: visaoGeral,
    );
  }
}
