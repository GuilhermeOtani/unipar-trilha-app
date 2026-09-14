import 'package:unipar_trilha_app/shared/models/aluno_resumo.dart';

/// Ícone do curso no card "Cursos/Trilhas" (tela 7).
///
/// Os logotipos não fazem parte do kit; `CursosCard` desenha glifos do Font
/// Awesome sobre as cores de marca de cada curso.
enum IconeCurso { spring, xampp, javascript, hibernate, generico }

/// Quantidade de trilhas por curso no card "Cursos/Trilhas" (tela 7).
class CursoResumo {
  const CursoResumo({
    required this.nome,
    required this.quantidade,
    this.icone = IconeCurso.generico,
  });

  final String nome;
  final int quantidade;
  final IconeCurso icone;
}

/// Dados da tela 7 — Visão geral do aluno.
class VisaoGeralAluno {
  const VisaoGeralAluno({
    required this.aluno,
    required this.pontos,
    required this.xp,
    required this.turma,
    required this.professores,
    required this.cursos,
    this.ranking,
  });

  final AlunoResumo aluno;

  /// Couves acumuladas, exibidas no card do perfil.
  final int pontos;
  final int xp;
  final String turma;
  final List<String> professores;

  /// Cursos na ordem de exibição: a grade é preenchida por coluna (duas
  /// linhas) e rola na horizontal.
  final List<CursoResumo> cursos;

  /// Nome da faixa de ranking (ex.: "Diamante"). Nulo oculta o item.
  final String? ranking;
}
