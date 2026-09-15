import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/api_error.dart';
import 'package:unipar_trilha_app/core/auth_session.dart';
import 'package:unipar_trilha_app/core/theme/app_assets.dart';
import 'package:unipar_trilha_app/core/widgets/app_async_state.dart';
import 'package:unipar_trilha_app/core/widgets/app_bottom_navigation.dart';
import 'package:unipar_trilha_app/core/widgets/app_page.dart';
import 'package:unipar_trilha_app/core/widgets/app_shell.dart';
import 'package:unipar_trilha_app/modules/acompanhamento/page/acompanhamento_professor_page.dart';
import 'package:unipar_trilha_app/modules/distribuicao/page/distribuicoes_professor_page.dart';
import 'package:unipar_trilha_app/modules/home/dto/professor_contexto_response.dart';
import 'package:unipar_trilha_app/modules/home/page/professor_home_page.dart';
import 'package:unipar_trilha_app/modules/home/service/professor_contexto_service.dart';
import 'package:unipar_trilha_app/modules/login/dto/usuario_response.dart';
import 'package:unipar_trilha_app/modules/perfil/page/perfil_conta_page.dart';
import 'package:unipar_trilha_app/modules/trilha/dto/trilha_dto.dart';
import 'package:unipar_trilha_app/modules/trilha/page/trilhas_professor_page.dart';
import 'package:unipar_trilha_app/modules/trilha/service/trilha_service.dart';

class ProfessorNavegacaoPage extends StatefulWidget {
  const ProfessorNavegacaoPage({
    super.key,
    required this.usuario,
    required this.authSession,
    this.contextoService,
    this.trilhaService,
  });

  final UsuarioResponse usuario;
  final AuthSession authSession;
  final ProfessorContextoServiceContract? contextoService;
  final TrilhaServiceContract? trilhaService;

  @override
  State<ProfessorNavegacaoPage> createState() => _ProfessorNavegacaoPageState();
}

class _ProfessorNavegacaoPageState extends State<ProfessorNavegacaoPage> {
  late final ProfessorContextoServiceContract _contextoService =
      widget.contextoService ?? ProfessorContextoService();
  late final TrilhaServiceContract _trilhaService =
      widget.trilhaService ?? TrilhaService();

  int _aba = 0;
  int _operacao = 0;
  bool _carregando = true;
  String? _erro;
  ProfessorContextoResponse? _contexto;
  List<TrilhaProfessorResumoResponse> _trilhas = const [];

  static const _destinos = [
    AppNavigationDestination(icon: AppIcons.home, label: 'Início'),
    AppNavigationDestination(icon: AppIcons.learningBook, label: 'Trilhas'),
    AppNavigationDestination(icon: AppIcons.play, label: 'Distribuir'),
    AppNavigationDestination(icon: AppIcons.ranking, label: 'Acompanhar'),
    AppNavigationDestination(icon: AppIcons.menu, label: 'Perfil'),
  ];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final operacao = ++_operacao;
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final resultados = await Future.wait<Object>([
        _contextoService.obter(),
        _trilhaService.listar(),
      ]);
      if (!mounted || operacao != _operacao) return;
      setState(() {
        _contexto = resultados[0] as ProfessorContextoResponse;
        _trilhas = resultados[1] as List<TrilhaProfessorResumoResponse>;
      });
    } on ApiError catch (error) {
      if (mounted && operacao == _operacao) {
        setState(() => _erro = error.message);
      }
    } finally {
      if (mounted && operacao == _operacao) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const AppPage(
        body: Center(
          child: AppLoadingState(message: 'Carregando área do professor...'),
        ),
      );
    }
    if (_erro != null || _contexto == null) {
      return AppPage(
        body: Center(
          child: AppErrorState(
            message: _erro ?? 'Contexto acadêmico indisponível.',
            onRetry: _carregar,
          ),
        ),
      );
    }
    final contexto = _contexto!;
    return AppShell(
      bottomNavigation: AppBottomNavigation(
        destinations: _destinos,
        currentIndex: _aba,
        onSelected: (value) => setState(() => _aba = value),
      ),
      body: IndexedStack(
        index: _aba,
        children: [
          ProfessorHomePage(
            usuario: widget.usuario,
            contexto: contexto,
            trilhas: _trilhas,
          ),
          TrilhasProfessorPage(
            usuario: widget.usuario,
            contexto: contexto,
            trilhas: _trilhas,
            service: _trilhaService,
            onAtualizar: _carregar,
          ),
          DistribuicoesProfessorPage(
            usuario: widget.usuario,
            contexto: contexto,
            trilhas: _trilhas,
          ),
          AcompanhamentoProfessorPage(
            usuario: widget.usuario,
            contexto: contexto,
          ),
          PerfilContaPage(
            usuario: widget.usuario,
            authSession: widget.authSession,
          ),
        ],
      ),
    );
  }
}
