import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/api_error.dart';
import 'package:unipar_trilha_app/core/theme/app_spacing.dart';
import 'package:unipar_trilha_app/core/widgets/app_async_state.dart';
import 'package:unipar_trilha_app/core/widgets/app_button.dart';
import 'package:unipar_trilha_app/core/widgets/app_message_banner.dart';
import 'package:unipar_trilha_app/core/widgets/app_page.dart';
import 'package:unipar_trilha_app/core/widgets/app_section_card.dart';
import 'package:unipar_trilha_app/core/widgets/app_text_field.dart';
import 'package:unipar_trilha_app/modules/home/dto/professor_contexto_response.dart';
import 'package:unipar_trilha_app/modules/trilha/dto/trilha_dto.dart';
import 'package:unipar_trilha_app/modules/trilha/service/trilha_service.dart';

class TrilhaEditorPage extends StatefulWidget {
  const TrilhaEditorPage({
    super.key,
    required this.contexto,
    required this.service,
    this.trilhaId,
  });

  final ProfessorContextoResponse contexto;
  final TrilhaServiceContract service;
  final int? trilhaId;

  @override
  State<TrilhaEditorPage> createState() => _TrilhaEditorPageState();
}

class _TrilhaEditorPageState extends State<TrilhaEditorPage> {
  final _titulo = TextEditingController();
  final _descricao = TextEditingController();
  final List<_ModuloEditor> _modulos = [];
  int? _disciplinaId;
  int? _trilhaId;
  int _etapa = 0;
  int _operacao = 0;
  bool _carregando = false;
  bool _enviando = false;
  String? _erro;
  String? _sucesso;

  @override
  void initState() {
    super.initState();
    _trilhaId = widget.trilhaId;
    _disciplinaId = widget.contexto.turmas.isEmpty
        ? null
        : widget.contexto.turmas.first.disciplinaId;
    if (_trilhaId == null) {
      _modulos.add(_ModuloEditor.vazio());
    } else {
      _carregar();
    }
  }

  @override
  void dispose() {
    _titulo.dispose();
    _descricao.dispose();
    for (final modulo in _modulos) {
      modulo.dispose();
    }
    super.dispose();
  }

  List<TurmaProfessorResponse> get _disciplinas {
    final unicas = <int, TurmaProfessorResponse>{};
    for (final turma in widget.contexto.turmas) {
      unicas.putIfAbsent(turma.disciplinaId, () => turma);
    }
    return unicas.values.toList(growable: false);
  }

  Future<void> _carregar() async {
    final operacao = ++_operacao;
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final trilha = await widget.service.buscar(_trilhaId!);
      if (!mounted || operacao != _operacao) return;
      _titulo.text = trilha.titulo;
      _descricao.text = trilha.descricao ?? '';
      _disciplinaId = trilha.disciplinaId;
      for (final modulo in _modulos) {
        modulo.dispose();
      }
      _modulos
        ..clear()
        ..addAll(
          trilha.modulos.isEmpty
              ? [_ModuloEditor.vazio()]
              : trilha.modulos.map(_ModuloEditor.fromDto),
        );
    } on ApiError catch (error) {
      if (mounted && operacao == _operacao) {
        setState(() => _erro = error.message);
      }
    } finally {
      if (mounted && operacao == _operacao) setState(() => _carregando = false);
    }
  }

  String? _validarEtapaBasica() {
    if (_titulo.text.trim().isEmpty) return 'Informe o título da trilha.';
    if (_disciplinaId == null) return 'Selecione uma disciplina.';
    return null;
  }

  String? _validarConteudo() {
    if (_modulos.isEmpty) return 'Adicione pelo menos um módulo.';
    for (var m = 0; m < _modulos.length; m++) {
      final modulo = _modulos[m];
      if (modulo.titulo.text.trim().isEmpty) {
        return 'Informe o título do módulo ${m + 1}.';
      }
      if (modulo.licoes.isEmpty) {
        return 'O módulo ${m + 1} precisa de uma lição.';
      }
      for (var l = 0; l < modulo.licoes.length; l++) {
        final licao = modulo.licoes[l];
        if (licao.titulo.text.trim().isEmpty) {
          return 'Informe o título da lição ${l + 1} do módulo ${m + 1}.';
        }
        if (licao.desafios.isEmpty) return 'Cada lição precisa de um desafio.';
        for (final desafio in licao.desafios) {
          if (desafio.enunciado.text.trim().isEmpty ||
              desafio.explicacao.text.trim().isEmpty) {
            return 'Preencha o enunciado e a explicação de cada desafio.';
          }
          if (desafio.opcoes.length < 2) {
            return 'Cada desafio precisa de pelo menos duas opções.';
          }
          if (desafio.opcoes.any((opcao) => opcao.texto.text.trim().isEmpty)) {
            return 'Preencha o texto de todas as opções.';
          }
          if (desafio.opcoes.where((opcao) => opcao.correta).length != 1) {
            return 'Marque exatamente uma resposta correta por desafio.';
          }
        }
      }
    }
    return null;
  }

  Future<void> _avancar() async {
    if (_enviando) return;
    final basico = _validarEtapaBasica();
    if (basico != null) {
      setState(() => _erro = basico);
      return;
    }
    if (_etapa == 0) {
      if (_trilhaId == null) {
        await _criarRascunho();
      } else {
        setState(() {
          _erro = null;
          _etapa = 1;
        });
      }
      return;
    }
    if (_etapa == 1) await _salvarConteudo();
  }

  Future<void> _criarRascunho() async {
    setState(() {
      _enviando = true;
      _erro = null;
    });
    try {
      final trilha = await widget.service.criar(
        TrilhaCreateRequest(
          titulo: _titulo.text.trim(),
          descricao: _textoOpcional(_descricao.text),
          disciplinaId: _disciplinaId!,
        ),
      );
      if (!mounted) return;
      setState(() {
        _trilhaId = trilha.id;
        _etapa = 1;
        _sucesso = 'Rascunho criado. Agora monte o conteúdo.';
      });
    } on ApiError catch (error) {
      if (mounted) setState(() => _erro = error.message);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<void> _salvarConteudo() async {
    final erro = _validarConteudo();
    if (erro != null) {
      setState(() => _erro = erro);
      return;
    }
    setState(() {
      _enviando = true;
      _erro = null;
    });
    try {
      await widget.service.atualizar(_trilhaId!, _request());
      if (!mounted) return;
      setState(() {
        _etapa = 2;
        _sucesso = 'Conteúdo salvo. Revise antes de publicar.';
      });
    } on ApiError catch (error) {
      if (mounted) setState(() => _erro = error.message);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<void> _publicar() async {
    if (_enviando) return;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Publicar versão?'),
        content: const Text(
          'Será criado um snapshot imutável. O rascunho continuará editável.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Publicar'),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;
    setState(() {
      _enviando = true;
      _erro = null;
    });
    try {
      final publicacao = await widget.service.publicar(_trilhaId!);
      if (!mounted) return;
      setState(
        () => _sucesso =
            'Versão ${publicacao.numeroVersao} publicada com sucesso.',
      );
      Navigator.of(context).pop(true);
    } on ApiError catch (error) {
      if (mounted) setState(() => _erro = error.message);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  TrilhaConteudoRequest _request() => TrilhaConteudoRequest(
    titulo: _titulo.text.trim(),
    descricao: _textoOpcional(_descricao.text),
    disciplinaId: _disciplinaId!,
    modulos: [
      for (final (m, modulo) in _modulos.indexed)
        ModuloTrilhaDto(
          titulo: modulo.titulo.text.trim(),
          ordem: m + 1,
          licoes: [
            for (final (l, licao) in modulo.licoes.indexed)
              LicaoTrilhaDto(
                titulo: licao.titulo.text.trim(),
                resumo: _textoOpcional(licao.resumo.text),
                ordem: l + 1,
                desafios: [
                  for (final (d, desafio) in licao.desafios.indexed)
                    DesafioTrilhaDto(
                      enunciado: desafio.enunciado.text.trim(),
                      dificuldade: desafio.dificuldade,
                      explicacao: desafio.explicacao.text.trim(),
                      ordem: d + 1,
                      opcoes: [
                        for (final (o, opcao) in desafio.opcoes.indexed)
                          OpcaoTrilhaDto(
                            texto: opcao.texto.text.trim(),
                            ordem: o + 1,
                            correta: opcao.correta,
                          ),
                      ],
                    ),
                ],
              ),
          ],
        ),
    ],
  );

  String? _textoOpcional(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  void _voltarEtapa() {
    if (_etapa == 0) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _etapa--;
        _erro = null;
        _sucesso = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const AppPage(
        body: Center(child: AppLoadingState(message: 'Carregando rascunho...')),
      );
    }
    return AppPage(
      maxContentWidth: 960,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Voltar',
                onPressed: _enviando ? null : _voltarEtapa,
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  _trilhaId == null ? 'Nova trilha' : 'Editar trilha',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _EtapasIndicador(etapa: _etapa),
          if (_erro != null) ...[
            const SizedBox(height: AppSpacing.md),
            AppMessageBanner(message: _erro!),
          ],
          if (_sucesso != null) ...[
            const SizedBox(height: AppSpacing.md),
            AppMessageBanner(message: _sucesso!, kind: AppMessageKind.info),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (_etapa == 0)
            _basico()
          else if (_etapa == 1)
            _conteudo()
          else
            _revisao(),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final voltar = AppButton(
                label: _etapa == 0 ? 'Cancelar' : 'Voltar',
                variant: AppButtonVariant.outline,
                onPressed: _enviando ? null : _voltarEtapa,
              );
              final avancar = AppButton(
                key: const Key('trilha-primary-action'),
                label: _etapa == 2 ? 'Publicar versão' : 'Continuar',
                isLoading: _enviando,
                onPressed: _enviando
                    ? null
                    : () => _etapa == 2 ? _publicar() : _avancar(),
              );

              if (constraints.maxWidth < 440) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    avancar,
                    const SizedBox(height: AppSpacing.sm),
                    voltar,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: voltar),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: avancar),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _basico() {
    return AppSectionCard(
      title: '1. Informações básicas',
      subtitle: 'Defina o rascunho antes de montar as lições.',
      child: Column(
        children: [
          AppTextField(label: 'Título', controller: _titulo),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Descrição',
            controller: _descricao,
            minLines: 3,
            maxLines: 5,
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<int>(
            isExpanded: true,
            key: ValueKey(_disciplinaId),
            initialValue: _disciplinaId,
            decoration: const InputDecoration(labelText: 'Disciplina'),
            items: [
              for (final disciplina in _disciplinas)
                DropdownMenuItem(
                  value: disciplina.disciplinaId,
                  child: Text(disciplina.disciplinaNome),
                ),
            ],
            onChanged: _enviando
                ? null
                : (value) => setState(() => _disciplinaId = value),
          ),
        ],
      ),
    );
  }

  Widget _conteudo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (indice, modulo) in _modulos.indexed) ...[
          _modulo(modulo, indice),
          const SizedBox(height: AppSpacing.md),
        ],
        AppButton(
          label: 'Adicionar módulo',
          variant: AppButtonVariant.outline,
          onPressed: () => setState(() => _modulos.add(_ModuloEditor.vazio())),
        ),
      ],
    );
  }

  Widget _modulo(_ModuloEditor modulo, int indice) {
    return AppSectionCard(
      title: 'Módulo ${indice + 1}',
      trailing: IconButton(
        tooltip: 'Remover módulo',
        onPressed: () => setState(() {
          _modulos.removeAt(indice).dispose();
        }),
        icon: const Icon(Icons.delete_outline),
      ),
      child: Column(
        children: [
          AppTextField(label: 'Título do módulo', controller: modulo.titulo),
          const SizedBox(height: AppSpacing.md),
          for (final (l, licao) in modulo.licoes.indexed) ...[
            _licao(modulo, licao, l),
            const SizedBox(height: AppSpacing.sm),
          ],
          AppButton(
            label: 'Adicionar lição',
            size: AppButtonSize.small,
            variant: AppButtonVariant.outline,
            onPressed: () =>
                setState(() => modulo.licoes.add(_LicaoEditor.vazia())),
          ),
        ],
      ),
    );
  }

  Widget _licao(_ModuloEditor modulo, _LicaoEditor licao, int indice) {
    return ExpansionTile(
      initiallyExpanded: true,
      title: Text('Lição ${indice + 1}'),
      trailing: IconButton(
        tooltip: 'Remover lição',
        onPressed: () => setState(() {
          modulo.licoes.removeAt(indice).dispose();
        }),
        icon: const Icon(Icons.delete_outline),
      ),
      childrenPadding: const EdgeInsets.only(bottom: AppSpacing.md),
      children: [
        AppTextField(label: 'Título da lição', controller: licao.titulo),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          label: 'Resumo',
          controller: licao.resumo,
          minLines: 2,
          maxLines: 4,
        ),
        const SizedBox(height: AppSpacing.md),
        for (final (d, desafio) in licao.desafios.indexed) ...[
          _desafio(licao, desafio, d),
          const SizedBox(height: AppSpacing.sm),
        ],
        AppButton(
          label: 'Adicionar desafio',
          size: AppButtonSize.small,
          variant: AppButtonVariant.outline,
          onPressed: () =>
              setState(() => licao.desafios.add(_DesafioEditor.vazio())),
        ),
      ],
    );
  }

  Widget _desafio(_LicaoEditor licao, _DesafioEditor desafio, int indice) {
    return AppSectionCard(
      title: 'Desafio ${indice + 1}',
      trailing: IconButton(
        tooltip: 'Remover desafio',
        onPressed: () => setState(() {
          licao.desafios.removeAt(indice).dispose();
        }),
        icon: const Icon(Icons.delete_outline),
      ),
      child: Column(
        children: [
          AppTextField(
            label: 'Enunciado',
            controller: desafio.enunciado,
            minLines: 2,
            maxLines: 5,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            label: 'Explicação do feedback',
            controller: desafio.explicacao,
            minLines: 2,
            maxLines: 5,
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: desafio.dificuldade,
            decoration: const InputDecoration(labelText: 'Dificuldade'),
            items: const [
              DropdownMenuItem(value: 'FACIL', child: Text('Fácil')),
              DropdownMenuItem(value: 'MEDIA', child: Text('Média')),
              DropdownMenuItem(value: 'DIFICIL', child: Text('Difícil')),
            ],
            onChanged: (value) {
              if (value != null) desafio.dificuldade = value;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          for (final (o, opcao) in desafio.opcoes.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Checkbox(
                    value: opcao.correta,
                    onChanged: (_) => setState(() {
                      for (final item in desafio.opcoes) {
                        item.correta = false;
                      }
                      opcao.correta = true;
                    }),
                  ),
                  Expanded(
                    child: AppTextField(
                      label: 'Opção ${o + 1}',
                      controller: opcao.texto,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Remover opção',
                    onPressed: () => setState(() {
                      desafio.opcoes.removeAt(o).dispose();
                    }),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          AppButton(
            label: 'Adicionar opção',
            size: AppButtonSize.small,
            variant: AppButtonVariant.outline,
            onPressed: () => setState(() => desafio.opcoes.add(_OpcaoEditor())),
          ),
        ],
      ),
    );
  }

  Widget _revisao() {
    final licoes = _modulos.fold<int>(
      0,
      (total, modulo) => total + modulo.licoes.length,
    );
    final desafios = _modulos.fold<int>(
      0,
      (total, modulo) =>
          total +
          modulo.licoes.fold<int>(
            0,
            (subtotal, licao) => subtotal + licao.desafios.length,
          ),
    );
    return AppSectionCard(
      title: '3. Revisão e publicação',
      subtitle: 'A versão publicada não será alterada por edições futuras.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_titulo.text, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _descricao.text.trim().isEmpty ? 'Sem descrição' : _descricao.text,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '${_modulos.length} módulo(s) • $licoes lição(ões) • $desafios desafio(s)',
          ),
        ],
      ),
    );
  }
}

class _EtapasIndicador extends StatelessWidget {
  const _EtapasIndicador({required this.etapa});
  final int etapa;

  @override
  Widget build(BuildContext context) {
    const labels = ['Dados', 'Conteúdo', 'Publicar'];
    Widget etapaChip(int i) => Chip(
      avatar: CircleAvatar(child: Text('${i + 1}')),
      label: Text(labels[i]),
      side: i == etapa
          ? BorderSide(color: Theme.of(context).colorScheme.primary)
          : null,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 520) {
          return Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [for (var i = 0; i < labels.length; i++) etapaChip(i)],
          );
        }

        return Row(
          children: [
            for (var i = 0; i < labels.length; i++) ...[
              if (i > 0) const Expanded(child: Divider()),
              etapaChip(i),
            ],
          ],
        );
      },
    );
  }
}

class _ModuloEditor {
  _ModuloEditor(this.titulo, this.licoes);
  factory _ModuloEditor.vazio() =>
      _ModuloEditor(TextEditingController(), [_LicaoEditor.vazia()]);
  factory _ModuloEditor.fromDto(ModuloTrilhaDto dto) => _ModuloEditor(
    TextEditingController(text: dto.titulo),
    dto.licoes.map(_LicaoEditor.fromDto).toList(),
  );
  final TextEditingController titulo;
  final List<_LicaoEditor> licoes;
  void dispose() {
    titulo.dispose();
    for (final item in licoes) {
      item.dispose();
    }
  }
}

class _LicaoEditor {
  _LicaoEditor(this.titulo, this.resumo, this.desafios);
  factory _LicaoEditor.vazia() => _LicaoEditor(
    TextEditingController(),
    TextEditingController(),
    [_DesafioEditor.vazio()],
  );
  factory _LicaoEditor.fromDto(LicaoTrilhaDto dto) => _LicaoEditor(
    TextEditingController(text: dto.titulo),
    TextEditingController(text: dto.resumo),
    dto.desafios.map(_DesafioEditor.fromDto).toList(),
  );
  final TextEditingController titulo;
  final TextEditingController resumo;
  final List<_DesafioEditor> desafios;
  void dispose() {
    titulo.dispose();
    resumo.dispose();
    for (final item in desafios) {
      item.dispose();
    }
  }
}

class _DesafioEditor {
  _DesafioEditor(
    this.enunciado,
    this.explicacao,
    this.dificuldade,
    this.opcoes,
  );
  factory _DesafioEditor.vazio() => _DesafioEditor(
    TextEditingController(),
    TextEditingController(),
    'FACIL',
    [_OpcaoEditor(correta: true), _OpcaoEditor()],
  );
  factory _DesafioEditor.fromDto(DesafioTrilhaDto dto) => _DesafioEditor(
    TextEditingController(text: dto.enunciado),
    TextEditingController(text: dto.explicacao),
    dto.dificuldade,
    dto.opcoes.map(_OpcaoEditor.fromDto).toList(),
  );
  final TextEditingController enunciado;
  final TextEditingController explicacao;
  String dificuldade;
  final List<_OpcaoEditor> opcoes;
  void dispose() {
    enunciado.dispose();
    explicacao.dispose();
    for (final item in opcoes) {
      item.dispose();
    }
  }
}

class _OpcaoEditor {
  _OpcaoEditor({String texto = '', this.correta = false})
    : texto = TextEditingController(text: texto);
  factory _OpcaoEditor.fromDto(OpcaoTrilhaDto dto) =>
      _OpcaoEditor(texto: dto.texto, correta: dto.correta);
  final TextEditingController texto;
  bool correta;
  void dispose() => texto.dispose();
}
