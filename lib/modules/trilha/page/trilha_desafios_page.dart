import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/modules/trilha/models/trilha_edicao.dart';
import 'package:unipar_trilha_app/modules/trilha/widgets/cadastro_trilha_widgets.dart';

class TrilhaDesafiosPage extends StatelessWidget {
  const TrilhaDesafiosPage({
    super.key,
    required this.desafio,
    required this.onChanged,
    required this.onSalvar,
  });
  final DesafioEdicao desafio;
  final VoidCallback onChanged;
  final VoidCallback onSalvar;
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return CadastroPainel(
      title: 'Criação de Desafios',
      children: [
        CadastroCampo(
          label: 'Enunciado',
          value: desafio.enunciado,
          onChanged: (v) {
            desafio.enunciado = v;
            onChanged();
          },
          maxLines: 4,
        ),
        const SizedBox(height: 8),
        CadastroCampo(
          label: 'Feedback',
          value: desafio.feedback,
          onChanged: (v) {
            desafio.feedback = v;
            onChanged();
          },
          maxLines: 4,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          style: Theme.of(context).textTheme.bodyLarge,
          initialValue:
              ['FACIL', 'MEDIA', 'DIFICIL'].contains(desafio.dificuldade)
              ? desafio.dificuldade
              : null,
          decoration: const InputDecoration(labelText: 'Dificuldade'),
          items: const [
            DropdownMenuItem(value: 'FACIL', child: Text('Fácil')),
            DropdownMenuItem(value: 'MEDIA', child: Text('Média')),
            DropdownMenuItem(value: 'DIFICIL', child: Text('Difícil')),
          ],
          onChanged: (v) {
            if (v != null) {
              desafio.dificuldade = v;
              onChanged();
            }
          },
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < desafio.opcoes.length; i++)
          Padding(
            key: ObjectKey(desafio.opcoes[i]),
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Semantics(
                  checked: desafio.opcoes[i].correta,
                  inMutuallyExclusiveGroup: true,
                  child: IconButton(
                    tooltip: 'Marcar opção ${i + 1} como correta',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 32,
                    ),
                    icon: Icon(
                      desafio.opcoes[i].correta
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: colors.trailCyanAction,
                      size: 22,
                    ),
                    onPressed: () {
                      for (final o in desafio.opcoes) {
                        o.correta = identical(o, desafio.opcoes[i]);
                      }
                      onChanged();
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: CadastroCampo(
                    label: 'Opção ${i + 1}',
                    value: desafio.opcoes[i].texto,
                    onChanged: (v) {
                      desafio.opcoes[i].texto = v;
                      onChanged();
                    },
                  ),
                ),
                IconButton(
                  tooltip: 'Remover opção ${i + 1}',
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: desafio.opcoes.length <= 2
                      ? null
                      : () {
                          final removida = desafio.opcoes.removeAt(i);
                          if (removida.correta) {
                            desafio.opcoes.first.correta = true;
                          }
                          onChanged();
                        },
                  icon: const Icon(Icons.close, size: 26),
                ),
              ],
            ),
          ),
        Center(
          child: CadastroAcao(
            label: 'Adicionar mais opções',
            onPressed: () {
              desafio.opcoes.add(OpcaoEdicao());
              onChanged();
            },
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton.filled(
            key: const Key('salvar-trilha'),
            tooltip: 'Salvar rascunho',
            onPressed: onSalvar,
            style: IconButton.styleFrom(
              backgroundColor: colors.actionInfo,
              foregroundColor: colors.textOnSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.save_outlined, size: 34),
          ),
        ),
      ],
    );
  }
}
