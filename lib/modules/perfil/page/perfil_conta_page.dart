import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/auth_session.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/theme/app_spacing.dart';
import 'package:unipar_trilha_app/core/widgets/app_button.dart';
import 'package:unipar_trilha_app/core/widgets/app_page.dart';
import 'package:unipar_trilha_app/core/widgets/profile_header.dart';
import 'package:unipar_trilha_app/modules/login/dto/usuario_response.dart';

class PerfilContaPage extends StatelessWidget {
  const PerfilContaPage({
    super.key,
    required this.usuario,
    required this.authSession,
  });

  final UsuarioResponse usuario;
  final AuthSession authSession;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return AppPage(
      header: ProfileHeader(
        name: usuario.nome,
        registration: usuario.login,
        registrationLabel: 'Login',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: colors.surfaceDefault,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: colors.borderCard),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Conta', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                Text('Nome: ${usuario.nome}'),
                Text('Login: ${usuario.login}'),
                Text('Perfil: ${usuario.perfil.label}'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Sair',
            variant: AppButtonVariant.outline,
            onPressed: authSession.logout,
          ),
        ],
      ),
    );
  }
}
