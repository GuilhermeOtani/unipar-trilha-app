import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/modules/trilha/models/trilha_edicao.dart';
import 'package:unipar_trilha_app/modules/trilha/widgets/cadastro_trilha_widgets.dart';

class TrilhaModulosPage extends StatelessWidget {
  const TrilhaModulosPage({
    super.key,
    required this.modulo,
    required this.onChanged,
    required this.onCriar,
  });
  final ModuloEdicao modulo;
  final VoidCallback onChanged;
  final VoidCallback onCriar;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      CadastroPainel(
        title: 'Criação de Módulos',
        children: [
          CadastroCampo(
            label: 'Título',
            value: modulo.titulo,
            onChanged: (v) {
              modulo.titulo = v;
              onChanged();
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
      const SizedBox(height: 30),
      Center(
        child: SizedBox(
          width: 192,
          child: CadastroAcao(
            label: modulo.licoes.isEmpty ? 'Criar' : 'Abrir lições',
            onPressed: onCriar,
          ),
        ),
      ),
    ],
  );
}
