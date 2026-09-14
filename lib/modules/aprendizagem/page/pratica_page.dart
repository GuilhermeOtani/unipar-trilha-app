import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/api_error.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/theme/app_typography.dart';
import 'package:unipar_trilha_app/core/widgets/app_back_link.dart';
import 'package:unipar_trilha_app/core/widgets/app_button.dart';
import 'package:unipar_trilha_app/core/widgets/app_design_frame.dart';
import 'package:unipar_trilha_app/core/widgets/app_progress.dart';
import 'package:unipar_trilha_app/core/widgets/feedback_card.dart';
import 'package:unipar_trilha_app/core/widgets/quiz_option.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/models/desafio_pratica.dart';

/// Telas 4, 5 e 6 — Prática de uma questão.
///
/// Uma única página com três estados:
/// - tela 4: alternativa selecionada e "Enviar resposta";
/// - tela 5: resposta incorreta e feedback; escolher outra alternativa inicia
///   a nova tentativa, como no wireframe (sem botão extra);
/// - tela 6: resposta correta, feedback e "Continuar".
///
/// Canvas de 360 dp (medidas do wireframe):
///
/// | Bloco | Topo | Margens laterais |
/// |---|---|---|
/// | "Voltar à Trilha" (20,3 dp) | 9 dp | 9 dp |
/// | "Questão n de total" + segmentos | 44,3 dp | 9 / 26,3 dp |
/// | enunciado Inter 17,3 sp | 77,7 dp | 10 / 12 dp |
/// | "Selecione uma alternativa" 9,8 sp | 99,7 dp | 12,3 dp |
/// | alternativas (47,6 dp, 10 dp entre elas) | 123,7 dp | 18,3 dp |
/// | botão 160 × 28 dp centralizado | +16,6 dp | — |
/// | feedback (mín. 206 dp) | +10 dp | 18,3 dp |
class PraticaPage extends StatefulWidget {
  const PraticaPage({
    super.key,
    required this.desafio,
    required this.onResponder,
    required this.onVoltar,
    required this.onContinuar,
  });

  final DesafioPratica desafio;
  final ResponderDesafio onResponder;
  final VoidCallback onVoltar;

  /// Chamado por "Continuar" após um acerto, com a correção recebida
  /// (`proximoDesafio` e `concluida`).
  final ValueChanged<CorrecaoPratica> onContinuar;

  @override
  State<PraticaPage> createState() => _PraticaPageState();
}

class _PraticaPageState extends State<PraticaPage> {
  OpcaoPratica? _selecionada;
  CorrecaoPratica? _correcao;
  bool _enviando = false;

  Future<void> _enviar() async {
    final opcao = _selecionada;
    if (opcao == null || _enviando) return;
    setState(() => _enviando = true);
    try {
      final correcao = await widget.onResponder(widget.desafio, opcao);
      if (!mounted) return;
      setState(() => _correcao = correcao);
    } catch (error) {
      if (!mounted) return;
      // A seleção é mantida para o aluno reenviar manualmente.
      final mensagem = error is ApiError
          ? error.message
          : 'Não foi possível enviar a resposta. Tente novamente.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagem)));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  /// Seleciona uma alternativa. Após um erro, inicia a nova tentativa.
  void _selecionar(OpcaoPratica opcao) => setState(() {
    _selecionada = opcao;
    _correcao = null;
  });

  QuizOptionState _estado(OpcaoPratica opcao) {
    if (opcao != _selecionada) return QuizOptionState.idle;
    final correcao = _correcao;
    if (correcao == null) return QuizOptionState.selected;
    return correcao.correta
        ? QuizOptionState.correct
        : QuizOptionState.incorrect;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final desafio = widget.desafio;
    final correcao = _correcao;
    final bloqueada = _enviando || (correcao?.correta ?? false);

    return AppDesignPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 7),
          Align(
            alignment: Alignment.centerLeft,
            child: AppBackLink(
              label: 'Voltar à Trilha',
              onPressed: widget.onVoltar,
            ),
          ),
          const SizedBox(height: 13),
          Padding(
            padding: const EdgeInsets.fromLTRB(9, 0, 26.3, 0),
            child: QuizStepper(current: desafio.numero, total: desafio.total),
          ),
          const SizedBox(height: 16.4),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 12, 0),
            child: Text(
              desafio.enunciado,
              style: textTheme.titleLarge?.copyWith(
                fontSize: 17.3,
                fontWeight: FontWeight.w400,
                height: 1.29,
                color: colors.textOnSurface,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12.3, 0, 12, 0),
            child: Text(
              'Selecione uma alternativa',
              style: textTheme.bodySmall?.copyWith(
                fontSize: 9.8,
                height: 1,
                color: colors.textAccent,
              ),
            ),
          ),
          const SizedBox(height: 15.4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < desafio.opcoes.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  QuizOption(
                    label: String.fromCharCode(97 + i),
                    text: desafio.opcoes[i].texto,
                    state: _estado(desafio.opcoes[i]),
                    onTap: bloqueada
                        ? null
                        : () => _selecionar(desafio.opcoes[i]),
                  ),
                ],
              ],
            ),
          ),
          if (correcao == null) ...[
            const SizedBox(height: 16.6),
            Center(
              child: SizedBox(
                width: 160,
                child: AppButton(
                  label: 'Enviar resposta',
                  variant: AppButtonVariant.confirm,
                  size: AppButtonSize.small,
                  expanded: true,
                  isLoading: _enviando,
                  labelStyle: textTheme.labelLarge?.copyWith(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12.3,
                    fontWeight: FontWeight.w400,
                  ),
                  onPressed: _selecionada == null ? null : _enviar,
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.3),
              child: FeedbackCard(
                variant: correcao.correta
                    ? FeedbackVariant.success
                    : FeedbackVariant.danger,
                title: correcao.correta
                    ? 'Isso aí, excelente!'
                    : 'Não foi dessa vez...',
                message: correcao.explicacao,
                code: correcao.codigo,
                hint: correcao.dica,
                action: correcao.correta
                    ? AppButton(
                        label: 'Continuar',
                        variant: AppButtonVariant.confirm,
                        size: AppButtonSize.small,
                        onPressed: () => widget.onContinuar(correcao),
                      )
                    : null,
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
