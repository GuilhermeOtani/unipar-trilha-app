import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/api_error.dart';
import 'package:unipar_trilha_app/core/theme/app_spacing.dart';
import 'package:unipar_trilha_app/core/widgets/app_async_state.dart';
import 'package:unipar_trilha_app/core/widgets/app_empty_state.dart';
import 'package:unipar_trilha_app/core/widgets/app_page.dart';
import 'package:unipar_trilha_app/core/widgets/app_section_card.dart';
import 'package:unipar_trilha_app/core/widgets/profile_header.dart';
import 'package:unipar_trilha_app/modules/acompanhamento/dto/indicadores_turma_response.dart';
import 'package:unipar_trilha_app/modules/acompanhamento/service/acompanhamento_service.dart';
import 'package:unipar_trilha_app/modules/home/dto/professor_contexto_response.dart';
import 'package:unipar_trilha_app/modules/login/dto/usuario_response.dart';

class AcompanhamentoProfessorPage extends StatefulWidget {
  const AcompanhamentoProfessorPage({
    super.key,
    required this.usuario,
    required this.contexto,
    this.service,
  });

  final UsuarioResponse usuario;
  final ProfessorContextoResponse contexto;
  final AcompanhamentoServiceContract? service;

  @override
  State<AcompanhamentoProfessorPage> createState() =>
      _AcompanhamentoProfessorPageState();
}

class _AcompanhamentoProfessorPageState
    extends State<AcompanhamentoProfessorPage> {
  late final AcompanhamentoServiceContract _service =
      widget.service ?? AcompanhamentoService();
  int? _turmaId;
  IndicadoresTurmaResponse? _indicadores;
  bool _carregando = false;
  String? _erro;
  int _operacao = 0;

  @override
  void initState() {
    super.initState();
    if (widget.contexto.turmas.isNotEmpty) {
      _turmaId = widget.contexto.turmas.first.turmaId;
      _carregar();
    }
  }

  Future<void> _carregar() async {
    final turmaId = _turmaId;
    if (turmaId == null) return;
    final operacao = ++_operacao;
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final response = await _service.obter(turmaId);
      if (mounted && operacao == _operacao) {
        setState(() => _indicadores = response);
      }
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
    final indicadores = _indicadores;
    return AppPage(
      maxContentWidth: 900,
      header: ProfileHeader(
        name: widget.usuario.nome,
        registration: widget.usuario.login,
        registrationLabel: 'Login',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Acompanhamento',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.md),
          if (widget.contexto.turmas.isNotEmpty)
            DropdownButtonFormField<int>(
              key: ValueKey(_turmaId),
              initialValue: _turmaId,
              decoration: const InputDecoration(labelText: 'Turma'),
              items: [
                for (final turma in widget.contexto.turmas)
                  DropdownMenuItem(
                    value: turma.turmaId,
                    child: Text(turma.turmaNome),
                  ),
              ],
              onChanged: (value) {
                setState(() => _turmaId = value);
                _carregar();
              },
            ),
          const SizedBox(height: AppSpacing.lg),
          if (widget.contexto.turmas.isEmpty)
            const AppEmptyState(
              title: 'Nenhuma turma vinculada',
              message: 'Os indicadores ficam disponíveis após o vínculo.',
            )
          else if (_carregando)
            const AppLoadingState(message: 'Calculando indicadores...')
          else if (_erro != null)
            AppErrorState(message: _erro!, onRetry: _carregar)
          else if (indicadores != null) ...[
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                _Indicador(
                  label: 'Matriculados',
                  valor: indicadores.matriculados,
                ),
                _Indicador(label: 'Iniciaram', valor: indicadores.iniciaram),
                _Indicador(label: 'Concluíram', valor: indicadores.concluiram),
                _Indicador(
                  label: 'Conclusão',
                  valor: indicadores.percentualConclusao,
                  sufixo: '%',
                ),
                _Indicador(label: 'Acertos', valor: indicadores.acertos),
                _Indicador(label: 'Erros', valor: indicadores.erros),
                _Indicador(
                  label: 'Acurácia',
                  valor: indicadores.acuracia,
                  sufixo: '%',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppSectionCard(
              title: 'Desafios com mais erros',
              child: indicadores.desafiosComMaisErros.isEmpty
                  ? const Text('Ainda não há tentativas nesta turma.')
                  : Column(
                      children: [
                        for (final item in indicadores.desafiosComMaisErros)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              child: Text('${item.taxaErro}%'),
                            ),
                            title: Text(item.enunciado),
                            subtitle: Text(
                              'Versão ${item.numeroVersao} • ${item.erros} erro(s) em ${item.tentativas} tentativa(s)',
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Indicador extends StatelessWidget {
  const _Indicador({
    required this.label,
    required this.valor,
    this.sufixo = '',
  });
  final String label;
  final int valor;
  final String sufixo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: AppSectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$valor$sufixo',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}
