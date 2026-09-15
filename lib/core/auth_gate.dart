import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/auth_session.dart';
import 'package:unipar_trilha_app/modules/home/page/aluno_navegacao_page.dart';
import 'package:unipar_trilha_app/modules/home/page/professor_navegacao_page.dart';
import 'package:unipar_trilha_app/modules/login/dto/perfil_usuario.dart';
import 'package:unipar_trilha_app/modules/login/page/login_page.dart';
import 'package:unipar_trilha_app/modules/login/service/login_service.dart';
import 'package:unipar_trilha_app/modules/usuarios/page/administrador_home_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, this.authSession, this.loginService});

  final AuthSession? authSession;
  final LoginServiceContract? loginService;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthSession _authSession;
  bool _starting = true;

  @override
  void initState() {
    super.initState();
    _authSession = widget.authSession ?? AuthSession.instance;
    _authSession.addListener(_sessionChanged);
    _restore();
  }

  @override
  void dispose() {
    _authSession.removeListener(_sessionChanged);
    super.dispose();
  }

  void _sessionChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _restore() async {
    if (mounted) setState(() => _starting = true);
    await _authSession.restaurar();
    if (mounted) setState(() => _starting = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_starting || _authSession.state.status == AuthSessionStatus.validando) {
      return const _SessionLoadingPage();
    }

    return switch (_authSession.state.status) {
      AuthSessionStatus.autenticada => _areaAutenticada(),
      AuthSessionStatus.naoValidada => LoginPage(
        service: widget.loginService,
        sessionMessage: _authSession.state.message,
        onRetrySession: _restore,
      ),
      AuthSessionStatus.semSessao => LoginPage(service: widget.loginService),
      AuthSessionStatus.validando => const _SessionLoadingPage(),
    };
  }

  Widget _areaAutenticada() {
    final usuario = _authSession.state.usuario!;
    return switch (usuario.perfil) {
      PerfilUsuario.aluno => AlunoNavegacaoPage(
        usuario: usuario,
        authSession: _authSession,
      ),
      PerfilUsuario.professor => ProfessorNavegacaoPage(
        usuario: usuario,
        authSession: _authSession,
      ),
      PerfilUsuario.administrador => AdministradorHomePage(
        usuario: usuario,
        authSession: _authSession,
      ),
    };
  }
}

class _SessionLoadingPage extends StatelessWidget {
  const _SessionLoadingPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Semantics(
          label: 'Validando sessão',
          child: const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
