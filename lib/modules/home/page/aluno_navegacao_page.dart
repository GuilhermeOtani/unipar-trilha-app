import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unipar_trilha_app/core/api_error.dart';
import 'package:unipar_trilha_app/core/theme/app_assets.dart';
import 'package:unipar_trilha_app/core/widgets/app_bottom_navigation.dart';
import 'package:unipar_trilha_app/core/widgets/app_empty_state.dart';
import 'package:unipar_trilha_app/core/widgets/app_page.dart';
import 'package:unipar_trilha_app/core/widgets/app_shell.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/page/caminho_trilha_page.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/page/sessao_pratica_page.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/service/aprendizagem_service.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/models/trilha_resumo.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/page/catalogo_aluno_page.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/service/catalogo_aluno_service.dart';
import 'package:unipar_trilha_app/modules/home/models/aluno_conteudo.dart';
import 'package:unipar_trilha_app/modules/home/models/home_aluno.dart';
import 'package:unipar_trilha_app/modules/home/page/aluno_home_page.dart';
import 'package:unipar_trilha_app/modules/perfil/page/perfil_page.dart';
import 'package:unipar_trilha_app/shared/widgets/aluno_header.dart';

enum AbaAluno { inicio, desempenho, trilhas, perfil }

/// Navegação do aluno: `AppShell` + navegação inferior com quatro abas.
///
/// | Aba | Ícone | Telas |
/// |---|---|---|
/// | Início | casa | 1 |
/// | Desempenho | barras | sem wireframe (estado vazio) |
/// | Trilhas | livro | 3 → 2 → 4/5/6 (pilha própria) |
/// | Perfil | menu | 7 |
///
/// Carrega o catálogo com `CatalogoAlunoService` (home e aba Trilhas usam a
/// mesma lista) e abre a prática com `SessaoPraticaPage`. Os services são
/// opcionais para testes e pré-visualização; em execução normal usam a API.
///
/// A aba Trilhas tem um `Navigator` interno para manter a navegação inferior
/// visível no caminho e na prática, como nos wireframes.
class AlunoNavegacaoPage extends StatefulWidget {
  const AlunoNavegacaoPage({
    super.key,
    required this.conteudo,
    this.catalogoService,
    this.aprendizagemService,
  });

  final AlunoConteudo conteudo;
  final CatalogoAlunoService? catalogoService;
  final AprendizagemService? aprendizagemService;

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
  late final CatalogoAlunoService _catalogoService =
      widget.catalogoService ?? CatalogoAlunoService();
  late final AprendizagemService _aprendizagemService =
      widget.aprendizagemService ?? AprendizagemService();

  AbaAluno _aba = AbaAluno.inicio;
  List<TrilhaResumo> _trilhas = const [];
  bool _carregandoTrilhas = true;
  String? _erroTrilhas;
  int _carregamento = 0;

  AlunoConteudo get _conteudo => widget.conteudo;
  NavigatorState get _pilhaTrilhas => _trilhasNavigator.currentState!;

  @override
  void initState() {
    super.initState();
    _carregarTrilhas();
  }

  /// Busca o catálogo; uma resposta atrasada de chamada anterior é ignorada.
  Future<void> _carregarTrilhas() async {
    final operacao = ++_carregamento;
    setState(() {
      _carregandoTrilhas = true;
      _erroTrilhas = null;
    });
    try {
      final catalogo = await _catalogoService.listar();
      if (!mounted || operacao != _carregamento) return;
      setState(() {
        _trilhas = [
          for (final (indice, item) in catalogo.distribuicoes.indexed)
            TrilhaResumo.fromDistribuicao(item, indice: indice),
        ];
      });
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
      ..push(_rotaCaminho(trilha));
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
        aluno: _conteudo.aluno,
        caminho: _conteudo.caminhoDe(trilha),
        onSelecionarLicao: (_) =>
            Navigator.of(context).push(_rotaPratica(trilha)),
      ),
    );
  }

  /// A API abre a prática pela distribuição; ao sair, o catálogo é recarregado
  /// para refletir o progresso retornado pelo backend.
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
              aluno: _conteudo.aluno,
              trilhas: _trilhas,
              carregandoTrilhas: _carregandoTrilhas,
              erroTrilhas: _erroTrilhas,
              onTentarNovamente: _carregarTrilhas,
              metaDiaria: _conteudo.metaDiaria,
              proximaLicao: _conteudo.proximaLicao,
              onAbrirTrilha: _abrirTrilha,
              onVerTodas: () => _selecionarAba(AbaAluno.trilhas.index),
              onComecarProximaLicao: _comecarProximaLicao,
            ),
            AppPage(
              header: AlunoHeader(aluno: _conteudo.aluno),
              body: const AppEmptyState(
                title: 'Desempenho',
                message: 'Em breve você poderá acompanhar seu desempenho aqui.',
              ),
            ),
            Navigator(
              key: _trilhasNavigator,
              onGenerateRoute: (_) => MaterialPageRoute(
                builder: (_) => CatalogoAlunoPage(
                  aluno: _conteudo.aluno,
                  trilhas: _trilhas,
                  carregando: _carregandoTrilhas,
                  erro: _erroTrilhas,
                  onTentarNovamente: _carregarTrilhas,
                  onAbrirTrilha: _abrirTrilha,
                ),
              ),
            ),
            PerfilPage(visaoGeral: _conteudo.visaoGeral),
          ],
        ),
      ),
    );
  }
}
