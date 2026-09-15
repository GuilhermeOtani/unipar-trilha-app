import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_spacing.dart';
import 'package:unipar_trilha_app/core/widgets/app_button.dart';
import 'package:unipar_trilha_app/core/widgets/app_empty_state.dart';
import 'package:unipar_trilha_app/core/widgets/app_page.dart';
import 'package:unipar_trilha_app/core/widgets/app_section_card.dart';
import 'package:unipar_trilha_app/core/widgets/profile_header.dart';
import 'package:unipar_trilha_app/modules/home/dto/professor_contexto_response.dart';
import 'package:unipar_trilha_app/modules/login/dto/usuario_response.dart';
import 'package:unipar_trilha_app/modules/trilha/dto/trilha_dto.dart';
import 'package:unipar_trilha_app/modules/trilha/page/trilha_editor_page.dart';
import 'package:unipar_trilha_app/modules/trilha/service/trilha_service.dart';

class TrilhasProfessorPage extends StatelessWidget {
  const TrilhasProfessorPage({
    super.key,
    required this.usuario,
    required this.contexto,
    required this.trilhas,
    required this.service,
    required this.onAtualizar,
  });

  final UsuarioResponse usuario;
  final ProfessorContextoResponse contexto;
  final List<TrilhaProfessorResumoResponse> trilhas;
  final TrilhaServiceContract service;
  final Future<void> Function() onAtualizar;

  Future<void> _abrir(BuildContext context, [int? trilhaId]) async {
    final alterou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TrilhaEditorPage(
          contexto: contexto,
          service: service,
          trilhaId: trilhaId,
        ),
      ),
    );
    if (alterou == true) await onAtualizar();
  }

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Minhas trilhas',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              AppButton(
                label: 'Nova trilha',
                size: AppButtonSize.small,
                onPressed: contexto.turmas.isEmpty
                    ? null
                    : () => _abrir(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (trilhas.isEmpty)
            AppEmptyState(
              title: 'Nenhum rascunho',
              message: contexto.turmas.isEmpty
                  ? 'É necessário ter uma turma vinculada para criar trilhas.'
                  : 'Crie a primeira trilha para começar a publicar.',
            )
          else
            for (final trilha in trilhas) ...[
              AppSectionCard(
                title: trilha.titulo,
                subtitle:
                    '${trilha.disciplinaNome} • ${trilha.publicacoes.length} versão(ões)',
                trailing: IconButton(
                  tooltip: 'Editar rascunho',
                  onPressed: () => _abrir(context, trilha.id),
                  icon: const Icon(Icons.edit_outlined),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trilha.descricao ?? 'Sem descrição'),
                    if (trilha.publicacoes.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.xs,
                        children: [
                          for (final versao in trilha.publicacoes)
                            Chip(label: Text('Versão ${versao.numeroVersao}')),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
        ],
      ),
    );
  }
}
