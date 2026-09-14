import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/widgets/profile_header.dart';
import 'package:unipar_trilha_app/shared/models/aluno_resumo.dart';
import 'package:unipar_trilha_app/shared/widgets/sequencia_badge.dart';

/// Cabeçalho do aluno compartilhado pelas telas 1, 2 e 3.
class AlunoHeader extends StatelessWidget {
  const AlunoHeader({super.key, required this.aluno});

  final AlunoResumo aluno;

  @override
  Widget build(BuildContext context) {
    return ProfileHeader(
      name: aluno.nome,
      registration: aluno.ra,
      avatar: aluno.fotoUrl == null ? null : NetworkImage(aluno.fotoUrl!),
      trailing: aluno.sequenciaDias == null
          ? null
          : SequenciaBadge(dias: aluno.sequenciaDias!),
    );
  }
}
