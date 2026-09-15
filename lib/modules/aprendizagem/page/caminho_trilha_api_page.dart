import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/api_error.dart';
import 'package:unipar_trilha_app/core/widgets/app_async_state.dart';
import 'package:unipar_trilha_app/core/widgets/app_page.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/models/caminho_trilha.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/page/caminho_trilha_page.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/page/sessao_pratica_page.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/service/aprendizagem_service.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/models/trilha_resumo.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/service/catalogo_aluno_service.dart';
import 'package:unipar_trilha_app/shared/models/aluno_resumo.dart';

class CaminhoTrilhaApiPage extends StatefulWidget {
  const CaminhoTrilhaApiPage({
    super.key,
    required this.aluno,
    required this.trilha,
    required this.catalogoService,
    required this.aprendizagemService,
    required this.onAtualizado,
  });

  final AlunoResumo aluno;
  final TrilhaResumo trilha;
  final CatalogoAlunoServiceContract catalogoService;
  final AprendizagemServiceContract aprendizagemService;
  final VoidCallback onAtualizado;

  @override
  State<CaminhoTrilhaApiPage> createState() => _CaminhoTrilhaApiPageState();
}

class _CaminhoTrilhaApiPageState extends State<CaminhoTrilhaApiPage> {
  CaminhoTrilha? _caminho;
  String? _erro;
  bool _carregando = true;
  int _operacao = 0;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final operacao = ++_operacao;
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final response = await widget.catalogoService.buscarCaminho(
        widget.trilha.id,
      );
      if (!mounted || operacao != _operacao) return;
      setState(
        () => _caminho = CaminhoTrilha.fromResponse(response, widget.trilha),
      );
    } on ApiError catch (error) {
      if (mounted && operacao == _operacao) {
        setState(() => _erro = error.message);
      }
    } finally {
      if (mounted && operacao == _operacao) setState(() => _carregando = false);
    }
  }

  Future<void> _abrirPratica(LicaoCaminho _) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => SessaoPraticaPage(
          distribuicaoId: widget.trilha.id,
          service: widget.aprendizagemService,
          onVoltar: () => Navigator.of(context).pop(),
        ),
      ),
    );
    if (!mounted) return;
    widget.onAtualizado();
    await _carregar();
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const AppPage(
        body: Center(child: AppLoadingState(message: 'Carregando caminho...')),
      );
    }
    if (_erro != null) {
      return AppPage(
        body: Center(
          child: AppErrorState(message: _erro!, onRetry: _carregar),
        ),
      );
    }
    return CaminhoTrilhaPage(
      aluno: widget.aluno,
      caminho: _caminho!,
      onSelecionarLicao: _abrirPratica,
    );
  }
}
