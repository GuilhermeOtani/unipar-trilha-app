import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/widgets/app_button.dart';
import 'package:unipar_trilha_app/core/widgets/app_text_field.dart';

/// Bloqueia tanto os toques quanto a edição por teclado durante o envio.
class CadastroBloqueio extends StatelessWidget {
  const CadastroBloqueio({
    super.key,
    required this.absorbing,
    required this.child,
  });
  final bool absorbing;
  final Widget child;
  @override
  Widget build(BuildContext context) => ExcludeFocus(
    excluding: absorbing,
    child: AbsorbPointer(absorbing: absorbing, child: child),
  );
}

class CadastroCampo extends StatelessWidget {
  const CadastroCampo({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.lines = 1,
    this.maxLines,
  });
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final int lines;
  final int? maxLines;
  @override
  Widget build(BuildContext context) => AppTextField(
    label: label,
    initialValue: value,
    onChanged: onChanged,
    minLines: lines,
    maxLines: maxLines ?? (lines == 1 ? 1 : lines + 2),
  );
}

class CadastroPainel extends StatelessWidget {
  const CadastroPainel({
    super.key,
    required this.title,
    required this.children,
    this.minHeight = 0,
  });
  final String title;
  final List<Widget> children;
  final double minHeight;
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceDefault,
        border: Border.all(color: colors.borderGoal, width: 1.5),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colors.textOnSurface,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class CadastroAcao extends StatelessWidget {
  const CadastroAcao({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  @override
  Widget build(BuildContext context) => AppButton(
    label: label,
    onPressed: onPressed,
    isLoading: loading,
    size: AppButtonSize.small,
    backgroundColor: AppColors.of(context).trailBlueAction,
    labelStyle: Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(fontSize: 12, fontWeight: FontWeight.w800),
  );
}

class CadastroItens extends StatelessWidget {
  const CadastroItens({
    super.key,
    required this.titulo,
    required this.itens,
    required this.selecionado,
    required this.onSelecionar,
    required this.onRemover,
    required this.onAdicionar,
  });
  final String titulo;
  final List<String> itens;
  final int selecionado;
  final ValueChanged<int> onSelecionar;
  final ValueChanged<int> onRemover;
  final VoidCallback onAdicionar;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SizedBox(height: 16),
      Text(
        titulo,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
      for (var i = 0; i < itens.length; i++)
        ListTile(
          key: ValueKey('$titulo-$i'),
          contentPadding: EdgeInsets.zero,
          dense: true,
          selected: i == selecionado,
          title: Text(
            itens[i].trim().isEmpty ? 'Sem título' : itens[i],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          leading: Icon(
            i == selecionado ? Icons.edit_outlined : Icons.chevron_right,
            size: 18,
          ),
          onTap: () => onSelecionar(i),
          trailing: IconButton(
            tooltip: 'Remover ${titulo.toLowerCase()} ${i + 1}',
            onPressed: () => onRemover(i),
            icon: const Icon(Icons.delete_outline, size: 18),
          ),
        ),
      TextButton(
        onPressed: onAdicionar,
        child: Text(
          'Adicionar ${titulo.toLowerCase()}',
          style: const TextStyle(fontSize: 12),
        ),
      ),
    ],
  );
}

class CadastroEtapas extends StatelessWidget {
  const CadastroEtapas({
    super.key,
    required this.etapa,
    required this.onSelected,
    required this.temTrilha,
    required this.temModulo,
  });
  final int etapa;
  final ValueChanged<int> onSelected;
  final bool temTrilha;
  final bool temModulo;
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    const nomes = ['1. Dados', '2. Módulos', '3. Lições'];
    return Row(
      children: [
        for (var i = 0; i < nomes.length; i++) ...[
          if (i > 0) Expanded(child: Divider(color: colors.borderGoal)),
          Semantics(
            selected: i == etapa,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: i == etapa
                    ? colors.trailBlueTrack
                    : colors.surfaceInfo,
                foregroundColor: colors.textOnSurface,
                minimumSize: const Size(0, 26),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(fontSize: 8.5),
                shape: const StadiumBorder(),
              ),
              onPressed:
                  i == 0 || (i == 1 && temTrilha) || (i == 2 && temModulo)
                  ? () => onSelected(i)
                  : null,
              child: Text(nomes[i]),
            ),
          ),
        ],
      ],
    );
  }
}
