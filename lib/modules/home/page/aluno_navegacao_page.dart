import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unipar_trilha_app/core/api_error.dart';
import 'package:unipar_trilha_app/core/auth_session.dart';
import 'package:unipar_trilha_app/core/theme/app_assets.dart';
import 'package:unipar_trilha_app/core/widgets/app_bottom_navigation.dart';
import 'package:unipar_trilha_app/core/widgets/app_empty_state.dart';
import 'package:unipar_trilha_app/core/widgets/app_page.dart';
import 'package:unipar_trilha_app/core/widgets/app_shell.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/models/caminho_trilha.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/page/caminho_trilha_api_page.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/page/caminho_trilha_page.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/page/sessao_pratica_page.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/service/aprendizagem_service.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/dto/catalogo_aluno_response.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/models/trilha_resumo.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/page/catalogo_aluno_page.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/service/catalogo_aluno_service.dart';
import 'package:unipar_trilha_app/modules/home/models/aluno_conteudo.dart';
import 'package:unipar_trilha_app/modules/home/models/home_aluno.dart';
import 'package:unipar_trilha_app/modules/home/page/aluno_home_page.dart';
import 'package:unipar_trilha_app/modules/login/dto/usuario_response.dart';
import 'package:unipar_trilha_app/modules/perfil/page/perfil_conta_page.dart';
import 'package:unipar_trilha_app/modules/perfil/page/perfil_page.dart';
import 'package:unipar_trilha_app/shared/models/aluno_resumo.dart';
import 'package:unipar_trilha_app/shared/widgets/aluno_header.dart';

enum AbaAluno { inicio, desempenho, trilhas, perfil }

/// Navegação autenticada do aluno. [conteudo] existe somente para o preview;
/// em produção a identidade e todos os dados acadêmicos vêm da API.
class AlunoNavegacaoPage extends StatefulWidget {
  const AlunoNavegacaoPage({
    super.key,
    this.conteudo,
    this.usuario,
    this.authSession,
    this.catalogoService,
    this.aprendizagemService,
  }) : assert(conteudo != null || (usuario != null && authSession != null));

  final AlunoConteudo? conteudo;
  final UsuarioResponse? usuario;
  final AuthSession? authSession;
  final CatalogoAlunoServiceContract? catalogoService;
  final AprendizagemServiceContract? aprendizagemService;

  static const destinos = [
    AppNavigationDestination(
      icon: AppIcons.home,
      label: 'Início',
      iconSize: 28,
    ),
    AppNavigationDestination(
      icon: AppIcons.ranking,
      label: 'Desempenho',
      iconSize: 33,
    ),
    AppNavigationDestination(
      icon: AppIcons.learningBook,
      label: 'Trilhas',
      iconSize: 34,
    ),
    AppNavigationDestination(
      icon: AppIcons.menu,
      label: 'Perfil',
      iconSize: 28,
    ),
  ];

  @override
  State<AlunoNavegacaoPage> createState() => _AlunoNavegacaoPageState();
}

class _AlunoNavegacaoPageState extends State<AlunoNavegacaoPage> {
  final _trilhasNavigator = GlobalKey<NavigatorState>();
  late final CatalogoAlunoServiceContract _catalogoService =
      widget.catalogoService ?? CatalogoAlunoService();
  late final AprendizagemServiceContract _aprendizagemService =
      widget.aprendizagemService ?? AprendizagemService();

  AbaAluno _aba = AbaAluno.inicio;
  List<TrilhaResumo> _trilhas = const [];
  bool _carregandoTrilhas = true;
  String? _erroTrilhas;
  ProximaLicao? _proximaLicao;
  int _carregamento = 0;

  AlunoConteudo? get _conteudo => widget.conteudo;
  AlunoResumo get _aluno {
    if (_conteudo != null) return _conteudo!.aluno;
    final usuario = widget.usuario!;
    return AlunoResumo(
      nome: usuario.nome,
      ra: usuario.login,
      rotuloIdentificacao: 'Login',
    );
  }

  NavigatorState get _pilhaTrilhas => _trilhasNavigator.currentState!;

  @override
  void initState() {
    super.initState();
    _carregarTrilhas();
  }

  Future<void> _carregarTrilhas() async {
    final operacao = ++_carregamento;
    setState(() {
      _carregandoTrilhas = true;
      _erroTrilhas = null;
    });
    try {
      final catalogo = await _catalogoService.listar();
      if (!mounted || operacao != _carregamento) return;
      final trilhas = [
        for (final (indice, item) in catalogo.distribuicoes.indexed)
          TrilhaResumo.fromDistribuicao(item, indice: indice),
      ];
      setState(() {
        _trilhas = trilhas;
        _proximaLicao = _conteudo?.proximaLicao;
      });
      if (_conteudo == null) {
        await _carregarProximaLicao(catalogo.distribuicoes, trilhas, operacao);
      }
    } on ApiError catch (error) {
      if (mounted && operacao == _carregamento) {
        setState(() => _erroTrilhas = error.message);
      }
    } finally {
      if (mounted && operacao == _carregamento) {
        setState(() => _carregandoTrilhas = false);
      }
    }
  }

  Future<void> _carregarProximaLicao(
    List<DistribuicaoAlunoResponse> distribuicoes,
    List<TrilhaResumo> trilhas,
    int operacao,
  ) async {
    for (final item in distribuicoes.where((item) => !item.concluida)) {
      try {
        final response = await _catalogoService.buscarCaminho(
          item.distribuicaoId,
        );
        if (!mounted || operacao != _carregamento) return;
        final trilha = trilhas.firstWhere(
          (value) => value.id == item.distribuicaoId,
        );
        final atual = CaminhoTrilha.fromResponse(response, trilha).licaoAtual;
        if (atual != null) {
          setState(() {
            _proximaLicao = ProximaLicao(
              trilha: trilha,
              titulo: atual.titulo,
              mensagemMascote: 'Sua próxima etapa está pronta.',
            );
          });
        }
        return;
      } on ApiError {
        // O catálogo permanece disponível mesmo sem o destaque da home.
      }
    }
  }

  void _selecionarAba(int index) {
    final aba = AbaAluno.values[index];
    if (aba == _aba && aba == AbaAluno.trilhas) {
      _pilhaTrilhas.popUntil((route) => route.isFirst);
      return;
    }
    setState(() => _aba = aba);
  }

  void _abrirTrilha(TrilhaResumo trilha, {bool abrirPratica = false}) {
    setState(() => _aba = AbaAluno.trilhas);
    _pilhaTrilhas
      ..popUntil((route) => route.isFirst)
      ..push(
        _conteudo == null ? _rotaCaminhoApi(trilha) : _rotaCaminho(trilha),
      );
    if (abrirPratica) _pilhaTrilhas.push(_rotaPratica(trilha));
  }

  void _comecarProximaLicao(ProximaLicao proxima) {
    _abrirTrilha(proxima.trilha, abrirPratica: true);
  }

  void _voltar() {
    if (_aba == AbaAluno.trilhas && _pilhaTrilhas.canPop()) {
      _pilhaTrilhas.pop();
    } else if (_aba != AbaAluno.inicio) {
      setState(() => _aba = AbaAluno.inicio);
    } else {
      SystemNavigator.pop();
    }
  }

  Route<void> _rotaCaminho(TrilhaResumo trilha) {
    return MaterialPageRoute(
      builder: (context) => CaminhoTrilhaPage(
        aluno: _aluno,
        caminho: _conteudo!.caminhoDe(trilha),
        onSelecionarLicao: (_) =>
            Navigator.of(context).push(_rotaPratica(trilha)),
      ),
    );
  }

  Route<void> _rotaCaminhoApi(TrilhaResumo trilha) {
    return MaterialPageRoute(
      builder: (_) => CaminhoTrilhaApiPage(
        aluno: _aluno,
        trilha: trilha,
        catalogoService: _catalogoService,
        aprendizagemService: _aprendizagemService,
        onAtualizado: _carregarTrilhas,
      ),
    );
  }

  Route<void> _rotaPratica(TrilhaResumo trilha) {
    final rota = MaterialPageRoute<void>(
      builder: (context) => SessaoPraticaPage(
        distribuicaoId: trilha.id,
        service: _aprendizagemService,
        onVoltar: () => Navigator.of(context).pop(),
      ),
    );
    rota.popped.then((_) {
      if (mounted) _carregarTrilhas();
    });
    return rota;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _voltar();
      },
      child: AppShell(
        bottomNavigation: AppBottomNavigation(
          destinations: AlunoNavegacaoPage.destinos,
          currentIndex: _aba.index,
          onSelected: _selecionarAba,
        ),
        body: IndexedStack(
          index: _aba.index,
          children: [
            AlunoHomePage(
              aluno: _aluno,
              trilhas: _trilhas,
              carregandoTrilhas: _carregandoTrilhas,
              erroTrilhas: _erroTrilhas,
              onTentarNovamente: _carregarTrilhas,
              metaDiaria: _conteudo?.metaDiaria,
              proximaLicao: _proximaLicao,
              onAbrirTrilha: _abrirTrilha,
              onVerTodas: () => _selecionarAba(AbaAluno.trilhas.index),
              onComecarProximaLicao: _comecarProximaLicao,
            ),
            AppPage(
              header: AlunoHeader(aluno: _aluno),
              body: const AppEmptyState(
                title: 'Desempenho',
                message: 'Em breve você poderá acompanhar seu desempenho aqui.',
              ),
            ),
            Navigator(
              key: _trilhasNavigator,
              onGenerateRoute: (_) => MaterialPageRoute(
                builder: (_) => CatalogoAlunoPage(
                  aluno: _aluno,
                  trilhas: _trilhas,
                  carregando: _carregandoTrilhas,
                  erro: _erroTrilhas,
                  onTentarNovamente: _carregarTrilhas,
                  onAbrirTrilha: _abrirTrilha,
                ),
              ),
            ),
            _conteudo != null
                ? PerfilPage(visaoGeral: _conteudo!.visaoGeral)
                : PerfilContaPage(
                    usuario: widget.usuario!,
                    authSession: widget.authSession!,
                  ),
          ],
        ),
      ),
    );
  }
}
