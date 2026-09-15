import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_spacing.dart';
import 'package:unipar_trilha_app/core/widgets/app_page.dart';
import 'package:unipar_trilha_app/core/widgets/app_section_card.dart';
import 'package:unipar_trilha_app/core/widgets/profile_header.dart';
import 'package:unipar_trilha_app/modules/home/dto/professor_contexto_response.dart';
import 'package:unipar_trilha_app/modules/login/dto/usuario_response.dart';
import 'package:unipar_trilha_app/modules/trilha/dto/trilha_dto.dart';

class ProfessorHomePage extends StatelessWidget {
  const ProfessorHomePage({
    super.key,
    required this.usuario,
    required this.contexto,
    required this.trilhas,
  });

  final UsuarioResponse usuario;
  final ProfessorContextoResponse contexto;
  final List<TrilhaProfessorResumoResponse> trilhas;

  @override
  Widget build(BuildContext context) {
    final publicadas = trilhas.fold<int>(
      0,
      (total, item) => total + item.publicacoes.length,
    );
    return AppPage(
      maxContentWidth: 900,
      header: ProfileHeader(
        name: usuario.nome,
        registration: usuario.login,
        registrationLabel: 'Login',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Área do professor',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _Resumo(label: 'Turmas', valor: contexto.turmas.length),
              _Resumo(label: 'Rascunhos', valor: trilhas.length),
              _Resumo(label: 'Versões publicadas', valor: publicadas),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSectionCard(
            title: 'Contexto acadêmico',
            child: contexto.turmas.isEmpty
                ? const Text('Nenhuma turma vinculada ao seu usuário.')
                : Column(
                    children: [
                      for (final turma in contexto.turmas)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.school_outlined),
                          title: Text(turma.turmaNome),
                          subtitle: Text(
                            '${turma.disciplinaNome} • ${turma.periodo}',
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Resumo extends StatelessWidget {
  const _Resumo({required this.label, required this.valor});
  final String label;
  final int valor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: AppSectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$valor', style: Theme.of(context).textTheme.headlineMedium),
            Text(label),
          ],
        ),
      ),
    );
  }
}
