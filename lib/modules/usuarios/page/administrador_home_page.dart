import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/api_error.dart';
import 'package:unipar_trilha_app/core/auth_session.dart';
import 'package:unipar_trilha_app/core/theme/app_spacing.dart';
import 'package:unipar_trilha_app/core/widgets/app_async_state.dart';
import 'package:unipar_trilha_app/core/widgets/app_button.dart';
import 'package:unipar_trilha_app/core/widgets/app_empty_state.dart';
import 'package:unipar_trilha_app/core/widgets/app_message_banner.dart';
import 'package:unipar_trilha_app/core/widgets/app_page.dart';
import 'package:unipar_trilha_app/core/widgets/app_section_card.dart';
import 'package:unipar_trilha_app/core/widgets/app_text_field.dart';
import 'package:unipar_trilha_app/core/widgets/profile_header.dart';
import 'package:unipar_trilha_app/modules/login/dto/perfil_usuario.dart';
import 'package:unipar_trilha_app/modules/login/dto/usuario_response.dart';
import 'package:unipar_trilha_app/modules/usuarios/dto/usuario_create_request.dart';
import 'package:unipar_trilha_app/modules/usuarios/service/usuario_service.dart';

class AdministradorHomePage extends StatefulWidget {
  const AdministradorHomePage({
    super.key,
    required this.usuario,
    required this.authSession,
    this.service,
  });

  final UsuarioResponse usuario;
  final AuthSession authSession;
  final UsuarioServiceContract? service;

  @override
  State<AdministradorHomePage> createState() => _AdministradorHomePageState();
}

class _AdministradorHomePageState extends State<AdministradorHomePage> {
  late final UsuarioServiceContract _service =
      widget.service ?? UsuarioService();
  final _formKey = GlobalKey<FormState>();
  final _login = TextEditingController();
  final _nome = TextEditingController();
  final _senha = TextEditingController();
  List<UsuarioResponse> _usuarios = const [];
  PerfilUsuario? _filtro;
  PerfilUsuario _novoPerfil = PerfilUsuario.aluno;
  bool _carregando = true;
  bool _enviando = false;
  String? _erro;
  String? _sucesso;
  int _operacao = 0;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _login.dispose();
    _nome.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    final operacao = ++_operacao;
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final listas = await Future.wait([
        for (final perfil in PerfilUsuario.values) _service.listar(perfil),
      ]);
      if (!mounted || operacao != _operacao) return;
      setState(() {
        _usuarios = listas.expand((lista) => lista).toList(growable: false)
          ..sort((a, b) => a.nome.compareTo(b.nome));
      });
    } on ApiError catch (error) {
      if (mounted && operacao == _operacao) {
        setState(() => _erro = error.message);
      }
    } finally {
      if (mounted && operacao == _operacao) setState(() => _carregando = false);
    }
  }

  Future<void> _criar() async {
    if (_enviando || !_formKey.currentState!.validate()) return;
    setState(() {
      _enviando = true;
      _erro = null;
      _sucesso = null;
    });
    try {
      await _service.criar(
        UsuarioCreateRequest(
          login: _login.text.trim(),
          nome: _nome.text.trim(),
          senha: _senha.text,
          perfil: _novoPerfil,
        ),
      );
      if (!mounted) return;
      _login.clear();
      _nome.clear();
      _senha.clear();
      setState(() => _sucesso = 'Usuário criado com sucesso.');
      await _carregar();
    } on ApiError catch (error) {
      if (mounted) setState(() => _erro = error.message);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  String? _obrigatorio(String? value) =>
      value == null || value.trim().isEmpty ? 'Campo obrigatório.' : null;

  List<UsuarioResponse> get _filtrados => _filtro == null
      ? _usuarios
      : _usuarios.where((usuario) => usuario.perfil == _filtro).toList();

  @override
  Widget build(BuildContext context) {
    return AppPage(
      maxContentWidth: 1100,
      header: ProfileHeader(
        name: widget.usuario.nome,
        registration: widget.usuario.login,
        registrationLabel: 'Login',
        trailing: IconButton(
          tooltip: 'Sair',
          onPressed: widget.authSession.logout,
          icon: const Icon(Icons.logout),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Gestão de usuários',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (_erro != null) ...[
            const SizedBox(height: AppSpacing.md),
            AppMessageBanner(message: _erro!),
          ],
          if (_sucesso != null) ...[
            const SizedBox(height: AppSpacing.md),
            AppMessageBanner(message: _sucesso!, kind: AppMessageKind.info),
          ],
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final form = _formulario();
              final list = _lista();
              if (constraints.maxWidth < 760) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    form,
                    const SizedBox(height: AppSpacing.lg),
                    list,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 340, child: form),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(child: list),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _formulario() {
    return AppSectionCard(
      title: 'Novo usuário',
      subtitle: 'Cadastro interno realizado pelo administrador.',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppTextField(
              label: 'Login',
              controller: _login,
              validator: _obrigatorio,
              enabled: !_enviando,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Nome',
              controller: _nome,
              validator: _obrigatorio,
              enabled: !_enviando,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Senha',
              controller: _senha,
              obscureText: true,
              enabled: !_enviando,
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'Use pelo menos 6 caracteres.';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<PerfilUsuario>(
              isExpanded: true,
              initialValue: _novoPerfil,
              decoration: const InputDecoration(labelText: 'Perfil'),
              items: [
                for (final perfil in PerfilUsuario.values)
                  DropdownMenuItem(value: perfil, child: Text(perfil.label)),
              ],
              onChanged: _enviando
                  ? null
                  : (value) {
                      if (value != null) setState(() => _novoPerfil = value);
                    },
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              key: const Key('criar-usuario'),
              label: 'Criar usuário',
              expanded: true,
              isLoading: _enviando,
              onPressed: _enviando ? null : _criar,
            ),
          ],
        ),
      ),
    );
  }

  Widget _lista() {
    return AppSectionCard(
      title: 'Usuários',
      trailing: IconButton(
        tooltip: 'Atualizar',
        onPressed: _carregando ? null : _carregar,
        icon: const Icon(Icons.refresh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<PerfilUsuario?>(
            isExpanded: true,
            initialValue: _filtro,
            decoration: const InputDecoration(labelText: 'Filtrar por perfil'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Todos')),
              for (final perfil in PerfilUsuario.values)
                DropdownMenuItem(value: perfil, child: Text(perfil.label)),
            ],
            onChanged: (value) => setState(() => _filtro = value),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_carregando)
            const AppLoadingState(message: 'Carregando usuários...')
          else if (_filtrados.isEmpty)
            const AppEmptyState(
              title: 'Nenhum usuário',
              message: 'Não há usuários neste filtro.',
            )
          else
            for (final usuario in _filtrados)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  child: Text(usuario.nome.substring(0, 1).toUpperCase()),
                ),
                title: Text(usuario.nome),
                subtitle: Text('${usuario.login} • ${usuario.perfil.label}'),
                trailing: Icon(
                  usuario.ativo ? Icons.check_circle_outline : Icons.block,
                ),
              ),
        ],
      ),
    );
  }
}
