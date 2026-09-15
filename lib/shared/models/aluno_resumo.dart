/// Dados do aluno exibidos no cabeçalho das telas 1, 2 e 3 e no perfil.
class AlunoResumo {
  const AlunoResumo({
    required this.nome,
    required this.ra,
    this.rotuloIdentificacao = 'RA',
    this.fotoUrl,
    this.sequenciaDias,
  });

  final String nome;
  final String ra;
  final String rotuloIdentificacao;

  /// Endereço da foto. Nulo exibe as iniciais.
  final String? fotoUrl;

  /// Dias seguidos de estudo. Nulo oculta o indicador.
  final int? sequenciaDias;
}
