import 'package:unipar_trilha_app/modules/aprendizagem/models/caminho_trilha.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/models/trilha_resumo.dart';
import 'package:unipar_trilha_app/modules/home/models/home_aluno.dart';
import 'package:unipar_trilha_app/modules/perfil/models/visao_geral_aluno.dart';
import 'package:unipar_trilha_app/shared/models/aluno_resumo.dart';

/// Dados das telas do aluno que **ainda não têm endpoint** no backend.
///
/// Catálogo e prática não passam por aqui: vêm de `CatalogoAlunoService` e
/// `AprendizagemService`. Quando o backend expuser perfil, meta diária,
/// próxima lição e lições da trilha, cada campo vira um service do módulo.
class AlunoConteudo {
  const AlunoConteudo({
    required this.aluno,
    required this.caminhoDe,
    required this.visaoGeral,
    this.metaDiaria,
    this.proximaLicao,
  });

  /// Nome e RA podem vir de `AuthSession` (`/usuarios/me`).
  final AlunoResumo aluno;
  final MetaDiaria? metaDiaria;
  final ProximaLicao? proximaLicao;

  /// Lições exibidas no mapa (tela 2). O contrato atual não lista lições; a
  /// prática é aberta pela distribuição da trilha.
  final CaminhoTrilha Function(TrilhaResumo trilha) caminhoDe;
  final VisaoGeralAluno visaoGeral;
}
