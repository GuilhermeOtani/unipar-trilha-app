import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/modules/trilha/models/trilha_edicao.dart';
import 'package:unipar_trilha_app/modules/trilha/widgets/cadastro_trilha_widgets.dart';

class TrilhaLicoesPage extends StatelessWidget {
  const TrilhaLicoesPage({
    super.key,
    required this.licao,
    required this.onChanged,
    required this.onCriar,
  });
  final LicaoEdicao licao;
  final VoidCallback onChanged;
  final VoidCallback onCriar;
  @override
  Widget build(BuildContext context) => CadastroPainel(
    title: 'Criação de Lições',
    children: [
      CadastroCampo(
        label: 'Título',
        value: licao.titulo,
        onChanged: (v) {
          licao.titulo = v;
          onChanged();
        },
      ),
      const SizedBox(height: 10),
      CadastroCampo(
        label: 'Resumo',
        value: licao.resumo,
        lines: 3,
        onChanged: (v) {
          licao.resumo = v;
          onChanged();
        },
      ),
      const SizedBox(height: 115),
      Center(
        child: SizedBox(
          width: 140,
          child: CadastroAcao(
            label: licao.desafios.isEmpty ? 'Criar' : 'Abrir desafios',
            onPressed: onCriar,
          ),
        ),
      ),
    ],
  );
}
