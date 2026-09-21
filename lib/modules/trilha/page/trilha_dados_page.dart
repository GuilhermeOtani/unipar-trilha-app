import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/modules/home/dto/professor_contexto_response.dart';
import 'package:unipar_trilha_app/modules/trilha/models/trilha_edicao.dart';
import 'package:unipar_trilha_app/modules/trilha/widgets/cadastro_trilha_widgets.dart';

class TrilhaDadosPage extends StatelessWidget {
  const TrilhaDadosPage({
    super.key,
    required this.edicao,
    required this.disciplinas,
    required this.onChanged,
    required this.onCriar,
    required this.existente,
  });
  final TrilhaEdicao edicao;
  final List<TurmaProfessorResponse> disciplinas;
  final VoidCallback onChanged;
  final VoidCallback onCriar;
  final bool existente;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      CadastroPainel(
        title: 'Informações da Trilha',
        children: [
          CadastroCampo(
            label: 'Título',
            value: edicao.titulo,
            onChanged: (v) {
              edicao.titulo = v;
              onChanged();
            },
          ),
          const SizedBox(height: 20),
          CadastroCampo(
            label: 'Descrição',
            value: edicao.descricao,
            lines: 3,
            onChanged: (v) {
              edicao.descricao = v;
              onChanged();
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Disciplina à qual pertence',
            style: TextStyle(fontSize: 11),
          ),
          const SizedBox(height: 5),
          DropdownButtonFormField<int>(
            key: ValueKey(edicao.disciplinaId),
            isExpanded: true,
            initialValue:
                disciplinas.any((d) => d.disciplinaId == edicao.disciplinaId)
                ? edicao.disciplinaId
                : null,
            decoration: const InputDecoration(
              hintText: 'Selecione a disciplina',
            ),
            style: Theme.of(context).textTheme.bodyLarge,
            items: [
              for (final d in disciplinas)
                DropdownMenuItem(
                  value: d.disciplinaId,
                  child: Text(
                    d.disciplinaNome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (v) {
              edicao.disciplinaId = v;
              onChanged();
            },
          ),
          if (disciplinas.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Nenhuma disciplina vinculada.'),
            ),
          const SizedBox(height: 12),
        ],
      ),
      const SizedBox(height: 26),
      Center(
        child: SizedBox(
          width: 192,
          child: CadastroAcao(
            label: existente ? 'Continuar' : 'Criar',
            onPressed: disciplinas.isEmpty ? null : onCriar,
          ),
        ),
      ),
    ],
  );
}
