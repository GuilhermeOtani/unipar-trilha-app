import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/api_error.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/widgets/app_async_state.dart';
import 'package:unipar_trilha_app/core/widgets/app_design_frame.dart';
import 'package:unipar_trilha_app/core/widgets/app_message_banner.dart';
import 'package:unipar_trilha_app/core/widgets/profile_header.dart';
import 'package:unipar_trilha_app/modules/home/dto/professor_contexto_response.dart';
import 'package:unipar_trilha_app/modules/trilha/models/trilha_edicao.dart';
import 'package:unipar_trilha_app/modules/trilha/page/trilha_dados_page.dart';
import 'package:unipar_trilha_app/modules/trilha/page/trilha_modulos_page.dart';
import 'package:unipar_trilha_app/modules/trilha/page/trilha_licoes_page.dart';
import 'package:unipar_trilha_app/modules/trilha/page/trilha_desafios_page.dart';
import 'package:unipar_trilha_app/modules/trilha/service/trilha_service.dart';
import 'package:unipar_trilha_app/modules/trilha/widgets/cadastro_trilha_widgets.dart';

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
  TrilhaEdicao _edicao = TrilhaEdicao();
  EtapaTrilha _etapa = EtapaTrilha.dados;
  int? _trilhaId;
  int _m = 0, _l = 0, _d = 0;
  bool _carregando = false, _enviando = false, _alterouServidor = false;
  bool _saidaAberta = false;
  bool _revisando = false;
  String? _erroCarga, _erro, _sucesso;
  late String _assinaturaSalva;
  bool _conteudoSalvo = false;
  final _mensagemKey = GlobalKey();

  void _revelarMensagem() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mensagemContext = _mensagemKey.currentContext;
      if (mounted && mensagemContext != null) {
        Scrollable.ensureVisible(
          mensagemContext,
          duration: const Duration(milliseconds: 200),
          alignment: 0.1,
        );
      }
    });
  }

  void _exibirErro(String mensagem) {
    setState(() {
      _erro = mensagem;
      _sucesso = null;
    });
    _revelarMensagem();
  }

  List<TurmaProfessorResponse> get _disciplinas => {
    for (final t in widget.contexto.turmas) t.disciplinaId: t,
  }.values.toList();
  Set<int> get _idsDisciplinas =>
      _disciplinas.map((d) => d.disciplinaId).toSet();
  bool get _sujo => _edicao.assinatura != _assinaturaSalva;
  ModuloEdicao get _modulo => _edicao.modulos[_m];
  LicaoEdicao get _licao => _modulo.licoes[_l];
  DesafioEdicao get _desafio => _licao.desafios[_d];

  @override
  void initState() {
    super.initState();
    _trilhaId = widget.trilhaId;
    _edicao.disciplinaId = _disciplinas.isEmpty
        ? null
        : _disciplinas.first.disciplinaId;
    _assinaturaSalva = _edicao.assinatura;
    if (_trilhaId != null) _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erroCarga = null;
    });
    try {
      final trilha = await widget.service.buscar(_trilhaId!);
      if (!mounted) return;
      setState(() {
        _edicao = TrilhaEdicao.fromDto(trilha);
        _assinaturaSalva = _edicao.assinatura;
        _conteudoSalvo = _edicao.validar(_idsDisciplinas) == null;
      });
    } on ApiError catch (error) {
      if (mounted) setState(() => _erroCarga = error.message);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _mudou() => setState(() {
    _sucesso = null;
    _erro = null;
  });

  void _ir(EtapaTrilha etapa) {
    if (_enviando) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _erro = null;
      _sucesso = null;
      if (etapa.index >= EtapaTrilha.modulos.index) {
        if (_edicao.modulos.isEmpty) _edicao.modulos.add(ModuloEdicao());
        _m = _m.clamp(0, _edicao.modulos.length - 1);
      }
      if (etapa.index >= EtapaTrilha.licoes.index) {
        if (_modulo.licoes.isEmpty) _modulo.licoes.add(LicaoEdicao());
        _l = _l.clamp(0, _modulo.licoes.length - 1);
      }
      if (etapa == EtapaTrilha.desafios) {
        if (_licao.desafios.isEmpty) _licao.desafios.add(DesafioEdicao());
        _d = _d.clamp(0, _licao.desafios.length - 1);
      }
      _etapa = etapa;
    });
  }

  void _mostrarPendencia(PendenciaTrilha erro) {
    _m = erro.modulo ?? _m;
    _l = erro.licao ?? 0;
    _d = erro.desafio ?? 0;
    _ir(erro.etapa);
    _exibirErro(erro.mensagem);
  }

  Future<void> _criar() async {
    if (_enviando) return;
    final erro = _edicao.validarDados(_idsDisciplinas);
    if (erro != null) {
      _mostrarPendencia(erro);
      return;
    }
    if (_trilhaId == null) {
      setState(() {
        _enviando = true;
        _erro = null;
      });
      try {
        final trilha = await widget.service.criar(_edicao.basico);
        if (!mounted) return;
        _trilhaId = trilha.id;
        _alterouServidor = true;
        _assinaturaSalva = _edicao.assinatura;
      } on ApiError catch (error) {
        if (mounted) _exibirErro(error.message);
        return;
      } finally {
        if (mounted) setState(() => _enviando = false);
      }
    }
    if (mounted) _ir(EtapaTrilha.modulos);
  }

  void _abrirLicoes() {
    final erro = validarTexto(_modulo.titulo, 'título do módulo', 160);
    if (erro != null) {
      _exibirErro(erro);
      return;
    }
    _ir(EtapaTrilha.licoes);
  }

  void _abrirDesafios() {
    final erro = _licao.validar();
    if (erro != null) {
      _exibirErro(erro);
      return;
    }
    _ir(EtapaTrilha.desafios);
  }

  Future<void> _salvar() async {
    if (_enviando || _trilhaId == null) return;
    final erro = _edicao.validar(_idsDisciplinas);
    if (erro != null) {
      _mostrarPendencia(erro);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _enviando = true;
      _erro = null;
      _sucesso = null;
    });
    try {
      await widget.service.atualizar(_trilhaId!, _edicao.conteudo);
      if (!mounted) return;
      setState(() {
        _assinaturaSalva = _edicao.assinatura;
        _conteudoSalvo = true;
        _alterouServidor = true;
        _sucesso =
            'Rascunho salvo. Você pode continuar editando ou revisar e publicar.';
      });
      _revelarMensagem();
    } on ApiError catch (error) {
      if (mounted) {
        _exibirErro(
          '${error.message} Seus dados continuam preenchidos. Tente salvar novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<void> _publicar() async {
    if (_enviando || _revisando || _sujo || !_conteudoSalvo) return;
    _revisando = true;
    try {
      final confirmado = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Revisar e publicar'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _edicao.titulo,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_edicao.descricao.trim().isNotEmpty)
                  Text(_edicao.descricao),
                for (final modulo in _edicao.modulos) ...[
                  const SizedBox(height: 12),
                  Text(
                    modulo.titulo,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  for (final licao in modulo.licoes)
                    Text(
                      '${licao.titulo} · ${licao.desafios.length} desafio(s)',
                    ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'A publicação cria uma nova versão. Edições futuras do rascunho não alteram essa versão.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Publicar versão'),
            ),
          ],
        ),
      );
      if (confirmado != true || !mounted) return;
      setState(() {
        _enviando = true;
        _erro = null;
        _sucesso = null;
      });
      await widget.service.publicar(_trilhaId!);
      if (!mounted) return;
      _alterouServidor = true;
      Navigator.of(context).pop(true);
    } on ApiError catch (error) {
      if (mounted) {
        _exibirErro(
          '${error.message} O rascunho está salvo. Tente publicar novamente.',
        );
      }
    } finally {
      _revisando = false;
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<void> _sair() async {
    if (_enviando || _saidaAberta) return;
    _saidaAberta = true;
    try {
      if (_sujo) {
        final sair = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sair sem salvar?'),
            content: const Text(
              'As alterações não salvas serão perdidas. O último rascunho salvo continuará disponível.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Continuar editando'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sair sem salvar'),
              ),
            ],
          ),
        );
        if (sair != true || !mounted) return;
      }
      if (mounted) Navigator.of(context).pop(_alterouServidor);
    } finally {
      _saidaAberta = false;
    }
  }

  void _voltar() {
    if (_enviando || _saidaAberta) return;
    if (_etapa == EtapaTrilha.dados || _erroCarga != null) {
      _sair();
    } else {
      _ir(EtapaTrilha.values[_etapa.index - 1]);
    }
  }

  Future<void> _remover(String nome, VoidCallback remover) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remover $nome?'),
        content: const Text(
          'O conteúdo deste item também será removido do rascunho em edição.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmou == true && mounted) {
      setState(remover);
      _ir(_etapa);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: BorderSide.none,
    );
    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _voltar();
      },
      child: Theme(
        data: theme.copyWith(
          textTheme: theme.textTheme.copyWith(
            bodyLarge: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          inputDecorationTheme: theme.inputDecorationTheme.copyWith(
            isDense: true,
            fillColor: colors.trailBlueTrack,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            labelStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
            border: fieldBorder,
            enabledBorder: fieldBorder,
            disabledBorder: fieldBorder,
            focusedBorder: fieldBorder.copyWith(
              borderSide: BorderSide(color: colors.borderFocus),
            ),
          ),
        ),
        child: AppDesignPage(
          fillViewport: false,
          key: ValueKey('$_etapa-$_m-$_l-$_d'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(9.5, 21, 9.5, 20),
                child: ProfileHeader(name: widget.contexto.professorNome),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.trilhaId == null
                            ? 'Nova trilha'
                            : 'Editar trilha',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Voltar para Trilhas',
                      onPressed: _enviando ? null : _sair,
                      icon: const Icon(Icons.close, size: 18),
                    ),
                  ],
                ),
              ),
              if (_carregando)
                const AppLoadingState(message: 'Carregando rascunho...')
              else if (_erroCarga != null)
                AppErrorState(message: _erroCarga!, onRetry: _carregar)
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 19),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CadastroBloqueio(
                        absorbing: _enviando,
                        child: CadastroEtapas(
                          etapa: _etapa.index.clamp(0, 2),
                          temTrilha: _trilhaId != null,
                          temModulo: _edicao.modulos.isNotEmpty,
                          onSelected: (i) => _ir(EtapaTrilha.values[i]),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_erro != null) ...[
                        AppMessageBanner(key: _mensagemKey, message: _erro!),
                        const SizedBox(height: 10),
                      ],
                      if (_sucesso != null) ...[
                        AppMessageBanner(
                          key: _mensagemKey,
                          message: _sucesso!,
                          kind: AppMessageKind.info,
                        ),
                        const SizedBox(height: 10),
                      ],
                      if (_etapa.index >= 2)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            _etapa == EtapaTrilha.desafios
                                ? '${_modulo.titulo} / ${_licao.titulo}'
                                : 'Módulo: ${_modulo.titulo}',
                            style: TextStyle(
                              fontSize: 10,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      CadastroBloqueio(
                        absorbing: _enviando || _saidaAberta,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            switch (_etapa) {
                              EtapaTrilha.dados => TrilhaDadosPage(
                                key: ObjectKey(_edicao),
                                edicao: _edicao,
                                disciplinas: _disciplinas,
                                onChanged: _mudou,
                                onCriar: _criar,
                                existente: _trilhaId != null,
                              ),
                              EtapaTrilha.modulos => TrilhaModulosPage(
                                key: ObjectKey(_modulo),
                                modulo: _modulo,
                                onChanged: _mudou,
                                onCriar: _abrirLicoes,
                              ),
                              EtapaTrilha.licoes => TrilhaLicoesPage(
                                key: ObjectKey(_licao),
                                licao: _licao,
                                onChanged: _mudou,
                                onCriar: _abrirDesafios,
                              ),
                              EtapaTrilha.desafios => TrilhaDesafiosPage(
                                key: ObjectKey(_desafio),
                                desafio: _desafio,
                                onChanged: _mudou,
                                onSalvar: _salvar,
                              ),
                            },
                            if (_etapa.index >= 2) ...[
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: CadastroAcao(
                                      label: _etapa == EtapaTrilha.licoes
                                          ? 'Voltar para Trilhas'
                                          : 'Voltar para Módulos',
                                      onPressed: _etapa == EtapaTrilha.licoes
                                          ? _sair
                                          : () => _ir(EtapaTrilha.modulos),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: CadastroAcao(
                                      label: _etapa == EtapaTrilha.licoes
                                          ? 'Voltar para Módulos'
                                          : 'Voltar para Lições',
                                      onPressed: () => _ir(
                                        _etapa == EtapaTrilha.licoes
                                            ? EtapaTrilha.modulos
                                            : EtapaTrilha.licoes,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (_etapa == EtapaTrilha.modulos)
                              CadastroItens(
                                titulo: 'Módulo',
                                itens: _edicao.modulos
                                    .map((m) => m.titulo)
                                    .toList(),
                                selecionado: _m,
                                onSelecionar: (i) {
                                  _m = i;
                                  _l = 0;
                                  _d = 0;
                                  _ir(EtapaTrilha.modulos);
                                },
                                onAdicionar: () {
                                  _edicao.modulos.add(ModuloEdicao());
                                  _m = _edicao.modulos.length - 1;
                                  _l = 0;
                                  _d = 0;
                                  _ir(EtapaTrilha.modulos);
                                },
                                onRemover: (i) => _remover('módulo', () {
                                  _edicao.modulos.removeAt(i);
                                  _m = 0;
                                  _l = 0;
                                  _d = 0;
                                }),
                              ),
                            if (_etapa == EtapaTrilha.licoes)
                              CadastroItens(
                                titulo: 'Lição',
                                itens: _modulo.licoes
                                    .map((l) => l.titulo)
                                    .toList(),
                                selecionado: _l,
                                onSelecionar: (i) {
                                  _l = i;
                                  _d = 0;
                                  _ir(EtapaTrilha.licoes);
                                },
                                onAdicionar: () {
                                  _modulo.licoes.add(LicaoEdicao());
                                  _l = _modulo.licoes.length - 1;
                                  _d = 0;
                                  _ir(EtapaTrilha.licoes);
                                },
                                onRemover: (i) => _remover('lição', () {
                                  _modulo.licoes.removeAt(i);
                                  _l = 0;
                                  _d = 0;
                                }),
                              ),
                            if (_etapa == EtapaTrilha.desafios)
                              CadastroItens(
                                titulo: 'Desafio',
                                itens: _licao.desafios
                                    .map((d) => d.enunciado)
                                    .toList(),
                                selecionado: _d,
                                onSelecionar: (i) {
                                  _d = i;
                                  _ir(EtapaTrilha.desafios);
                                },
                                onAdicionar: () {
                                  _licao.desafios.add(DesafioEdicao());
                                  _d = _licao.desafios.length - 1;
                                  _ir(EtapaTrilha.desafios);
                                },
                                onRemover: (i) => _remover('desafio', () {
                                  _licao.desafios.removeAt(i);
                                  _d = 0;
                                }),
                              ),
                          ],
                        ),
                      ),
                      if (_enviando)
                        const AppLoadingState(message: 'Processando...'),
                      if (_trilhaId != null) ...[
                        const SizedBox(height: 12),
                        if (_etapa != EtapaTrilha.desafios)
                          TextButton(
                            onPressed: _enviando ? null : _salvar,
                            child: const Text('Salvar rascunho'),
                          ),
                        TextButton(
                          onPressed: _enviando || _sujo || !_conteudoSalvo
                              ? null
                              : _publicar,
                          child: const Text('Revisar e publicar'),
                        ),
                        Text(
                          _sujo
                              ? 'Alterações ainda não salvas.'
                              : 'Rascunho salvo.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
