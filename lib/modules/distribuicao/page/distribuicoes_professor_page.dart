import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/api_error.dart';
import 'package:unipar_trilha_app/core/theme/app_spacing.dart';
import 'package:unipar_trilha_app/core/widgets/app_async_state.dart';
import 'package:unipar_trilha_app/core/widgets/app_button.dart';
import 'package:unipar_trilha_app/core/widgets/app_empty_state.dart';
import 'package:unipar_trilha_app/core/widgets/app_message_banner.dart';
import 'package:unipar_trilha_app/core/widgets/app_page.dart';
import 'package:unipar_trilha_app/core/widgets/app_section_card.dart';
import 'package:unipar_trilha_app/core/widgets/profile_header.dart';
import 'package:unipar_trilha_app/modules/distribuicao/dto/distribuicao_dto.dart';
import 'package:unipar_trilha_app/modules/distribuicao/service/distribuicao_service.dart';
import 'package:unipar_trilha_app/modules/home/dto/professor_contexto_response.dart';
import 'package:unipar_trilha_app/modules/login/dto/usuario_response.dart';
import 'package:unipar_trilha_app/modules/trilha/dto/trilha_dto.dart';

class DistribuicoesProfessorPage extends StatefulWidget {
  const DistribuicoesProfessorPage({
    super.key,
    required this.usuario,
    required this.contexto,
    required this.trilhas,
    this.service,
  });

  final UsuarioResponse usuario;
  final ProfessorContextoResponse contexto;
  final List<TrilhaProfessorResumoResponse> trilhas;
  final DistribuicaoServiceContract? service;

  @override
  State<DistribuicoesProfessorPage> createState() =>
      _DistribuicoesProfessorPageState();
}

class _DistribuicoesProfessorPageState
    extends State<DistribuicoesProfessorPage> {
  late final DistribuicaoServiceContract _service =
      widget.service ?? DistribuicaoService();
  int? _turmaId;
  int? _versaoId;
  DateTime _disponivelDe = DateTime.now();
  DateTime? _disponivelAte;
  List<DistribuicaoResponse> _distribuicoes = const [];
  bool _carregando = false;
  bool _enviando = false;
  String? _erro;
  String? _sucesso;
  int _operacao = 0;

  List<_VersaoDisponivel> get _versoes => [
    for (final trilha in widget.trilhas)
      for (final publicacao in trilha.publicacoes)
        _VersaoDisponivel(
          publicacao.versaoId,
          trilha.disciplinaId,
          '${trilha.titulo} — V${publicacao.numeroVersao}',
        ),
  ];

  List<_VersaoDisponivel> get _versoesDaTurma {
    final turma = widget.contexto.turmas
        .where((item) => item.turmaId == _turmaId)
        .firstOrNull;
    if (turma == null) return const [];
    return _versoes
        .where((item) => item.disciplinaId == turma.disciplinaId)
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    if (widget.contexto.turmas.isNotEmpty) {
      _turmaId = widget.contexto.turmas.first.turmaId;
      _versaoId = _versoesDaTurma.firstOrNull?.id;
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
      final itens = await _service.listar(turmaId);
      if (mounted && operacao == _operacao) {
        setState(() => _distribuicoes = itens);
      }
    } on ApiError catch (error) {
      if (mounted && operacao == _operacao) {
        setState(() => _erro = error.message);
      }
    } finally {
      if (mounted && operacao == _operacao) setState(() => _carregando = false);
    }
  }

  Future<void> _criar() async {
    if (_enviando || _turmaId == null || _versaoId == null) return;
    setState(() {
      _enviando = true;
      _erro = null;
      _sucesso = null;
    });
    try {
      await _service.criar(
        DistribuicaoRequest(
          versaoId: _versaoId!,
          turmaId: _turmaId!,
          disponivelDe: _disponivelDe,
          disponivelAte: _disponivelAte,
        ),
      );
      if (!mounted) return;
      setState(() => _sucesso = 'Trilha distribuída para a turma.');
      await _carregar();
    } on ApiError catch (error) {
      if (mounted) setState(() => _erro = error.message);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<void> _escolherData({required bool finalDoPrazo}) async {
    final inicial = finalDoPrazo
        ? (_disponivelAte ?? _disponivelDe)
        : _disponivelDe;
    final data = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (data == null || !mounted) return;
    setState(() {
      if (finalDoPrazo) {
        _disponivelAte = DateTime(data.year, data.month, data.day, 23, 59);
      } else {
        _disponivelDe = DateTime(data.year, data.month, data.day);
      }
    });
  }

  String _data(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

  @override
  Widget build(BuildContext context) {
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
            'Distribuições',
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
          AppSectionCard(
            title: 'Nova distribuição',
            child: widget.contexto.turmas.isEmpty
                ? const Text('Nenhuma turma vinculada.')
                : Column(
                    children: [
                      DropdownButtonFormField<int>(
                        isExpanded: true,
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
                          setState(() {
                            _turmaId = value;
                            _versaoId = _versoesDaTurma.firstOrNull?.id;
                          });
                          _carregar();
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        key: ValueKey('versao-$_turmaId-$_versaoId'),
                        initialValue: _versaoId,
                        decoration: const InputDecoration(
                          labelText: 'Versão publicada',
                        ),
                        items: [
                          for (final versao in _versoesDaTurma)
                            DropdownMenuItem(
                              value: versao.id,
                              child: Text(versao.label),
                            ),
                        ],
                        onChanged: (value) => setState(() => _versaoId = value),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _escolherData(finalDoPrazo: false),
                            icon: const Icon(Icons.calendar_today_outlined),
                            label: Text('Início: ${_data(_disponivelDe)}'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _escolherData(finalDoPrazo: true),
                            icon: const Icon(Icons.event_available_outlined),
                            label: Text(
                              _disponivelAte == null
                                  ? 'Sem prazo final'
                                  : 'Fim: ${_data(_disponivelAte!)}',
                            ),
                          ),
                          if (_disponivelAte != null)
                            TextButton(
                              onPressed: () =>
                                  setState(() => _disponivelAte = null),
                              child: const Text('Remover prazo'),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        label: 'Distribuir',
                        expanded: true,
                        isLoading: _enviando,
                        onPressed: _versaoId == null || _enviando
                            ? null
                            : _criar,
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Histórico da turma',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          if (_carregando)
            const AppLoadingState(message: 'Carregando distribuições...')
          else if (_distribuicoes.isEmpty)
            const AppEmptyState(
              title: 'Nenhuma distribuição',
              message: 'As versões enviadas para a turma aparecem aqui.',
            )
          else
            for (final item in _distribuicoes) ...[
              AppSectionCard(
                title: item.trilhaTitulo,
                subtitle: '${item.turmaNome} • Versão ${item.numeroVersao}',
                child: Text(
                  'Disponível desde ${_data(item.disponivelDe)}'
                  '${item.disponivelAte == null ? '' : ' até ${_data(item.disponivelAte!)}'}',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
        ],
      ),
    );
  }
}

class _VersaoDisponivel {
  const _VersaoDisponivel(this.id, this.disciplinaId, this.label);
  final int id;
  final int disciplinaId;
  final String label;
}
