import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/api_error.dart';
import 'package:unipar_trilha_app/core/widgets/app_async_state.dart';
import 'package:unipar_trilha_app/core/widgets/app_button.dart';
import 'package:unipar_trilha_app/core/widgets/app_empty_state.dart';
import 'package:unipar_trilha_app/core/widgets/app_page.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/dto/resposta_aluno_request.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/models/desafio_pratica.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/page/pratica_page.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/service/aprendizagem_service.dart';

/// Liga as telas 4–6 à API: inicia ou retoma a sessão da distribuição,
/// envia as respostas e avança com `proximoDesafio`.
///
/// Recebe o service opcionalmente (testes e pré-visualização); em execução
/// normal usa o `AprendizagemService` real.
class SessaoPraticaPage extends StatefulWidget {
  const SessaoPraticaPage({
    super.key,
    required this.distribuicaoId,
    required this.onVoltar,
    this.service,
  });

  final int distribuicaoId;
  final VoidCallback onVoltar;
  final AprendizagemService? service;

  @override
  State<SessaoPraticaPage> createState() => _SessaoPraticaPageState();
}

class _SessaoPraticaPageState extends State<SessaoPraticaPage> {
  late final AprendizagemService _service =
      widget.service ?? AprendizagemService();

  int? _sessaoId;
  DesafioPratica? _desafio;
  bool _carregando = true;
  bool _concluida = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final sessao = await _service.iniciarOuRetomar(widget.distribuicaoId);
      if (!mounted) return;
      final desafio = sessao.desafioAtual;
      setState(() {
        _sessaoId = sessao.sessaoId;
        _desafio = desafio == null
            ? null
            : DesafioPratica.fromSessao(desafio, sessao.progresso);
        _concluida = desafio == null;
      });
    } on ApiError catch (error) {
      if (mounted) setState(() => _erro = error.message);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<CorrecaoPratica> _responder(
    DesafioPratica desafio,
    OpcaoPratica opcao,
  ) async {
    final resposta = await _service.responder(
      _sessaoId!,
      RespostaAlunoRequest(desafioId: desafio.id, opcaoId: opcao.id),
    );
    return CorrecaoPratica.fromResposta(resposta);
  }

  void _continuar(CorrecaoPratica correcao) {
    setState(() {
      _desafio = correcao.proximoDesafio;
      _concluida = correcao.concluida || correcao.proximoDesafio == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final desafio = _desafio;
    if (!_carregando && _erro == null && !_concluida && desafio != null) {
      return PraticaPage(
        key: ValueKey(desafio.id),
        desafio: desafio,
        onResponder: _responder,
        onVoltar: widget.onVoltar,
        onContinuar: _continuar,
      );
    }

    return AppPage(
      scrollable: false,
      body: Center(
        child: _carregando
            ? const AppLoadingState(message: 'Carregando desafio...')
            : _erro != null
            ? AppErrorState(message: _erro!, onRetry: _carregar)
            : AppEmptyState(
                title: 'Trilha concluída!',
                message: 'Você respondeu todos os desafios desta trilha.',
                action: AppButton(
                  label: 'Voltar à Trilha',
                  size: AppButtonSize.small,
                  onPressed: widget.onVoltar,
                ),
              ),
      ),
    );
  }
}
