final class ConstantsApi {
  ConstantsApi._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const String health = '/actuator/health';
  static const String login = '/auth/login';
  static const String usuarioAtual = '/usuarios/me';
  static const String usuarios = '/usuarios';
  static const String professorContexto = '/professor/contexto';
  static const String trilhas = '/trilhas';
  static const String distribuicoes = '/distribuicoes';
  static const String alunoDistribuicoes = '/aluno/distribuicoes';

  static String alunoIniciarSessao(int distribuicaoId) =>
      '/aluno/distribuicoes/$distribuicaoId/sessoes';
  static String alunoCaminho(int distribuicaoId) =>
      '/aluno/distribuicoes/$distribuicaoId/caminho';
  static String alunoSessao(int sessaoId) => '/aluno/sessoes/$sessaoId';
  static String alunoRespostas(int sessaoId) =>
      '/aluno/sessoes/$sessaoId/respostas';
  static String trilha(int id) => '/trilhas/$id';
  static String publicarTrilha(int id) => '/trilhas/$id/publicacoes';
  static String indicadoresTurma(int turmaId) =>
      '/professor/turmas/$turmaId/indicadores';
}
