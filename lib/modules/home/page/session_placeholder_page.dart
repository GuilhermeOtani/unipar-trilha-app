import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/auth_session.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/widgets/app_primary_button.dart';
import 'package:unipar_trilha_app/core/widgets/auth_shell.dart';

class SessionPlaceholderPage extends StatefulWidget {
  const SessionPlaceholderPage({super.key, required this.authSession});

  final AuthSession authSession;

  @override
  State<SessionPlaceholderPage> createState() => _SessionPlaceholderPageState();
}

class _SessionPlaceholderPageState extends State<SessionPlaceholderPage> {
  bool _leaving = false;

  Future<void> _logout() async {
    if (_leaving) return;
    setState(() => _leaving = true);
    try {
      await widget.authSession.logout();
    } finally {
      if (mounted) setState(() => _leaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = widget.authSession.state.usuario!;
    return AuthShell(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.iconSuccess,
            size: 52,
          ),
          const SizedBox(height: 20),
          Text(
            'Login realizado!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            usuario.nome,
            key: const Key('authenticated-user-name'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            usuario.perfil.label,
            key: const Key('authenticated-user-profile'),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.actionPrimary),
          ),
          const SizedBox(height: 22),
          const Text(
            'Sua área inicial está em construção. Esta página será substituída pela home do seu perfil.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 26),
          AppPrimaryButton(
            key: const Key('session-logout'),
            label: 'Sair',
            icon: const Icon(Icons.logout_rounded),
            loading: _leaving,
            onPressed: _logout,
          ),
        ],
      ),
    );
  }
}
